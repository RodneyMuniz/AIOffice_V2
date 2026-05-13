from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Literal

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field


REPO_ROOT = Path(__file__).resolve().parents[3]
STATE_DIR = REPO_ROOT / "runtime" / "state"
APP_BRANCH = "release/r19-product-reset-ui-api-agent-orchestration-slice"

ApprovalStatus = Literal["pending", "approved", "rejected"]


class CardCreate(BaseModel):
    id: str | None = None
    title: str
    description: str = ""
    summary: str | None = None
    status: str = "new"
    owner_role: str = "operator"
    owner_agent_id: str | None = None
    priority: str = "medium"


class WorkOrderCreate(BaseModel):
    id: str | None = None
    card_id: str
    title: str
    description: str = ""
    summary: str | None = None
    status: str | None = None
    requested_by_agent_id: str = "orchestrator"
    assigned_agent_id: str = "developer_codex"
    request_requires_approval: bool = False
    approval_required: bool | None = None
    handoff_target_agent_id: str | None = None
    evidence_refs: list[str] = Field(default_factory=list)


class ApprovalCreate(BaseModel):
    id: str | None = None
    title: str
    description: str = ""
    related_card_id: str | None = None
    related_work_order_id: str | None = None
    requested_by: str = "operator"


class ApprovalDecision(BaseModel):
    decision_reason: str = ""
    decided_by: str = "operator"


