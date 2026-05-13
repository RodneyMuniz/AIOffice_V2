from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Literal

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field


REPO_ROOT = Path(__file__).resolve().parents[3]
STATE_DIR = REPO_ROOT / "runtime" / "state"
APP_BRANCH = "release/r19-product-reset-ui-api-agent-orchestration-slice"

CARD_STATUSES = ("intake", "planned", "in_progress", "blocked", "done", "archived")
WORK_ORDER_STATUSES = (
    "draft",
    "ready",
    "running",
    "waiting_approval",
    "approved",
    "rejected",
    "completed",
    "blocked",
    "cancelled",
)

ApprovalStatus = Literal["pending", "approved", "rejected"]
HandoffStatus = Literal["proposed", "accepted", "rejected", "completed", "blocked"]

HANDOFF_STATUSES = ("proposed", "accepted", "rejected", "completed", "blocked")
QA_RESULT_VALUES = ("passed", "failed", "blocked")


class CardCreate(BaseModel):
    id: str | None = None
    title: str
    description: str = ""
    summary: str | None = None
    status: str = "intake"
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


class HandoffCreate(BaseModel):
    id: str | None = None
    source_agent_id: str
    target_agent_id: str
    source_role: str
    target_role: str
    card_id: str
    work_order_id: str
    title: str
    summary: str = ""
    status: str = "proposed"
    payload_summary: str = ""
    validation_summary: str = ""
    evidence_refs: list[str] = Field(default_factory=list)


class HandoffDecisionRequest(BaseModel):
    decision_reason: str = ""
    decided_by: str = "operator"


class QaResultCreate(BaseModel):
    result: str
    summary: str
    findings: str = ""
    recommended_next_action: str = ""
    qa_agent_id: str = "qa_test"


class StatusUpdateRequest(BaseModel):
    status: str
    reason: str = ""
    requested_by: str = "operator"