class JsonStateStore:
    def __init__(self) -> None:
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        self.status_seed = self._load_json(STATE_DIR / "status.seed.json", {})
        self.cards = self._load_collection("cards", [])
        self.work_orders = self._load_collection("work_orders", [])
        self.agents = self._load_collection("agents", [])
        self.events = self._load_collection("events", [])
        self.evidence = self._load_collection("evidence", [])
        self.approvals = self._load_collection("approvals", [])

    def _load_json(self, path: Path, fallback: Any) -> Any:
        if not path.exists():
            return fallback

        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)

    def _load_collection(self, name: str, fallback: Any) -> Any:
        persistent_path = STATE_DIR / f"{name}.json"
        if persistent_path.exists():
            return self._load_json(persistent_path, fallback)

        seed_path = STATE_DIR / f"{name}.seed.json"
        return self._load_json(seed_path, fallback)

    def _save_collection(self, name: str, records: Any) -> None:
        path = STATE_DIR / f"{name}.json"
        temporary_path = path.with_suffix(f"{path.suffix}.tmp")
        with temporary_path.open("w", encoding="utf-8", newline="\n") as handle:
            json.dump(records, handle, indent=2)
            handle.write("\n")
        temporary_path.replace(path)

    def status(self) -> dict[str, Any]:
        active_card = self.cards[-1] if self.cards else {}
        active_work_order = self.work_orders[-1] if self.work_orders else {}
        active_agent = self.agents[0] if self.agents else {}
        pending_approvals_count = sum(
            1 for approval in self.approvals if approval.get("status") == "pending"
        )

        return {
            **self.status_seed,
            "repo": self.status_seed.get("repo", "RodneyMuniz/AIOffice_V2"),
            "branch": self.status_seed.get("branch", APP_BRANCH),
            "current_card_id": active_card.get("id"),
            "current_work_order_id": active_work_order.get("id"),
            "current_agent_id": active_agent.get("id"),
            "cards_count": len(self.cards),
            "work_orders_count": len(self.work_orders),
            "approvals_count": len(self.approvals),
            "pending_approvals_count": pending_approvals_count,
            "events_count": len(self.events),
            "evidence_count": len(self.evidence),
        }

    def create_card(self, payload: CardCreate) -> dict[str, Any]:
        card_data = _model_to_dict(payload)
        description = card_data.pop("description", "")
        summary = card_data.pop("summary", None) or description
        owner_agent_id = card_data.pop("owner_agent_id", None) or "orchestrator"
        card = {
            **card_data,
            "id": card_data.get("id") or self._next_id(self.cards, "R19-CARD"),
            "summary": summary,
            "owner_agent_id": owner_agent_id,
            "created_at": _utc_now(),
        }

        self.cards.append(card)
        self._append_event(
            event_type="card_created",
            summary=f"Card {card['id']} created from the operator UI/API.",
            actor_agent_id=card["owner_agent_id"],
            related_card_id=card["id"],
        )
        self._append_evidence(
            title=f"Card {card['id']} created",
            kind="operator_action",
            summary=f"Created card '{card['title']}' through POST /cards.",
            path=f"runtime/state/cards.json#{card['id']}",
            related_card_id=card["id"],
        )
        self._save_collection("cards", self.cards)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return card

    def create_work_order(self, payload: WorkOrderCreate) -> dict[str, Any]:
        card = self._find_card(payload.card_id)
        if card is None:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Invalid card_id: {payload.card_id}. "
                    "Create the card first or select an existing card_id."
                ),
            )

        work_order_data = _model_to_dict(payload)
        description = work_order_data.pop("description", "")
        summary = work_order_data.pop("summary", None) or description
        approval_required = (
            work_order_data.pop("approval_required")
            if work_order_data.get("approval_required") is not None
            else work_order_data.pop("request_requires_approval", False)
        )
        work_order_data.pop("request_requires_approval", None)
        status = work_order_data.pop("status", None) or (
            "awaiting_operator_approval" if approval_required else "queued"
        )
        work_order = {
            **work_order_data,
            "id": work_order_data.get("id") or self._next_id(self.work_orders, "R19-WO"),
            "summary": summary,
            "status": status,
            "approval_required": bool(approval_required),
            "created_at": _utc_now(),
        }

        self.work_orders.append(work_order)
        self._append_event(
            event_type="work_order_created",
            summary=f"Work order {work_order['id']} created from the operator UI/API.",
            actor_agent_id=work_order.get("requested_by_agent_id", "orchestrator"),
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order["id"],
        )
        self._append_evidence(
            title=f"Work order {work_order['id']} created",
            kind="operator_action",
            summary=f"Created work order '{work_order['title']}' linked to {work_order['card_id']}.",
            path=f"runtime/state/work_orders.json#{work_order['id']}",
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order["id"],
        )

        if approval_required:
            self._create_approval_record(
                title=f"Approve work order {work_order['id']}",
                description=f"Approval gate for work order '{work_order['title']}'.",
                related_card_id=work_order["card_id"],
                related_work_order_id=work_order["id"],
                requested_by=work_order.get("requested_by_agent_id", "orchestrator"),
                emit_action_records=True,
            )

        self._save_collection("work_orders", self.work_orders)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        if approval_required:
            self._save_collection("approvals", self.approvals)
        return work_order

    def create_approval(self, payload: ApprovalCreate) -> dict[str, Any]:
        approval_data = _model_to_dict(payload)
        approval = self._create_approval_record(
            title=approval_data["title"],
            description=approval_data.get("description", ""),
            related_card_id=approval_data.get("related_card_id"),
            related_work_order_id=approval_data.get("related_work_order_id"),
            requested_by=approval_data.get("requested_by", "operator"),
            approval_id=approval_data.get("id"),
            emit_action_records=True,
        )
        self._save_collection("approvals", self.approvals)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return approval

    def approve_approval(self, approval_id: str, decision: ApprovalDecision) -> dict[str, Any]:
        return self._decide_approval(approval_id, "approved", decision)

    def reject_approval(self, approval_id: str, decision: ApprovalDecision) -> dict[str, Any]:
        return self._decide_approval(approval_id, "rejected", decision)

    def _create_approval_record(
        self,
        title: str,
        description: str,
        related_card_id: str | None,
        related_work_order_id: str | None,
        requested_by: str,
        approval_id: str | None = None,
        emit_action_records: bool = False,
    ) -> dict[str, Any]:
        related_card_id = self._resolve_related_card_id(related_card_id, related_work_order_id)
        approval = {
            "id": approval_id or self._next_id(self.approvals, "R19-APPROVAL"),
            "title": title,
            "description": description,
            "related_card_id": related_card_id,
            "related_work_order_id": related_work_order_id,
            "status": "pending",
            "requested_by": requested_by,
            "created_at": _utc_now(),
            "decided_at": None,
            "decision_reason": None,
        }
        self.approvals.append(approval)

        if emit_action_records:
            self._append_event(
                event_type="approval_requested",
                summary=f"Approval {approval['id']} requested.",
                actor_agent_id=requested_by,
                related_card_id=related_card_id,
                related_work_order_id=related_work_order_id,
                related_approval_id=approval["id"],
            )
            self._append_evidence(
                title=f"Approval {approval['id']} requested",
                kind="approval_gate",
                summary=f"Pending approval requested for '{title}'.",
                path=f"runtime/state/approvals.json#{approval['id']}",
                related_card_id=related_card_id,
                related_work_order_id=related_work_order_id,
                related_approval_id=approval["id"],
            )

        return approval

    def _decide_approval(
        self,
        approval_id: str,
        status: ApprovalStatus,
        decision: ApprovalDecision,
    ) -> dict[str, Any]:
        approval = self._find_approval(approval_id)
        if approval is None:
            raise HTTPException(status_code=404, detail=f"Unknown approval id: {approval_id}")
        if approval.get("status") != "pending":
            raise HTTPException(
                status_code=400,
                detail=f"Approval {approval_id} is already {approval.get('status')}.",
            )

        decision_data = _model_to_dict(decision)
        reason = decision_data.get("decision_reason") or f"Operator {status} approval."
        decided_by = decision_data.get("decided_by", "operator")
        approval["status"] = status
        approval["decided_at"] = _utc_now()
        approval["decision_reason"] = reason

        self._append_event(
            event_type=f"approval_{status}",
            summary=f"Approval {approval_id} {status}.",
            actor_agent_id=decided_by,
            related_card_id=approval.get("related_card_id"),
            related_work_order_id=approval.get("related_work_order_id"),
            related_approval_id=approval_id,
        )
        self._append_evidence(
            title=f"Approval {approval_id} {status}",
            kind="approval_decision",
            summary=reason,
            path=f"runtime/state/approvals.json#{approval_id}",
            related_card_id=approval.get("related_card_id"),
            related_work_order_id=approval.get("related_work_order_id"),
            related_approval_id=approval_id,
        )

        self._save_collection("approvals", self.approvals)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return approval

    def _resolve_related_card_id(
        self, related_card_id: str | None, related_work_order_id: str | None
    ) -> str:
        if related_work_order_id:
            work_order = self._find_work_order(related_work_order_id)
            if work_order is None:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid related_work_order_id: {related_work_order_id}.",
                )
            work_order_card_id = work_order.get("card_id")
            if related_card_id and related_card_id != work_order_card_id:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        "related_card_id must match the selected work order's card_id "
                        f"({work_order_card_id})."
                    ),
                )
            return work_order_card_id

        if not related_card_id:
            raise HTTPException(
                status_code=400,
                detail="Approval requests require related_card_id or related_work_order_id.",
            )
        if self._find_card(related_card_id) is None:
            raise HTTPException(status_code=400, detail=f"Invalid related_card_id: {related_card_id}.")
        return related_card_id

    def _append_event(
        self,
        event_type: str,
        summary: str,
        actor_agent_id: str,
        related_card_id: str | None = None,
        related_work_order_id: str | None = None,
        related_approval_id: str | None = None,
    ) -> None:
        event = {
            "id": self._next_id(self.events, "R19-EVENT"),
            "timestamp": _utc_now(),
            "type": event_type,
            "summary": summary,
            "actor_agent_id": actor_agent_id,
            "related_card_id": related_card_id,
            "related_work_order_id": related_work_order_id,
            "related_approval_id": related_approval_id,
        }
        self.events.append({key: value for key, value in event.items() if value is not None})

    def _append_evidence(
        self,
        title: str,
        kind: str,
        summary: str,
        path: str,
        related_card_id: str,
        related_work_order_id: str | None = None,
        related_approval_id: str | None = None,
    ) -> None:
        evidence = {
            "id": self._next_id(self.evidence, "R19-EVIDENCE"),
            "title": title,
            "kind": kind,
            "summary": summary,
            "path": path,
            "related_card_id": related_card_id,
            "related_work_order_id": related_work_order_id,
            "related_approval_id": related_approval_id,
            "created_at": _utc_now(),
        }
        self.evidence.append({key: value for key, value in evidence.items() if value is not None})

    def _find_card(self, card_id: str) -> dict[str, Any] | None:
        return next((card for card in self.cards if card.get("id") == card_id), None)

    def _find_work_order(self, work_order_id: str) -> dict[str, Any] | None:
        return next(
            (work_order for work_order in self.work_orders if work_order.get("id") == work_order_id),
            None,
        )

    def _find_approval(self, approval_id: str) -> dict[str, Any] | None:
        return next((approval for approval in self.approvals if approval.get("id") == approval_id), None)

    def _next_id(self, records: list[dict[str, Any]], prefix: str) -> str:
        next_number = 1
        token = f"{prefix}-"
        for record in records:
            record_id = str(record.get("id", ""))
            if not record_id.startswith(token):
                continue
            try:
                next_number = max(next_number, int(record_id.removeprefix(token)) + 1)
            except ValueError:
                continue
        return f"{prefix}-{next_number:03d}"