class JsonStateStore:
    def __init__(self, state_dir: Path | None = None) -> None:
        configured_state_dir = os.environ.get("AIO_STATE_DIR")
        self.state_dir = state_dir or (Path(configured_state_dir) if configured_state_dir else STATE_DIR)
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.status_seed = self._load_json(self.state_dir / "status.seed.json", {})
        self.cards = self._load_collection("cards", [])
        self.work_orders = self._load_collection("work_orders", [])
        self.agents = self._load_collection("agents", [])
        self.events = self._load_collection("events", [])
        self.evidence = self._load_collection("evidence", [])
        self.approvals = self._load_collection("approvals", [])
        self.handoffs = self._load_collection("handoffs", [])
        self.qa_results = self._load_collection("qa_results", [])

    def _load_json(self, path: Path, fallback: Any) -> Any:
        if not path.exists():
            return fallback

        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)

    def _load_collection(self, name: str, fallback: Any) -> Any:
        persistent_path = self.state_dir / f"{name}.json"
        if persistent_path.exists():
            return self._load_json(persistent_path, fallback)

        seed_path = self.state_dir / f"{name}.seed.json"
        return self._load_json(seed_path, fallback)

    def _save_collection(self, name: str, records: Any) -> None:
        path = self.state_dir / f"{name}.json"
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
        pending_handoffs_count = sum(
            1 for handoff in self.handoffs if handoff.get("status") == "proposed"
        )
        failed_qa_results_count = sum(
            1 for qa_result in self.qa_results if qa_result.get("result") == "failed"
        )
        blocked_qa_results_count = sum(
            1 for qa_result in self.qa_results if qa_result.get("result") == "blocked"
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
            "handoffs_count": len(self.handoffs),
            "pending_handoffs_count": pending_handoffs_count,
            "qa_results_count": len(self.qa_results),
            "failed_qa_results_count": failed_qa_results_count,
            "blocked_qa_results_count": blocked_qa_results_count,
            "events_count": len(self.events),
            "evidence_count": len(self.evidence),
            "allowed_card_statuses": list(CARD_STATUSES),
            "allowed_work_order_statuses": list(WORK_ORDER_STATUSES),
        }

    def create_card(self, payload: CardCreate) -> dict[str, Any]:
        card_data = _model_to_dict(payload)
        description = card_data.pop("description", "")
        summary = card_data.pop("summary", None) or description
        owner_agent_id = card_data.pop("owner_agent_id", None) or "orchestrator"
        status = card_data.get("status") or "intake"
        _validate_status(status, CARD_STATUSES, "card")
        card_data["status"] = status
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
            "waiting_approval" if approval_required else "draft"
        )
        _validate_status(status, WORK_ORDER_STATUSES, "work-order")
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

    def update_card_status(self, card_id: str, payload: StatusUpdateRequest) -> dict[str, Any]:
        card = self._find_card(card_id)
        if card is None:
            raise HTTPException(status_code=404, detail=f"Unknown card id: {card_id}")

        update_data = _model_to_dict(payload)
        status = str(update_data.get("status", "")).strip()
        _validate_status(status, CARD_STATUSES, "card")
        previous_status = card.get("status")
        requested_by = str(update_data.get("requested_by") or "operator").strip() or "operator"
        reason = str(update_data.get("reason") or "").strip()

        card["status"] = status
        card["updated_at"] = _utc_now()
        summary = f"Card {card_id} status changed from {previous_status} to {status}."
        if reason:
            summary = f"{summary} Reason: {reason}"

        self._append_event(
            event_type="card_status_changed",
            summary=summary,
            actor_agent_id=requested_by,
            related_card_id=card_id,
        )
        self._append_evidence(
            title=f"Card {card_id} status changed",
            kind="status_transition",
            summary=summary,
            path=f"runtime/state/cards.json#{card_id}",
            related_card_id=card_id,
        )
        self._save_collection("cards", self.cards)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return card

    def update_work_order_status(
        self, work_order_id: str, payload: StatusUpdateRequest
    ) -> dict[str, Any]:
        work_order = self._find_work_order(work_order_id)
        if work_order is None:
            raise HTTPException(status_code=404, detail=f"Unknown work-order id: {work_order_id}")

        update_data = _model_to_dict(payload)
        status = str(update_data.get("status", "")).strip()
        _validate_status(status, WORK_ORDER_STATUSES, "work-order")
        requested_by = str(update_data.get("requested_by") or "operator").strip() or "operator"
        reason = str(update_data.get("reason") or "").strip()

        self._apply_work_order_status(work_order, status, reason, requested_by)
        if status == "waiting_approval" and not self._find_pending_approval_for_work_order(work_order_id):
            self._create_approval_record(
                title=f"Approve work order {work_order_id}",
                description=f"Approval gate requested by status transition for work order '{work_order['title']}'.",
                related_card_id=work_order["card_id"],
                related_work_order_id=work_order_id,
                requested_by=requested_by,
                emit_action_records=True,
            )

        self._save_collection("work_orders", self.work_orders)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        if status == "waiting_approval":
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

    def create_handoff(self, payload: HandoffCreate) -> dict[str, Any]:
        handoff_data = _model_to_dict(payload)
        status = str(handoff_data.get("status") or "proposed").strip()
        _validate_status(status, HANDOFF_STATUSES, "handoff")

        source_agent_id = str(handoff_data["source_agent_id"]).strip()
        target_agent_id = str(handoff_data["target_agent_id"]).strip()
        card_id = str(handoff_data["card_id"]).strip()
        work_order_id = str(handoff_data["work_order_id"]).strip()
        source_agent = self._find_agent(source_agent_id)
        target_agent = self._find_agent(target_agent_id)
        card = self._find_card(card_id)
        work_order = self._find_work_order(work_order_id)

        if source_agent is None:
            raise HTTPException(status_code=400, detail=f"Invalid source_agent_id: {source_agent_id}.")
        if target_agent is None:
            raise HTTPException(status_code=400, detail=f"Invalid target_agent_id: {target_agent_id}.")
        if card is None:
            raise HTTPException(status_code=400, detail=f"Invalid card_id: {card_id}.")
        if work_order is None:
            raise HTTPException(status_code=400, detail=f"Invalid work_order_id: {work_order_id}.")
        if work_order.get("card_id") != card_id:
            raise HTTPException(
                status_code=400,
                detail=f"work_order_id {work_order_id} does not belong to card_id {card_id}.",
            )

        now = _utc_now()
        payload_summary = (
            handoff_data.get("payload_summary")
            or f"Work order {work_order_id}: {work_order['title']} is currently {work_order['status']}."
        )
        validation_summary = (
            handoff_data.get("validation_summary")
            or (
                f"Validated {source_agent_id} -> {target_agent_id} handoff for "
                f"card {card_id} and work order {work_order_id}."
            )
        )
        handoff_id = handoff_data.get("id") or self._next_id(self.handoffs, "R19-HANDOFF")
        evidence_refs = [
            *handoff_data.get("evidence_refs", []),
            f"runtime/state/handoffs.json#{handoff_id}",
        ]
        handoff = {
            "id": handoff_id,
            "source_agent_id": source_agent_id,
            "target_agent_id": target_agent_id,
            "source_role": handoff_data["source_role"],
            "target_role": handoff_data["target_role"],
            "card_id": card_id,
            "work_order_id": work_order_id,
            "title": handoff_data["title"],
            "summary": handoff_data.get("summary", ""),
            "status": status,
            "payload_summary": payload_summary,
            "validation_summary": validation_summary,
            "created_at": now,
            "updated_at": now,
            "decided_at": None,
            "decision_reason": None,
            "evidence_refs": evidence_refs,
        }

        self.handoffs.append(handoff)
        self._append_event(
            event_type="handoff_created",
            summary=f"Handoff {handoff_id} proposed from {source_agent_id} to {target_agent_id}.",
            actor_agent_id=source_agent_id,
            related_card_id=card_id,
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
        )
        self._append_evidence(
            title=f"Handoff {handoff_id} created",
            kind="handoff_record",
            summary=validation_summary,
            path=f"runtime/state/handoffs.json#{handoff_id}",
            related_card_id=card_id,
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
        )
        self._save_collection("handoffs", self.handoffs)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return handoff

    def handoff_work_order_to_qa(self, work_order_id: str) -> dict[str, Any]:
        work_order = self._find_work_order(work_order_id)
        if work_order is None:
            raise HTTPException(status_code=404, detail=f"Unknown work-order id: {work_order_id}")

        evidence_refs = list(work_order.get("evidence_refs", []))
        evidence_refs.append(f"runtime/state/work_orders.json#{work_order_id}")
        return self.create_handoff(
            HandoffCreate(
                source_agent_id="developer_codex",
                target_agent_id="qa_test",
                source_role="Developer/Codex",
                target_role="QA/Test",
                card_id=work_order["card_id"],
                work_order_id=work_order_id,
                title=f"QA handoff for {work_order_id}",
                summary=f"Developer/Codex requests QA/Test validation for '{work_order['title']}'.",
                status="proposed",
                payload_summary=(
                    f"Work order '{work_order['title']}' is currently {work_order['status']} "
                    f"and assigned to {work_order.get('assigned_agent_id', 'unknown')}."
                ),
                validation_summary=(
                    "API dry-run handoff only: source/target agents, card, and work-order linkage "
                    "were validated; no AI or autonomous agent was invoked."
                ),
                evidence_refs=evidence_refs,
            )
        )

    def accept_handoff(
        self, handoff_id: str, decision: HandoffDecisionRequest
    ) -> dict[str, Any]:
        return self._decide_handoff(handoff_id, "accepted", decision)

    def reject_handoff(
        self, handoff_id: str, decision: HandoffDecisionRequest
    ) -> dict[str, Any]:
        return self._decide_handoff(handoff_id, "rejected", decision)

    def create_qa_result(self, handoff_id: str, payload: QaResultCreate) -> dict[str, Any]:
        handoff = self._find_handoff(handoff_id)
        if handoff is None:
            raise HTTPException(status_code=404, detail=f"Unknown handoff id: {handoff_id}")

        handoff_status = handoff.get("status")
        if handoff_status != "accepted":
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Handoff {handoff_id} is {handoff_status}; "
                    "QA results can only be recorded for accepted handoffs."
                ),
            )

        if self._find_qa_result_for_handoff(handoff_id):
            raise HTTPException(
                status_code=400,
                detail=f"QA result already exists for handoff {handoff_id}.",
            )

        result_data = _model_to_dict(payload)
        result = str(result_data.get("result") or "").strip()
        _validate_status(result, QA_RESULT_VALUES, "QA result")

        qa_agent_id = str(result_data.get("qa_agent_id") or "qa_test").strip() or "qa_test"
        now = _utc_now()
        qa_result_id = self._next_id(self.qa_results, "R19-QA-RESULT")
        evidence_refs = [
            f"runtime/state/handoffs.json#{handoff_id}",
            f"runtime/state/qa_results.json#{qa_result_id}",
        ]
        qa_result = {
            "id": qa_result_id,
            "handoff_id": handoff_id,
            "card_id": handoff["card_id"],
            "work_order_id": handoff["work_order_id"],
            "qa_agent_id": qa_agent_id,
            "result": result,
            "summary": str(result_data.get("summary") or "").strip(),
            "findings": str(result_data.get("findings") or "").strip(),
            "recommended_next_action": str(
                result_data.get("recommended_next_action") or ""
            ).strip(),
            "created_at": now,
            "updated_at": now,
            "evidence_refs": evidence_refs,
        }

        self.qa_results.append(qa_result)
        self._append_event(
            event_type="qa_result_recorded",
            summary=f"QA result {qa_result_id} recorded as {result} for handoff {handoff_id}.",
            actor_agent_id=qa_agent_id,
            related_card_id=handoff["card_id"],
            related_work_order_id=handoff["work_order_id"],
            related_handoff_id=handoff_id,
        )
        self._append_evidence(
            title=f"QA result {qa_result_id} recorded",
            kind="qa_result",
            summary=qa_result["summary"] or f"QA result recorded as {result}.",
            path=f"runtime/state/qa_results.json#{qa_result_id}",
            related_card_id=handoff["card_id"],
            related_work_order_id=handoff["work_order_id"],
            related_handoff_id=handoff_id,
        )

        work_order = self._find_work_order(handoff["work_order_id"])
        if work_order:
            target_status = "completed" if result == "passed" else "blocked"
            if work_order.get("status") != target_status:
                self._apply_work_order_status_from_qa(
                    work_order=work_order,
                    target_status=target_status,
                    qa_result=qa_result,
                    requested_by=qa_agent_id,
                )
            self._save_collection("work_orders", self.work_orders)

        self._save_collection("qa_results", self.qa_results)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return qa_result

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

        work_order_id = approval.get("related_work_order_id")
        if work_order_id:
            work_order = self._find_work_order(work_order_id)
            if work_order and work_order.get("status") == "waiting_approval":
                self._apply_work_order_status(work_order, status, reason, decided_by)

        self._save_collection("approvals", self.approvals)
        if work_order_id:
            self._save_collection("work_orders", self.work_orders)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return approval

    def _decide_handoff(
        self,
        handoff_id: str,
        status: HandoffStatus,
        decision: HandoffDecisionRequest,
    ) -> dict[str, Any]:
        handoff = self._find_handoff(handoff_id)
        if handoff is None:
            raise HTTPException(status_code=404, detail=f"Unknown handoff id: {handoff_id}")
        if handoff.get("status") != "proposed":
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Handoff {handoff_id} is already {handoff.get('status')}; "
                    "only proposed handoffs can be accepted or rejected."
                ),
            )

        decision_data = _model_to_dict(decision)
        reason = (
            str(decision_data.get("decision_reason") or "").strip()
            or f"Operator {status} handoff {handoff_id}."
        )
        decided_by = str(decision_data.get("decided_by") or "operator").strip() or "operator"
        now = _utc_now()
        handoff["status"] = status
        handoff["updated_at"] = now
        handoff["decided_at"] = now
        handoff["decision_reason"] = reason

        self._append_event(
            event_type=f"handoff_{status}",
            summary=f"Handoff {handoff_id} {status}.",
            actor_agent_id=decided_by,
            related_card_id=handoff["card_id"],
            related_work_order_id=handoff["work_order_id"],
            related_handoff_id=handoff_id,
        )
        self._append_evidence(
            title=f"Handoff {handoff_id} {status}",
            kind="handoff_decision",
            summary=reason,
            path=f"runtime/state/handoffs.json#{handoff_id}",
            related_card_id=handoff["card_id"],
            related_work_order_id=handoff["work_order_id"],
            related_handoff_id=handoff_id,
        )

        self._save_collection("handoffs", self.handoffs)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return handoff

    def _apply_work_order_status(
        self,
        work_order: dict[str, Any],
        status: str,
        reason: str,
        requested_by: str,
    ) -> None:
        previous_status = work_order.get("status")
        work_order["status"] = status
        work_order["updated_at"] = _utc_now()
        work_order_id = work_order["id"]
        summary = f"Work order {work_order_id} status changed from {previous_status} to {status}."
        if reason:
            summary = f"{summary} Reason: {reason}"

        self._append_event(
            event_type="work_order_status_changed",
            summary=summary,
            actor_agent_id=requested_by,
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
        )
        self._append_evidence(
            title=f"Work order {work_order_id} status changed",
            kind="status_transition",
            summary=summary,
            path=f"runtime/state/work_orders.json#{work_order_id}",
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
        )

    def _apply_work_order_status_from_qa(
        self,
        work_order: dict[str, Any],
        target_status: str,
        qa_result: dict[str, Any],
        requested_by: str,
    ) -> None:
        previous_status = work_order.get("status")
        work_order["status"] = target_status
        work_order["updated_at"] = _utc_now()
        work_order_id = work_order["id"]
        handoff_id = qa_result["handoff_id"]
        result = qa_result["result"]
        summary = (
            f"QA result {qa_result['id']} ({result}) moved work order {work_order_id} "
            f"from {previous_status} to {target_status}."
        )
        event_type = (
            "work_order_completed_from_qa"
            if target_status == "completed"
            else "work_order_blocked_from_qa"
        )

        self._append_event(
            event_type=event_type,
            summary=summary,
            actor_agent_id=requested_by,
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
        )
        self._append_evidence(
            title=f"Work order {work_order_id} updated from QA",
            kind="status_transition",
            summary=summary,
            path=f"runtime/state/work_orders.json#{work_order_id}",
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
        )

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
        related_handoff_id: str | None = None,
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
            "related_handoff_id": related_handoff_id,
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
        related_handoff_id: str | None = None,
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
            "related_handoff_id": related_handoff_id,
            "created_at": _utc_now(),
        }
        self.evidence.append({key: value for key, value in evidence.items() if value is not None})

    def _find_agent(self, agent_id: str) -> dict[str, Any] | None:
        return next((agent for agent in self.agents if agent.get("id") == agent_id), None)

    def _find_card(self, card_id: str) -> dict[str, Any] | None:
        return next((card for card in self.cards if card.get("id") == card_id), None)

    def _find_work_order(self, work_order_id: str) -> dict[str, Any] | None:
        return next(
            (work_order for work_order in self.work_orders if work_order.get("id") == work_order_id),
            None,
        )

    def _find_approval(self, approval_id: str) -> dict[str, Any] | None:
        return next((approval for approval in self.approvals if approval.get("id") == approval_id), None)

    def _find_handoff(self, handoff_id: str) -> dict[str, Any] | None:
        return next((handoff for handoff in self.handoffs if handoff.get("id") == handoff_id), None)

    def _find_qa_result_for_handoff(self, handoff_id: str) -> dict[str, Any] | None:
        return next(
            (qa_result for qa_result in self.qa_results if qa_result.get("handoff_id") == handoff_id),
            None,
        )

    def _find_pending_approval_for_work_order(self, work_order_id: str) -> dict[str, Any] | None:
        return next(
            (
                approval
                for approval in self.approvals
                if approval.get("related_work_order_id") == work_order_id
                and approval.get("status") == "pending"
            ),
            None,
        )

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


def _validate_status(status: str, allowed_statuses: tuple[str, ...], record_kind: str) -> None:
    if status not in allowed_statuses:
        allowed = ", ".join(allowed_statuses)
        raise HTTPException(
            status_code=400,
            detail=f"Invalid {record_kind} status: {status}. Allowed statuses: {allowed}.",
        )


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
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=False,
    allow_methods=["GET", "POST", "PATCH", "OPTIONS"],
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


@app.patch("/cards/{card_id}/status")
def patch_card_status(card_id: str, status_update: StatusUpdateRequest) -> dict[str, Any]:
    return store.update_card_status(card_id, status_update)


@app.get("/work-orders")
def get_work_orders() -> list[dict[str, Any]]:
    return store.work_orders


@app.post("/work-orders", status_code=201)
def post_work_orders(work_order: WorkOrderCreate) -> dict[str, Any]:
    return store.create_work_order(work_order)


@app.patch("/work-orders/{work_order_id}/status")
def patch_work_order_status(work_order_id: str, status_update: StatusUpdateRequest) -> dict[str, Any]:
    return store.update_work_order_status(work_order_id, status_update)


@app.post("/work-orders/{work_order_id}/handoff-to-qa", status_code=201)
def post_work_order_handoff_to_qa(work_order_id: str) -> dict[str, Any]:
    return store.handoff_work_order_to_qa(work_order_id)


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