def _model_to_dict(model: BaseModel) -> dict[str, Any]:
    if hasattr(model, "model_dump"):
        return model.model_dump(exclude_none=True)
    return model.dict(exclude_none=True)


def _utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


store = JsonStateStore()
app = FastAPI(
    title="AIOffice Orchestrator API",
    version="0.2.0",
    description="R19 local product reset API slice. No OpenAI or Codex APIs are invoked.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)


@app.get("/status")
def get_status() -> dict[str, Any]:
    return store.status()


@app.get("/cards")
def get_cards() -> list[dict[str, Any]]:
    return store.cards


@app.post("/cards", status_code=201)
def post_cards(card: CardCreate) -> dict[str, Any]:
    return store.create_card(card)


@app.get("/work-orders")
def get_work_orders() -> list[dict[str, Any]]:
    return store.work_orders


@app.post("/work-orders", status_code=201)
def post_work_orders(work_order: WorkOrderCreate) -> dict[str, Any]:
    return store.create_work_order(work_order)


@app.get("/agents")
def get_agents() -> list[dict[str, Any]]:
    return store.agents


@app.get("/events")
def get_events() -> list[dict[str, Any]]:
    return store.events


@app.get("/evidence")
def get_evidence() -> list[dict[str, Any]]:
    return store.evidence


@app.get("/approvals")
def get_approvals() -> list[dict[str, Any]]:
    return store.approvals


@app.post("/approvals", status_code=201)
def post_approvals(approval: ApprovalCreate) -> dict[str, Any]:
    return store.create_approval(approval)


@app.post("/approvals/{approval_id}/approve")
def post_approval_approve(approval_id: str, decision: ApprovalDecision | None = None) -> dict[str, Any]:
    return store.approve_approval(approval_id, decision or ApprovalDecision())


@app.post("/approvals/{approval_id}/reject")
def post_approval_reject(approval_id: str, decision: ApprovalDecision | None = None) -> dict[str, Any]:
    return store.reject_approval(approval_id, decision or ApprovalDecision())