@app.get("/handoffs")
def get_handoffs() -> list[dict[str, Any]]:
    return store.handoffs


@app.get("/qa-results")
def get_qa_results() -> list[dict[str, Any]]:
    return store.qa_results


@app.post("/approvals", status_code=201)
def post_approvals(approval: ApprovalCreate) -> dict[str, Any]:
    return store.create_approval(approval)


@app.post("/approvals/{approval_id}/approve")
def post_approval_approve(approval_id: str, decision: ApprovalDecision | None = None) -> dict[str, Any]:
    return store.approve_approval(approval_id, decision or ApprovalDecision())


@app.post("/approvals/{approval_id}/reject")
def post_approval_reject(approval_id: str, decision: ApprovalDecision | None = None) -> dict[str, Any]:
    return store.reject_approval(approval_id, decision or ApprovalDecision())


@app.post("/handoffs", status_code=201)
def post_handoffs(handoff: HandoffCreate) -> dict[str, Any]:
    return store.create_handoff(handoff)


@app.post("/handoffs/{handoff_id}/accept")
def post_handoff_accept(
    handoff_id: str, decision: HandoffDecisionRequest | None = None
) -> dict[str, Any]:
    return store.accept_handoff(handoff_id, decision or HandoffDecisionRequest())


@app.post("/handoffs/{handoff_id}/reject")
def post_handoff_reject(
    handoff_id: str, decision: HandoffDecisionRequest | None = None
) -> dict[str, Any]:
    return store.reject_handoff(handoff_id, decision or HandoffDecisionRequest())


@app.post("/handoffs/{handoff_id}/qa-result", status_code=201)
def post_handoff_qa_result(handoff_id: str, qa_result: QaResultCreate) -> dict[str, Any]:
    return store.create_qa_result(handoff_id, qa_result)
