from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field


REPO_ROOT = Path(__file__).resolve().parents[3]
STATE_DIR = REPO_ROOT / "runtime" / "state"
APP_BRANCH = "release/r19-product-reset-ui-api-agent-orchestration-slice"


class CardCreate(BaseModel):
    id: str | None = None
    title: str
    summary: str = ""
    status: str = "new"
    owner_agent_id: str = "orchestrator"
    priority: str = "medium"


class WorkOrderCreate(BaseModel):
    id: str | None = None
    card_id: str
    title: str
    summary: str = ""
    status: str = "awaiting_operator_approval"
    requested_by_agent_id: str = "orchestrator"
    assigned_agent_id: str = "developer_codex"
    approval_required: bool = True
    handoff_target_agent_id: str | None = None
    evidence_refs: list[str] = Field(default_factory=list)


class SeedStore:
    def __init__(self) -> None:
        self.status_seed = self._load_json("status.seed.json", {})
        self.cards = self._load_json("cards.seed.json", [])
        self.work_orders = self._load_json("work_orders.seed.json", [])
        self.agents = self._load_json("agents.seed.json", [])
        self.events = self._load_json("events.seed.json", [])
        self.evidence = self._load_json("evidence.seed.json", [])

    def _load_json(self, filename: str, fallback: Any) -> Any:
        path = STATE_DIR / filename
        if not path.exists():
            return fallback

        with path.open("r", encoding="utf-8") as handle:
            return json.load(handle)

    def status(self) -> dict[str, Any]:
        active_card = self.cards[0] if self.cards else {}
        active_work_order = self.work_orders[0] if self.work_orders else {}
        active_agent = self.agents[0] if self.agents else {}

        pending_approvals = [
            work_order
            for work_order in self.work_orders
            if work_order.get("approval_required")
            or work_order.get("status") in {"approval_required", "awaiting_operator_approval"}
        ]

        return {
            **self.status_seed,
            "repo": self.status_seed.get("repo", "RodneyMuniz/AIOffice_V2"),
            "branch": self.status_seed.get("branch", APP_BRANCH),
            "current_card_id": active_card.get("id"),
            "current_work_order_id": active_work_order.get("id"),
            "current_agent_id": active_agent.get("id"),
            "pending_approvals_count": len(pending_approvals),
            "events_count": len(self.events),
            "evidence_count": len(self.evidence),
        }

    def create_card(self, payload: CardCreate) -> dict[str, Any]:
        card = payload.dict(exclude_none=True)
        card.setdefault("id", f"R19-CARD-{len(self.cards) + 1:03d}")
        card["created_at"] = _utc_now()
        self.cards.append(card)
        self._append_event(
            event_type="card_created",
            summary=f"Card {card['id']} created through POST /cards.",
            actor_agent_id=card.get("owner_agent_id", "orchestrator"),
            related_card_id=card["id"],
        )
        return card

    def create_work_order(self, payload: WorkOrderCreate) -> dict[str, Any]:
        if not any(card.get("id") == payload.card_id for card in self.cards):
            raise HTTPException(status_code=404, detail=f"Unknown card_id: {payload.card_id}")

        work_order = payload.dict(exclude_none=True)
        work_order.setdefault("id", f"R19-WO-{len(self.work_orders) + 1:03d}")
        work_order["created_at"] = _utc_now()
        self.work_orders.append(work_order)
        self._append_event(
            event_type="work_order_created",
            summary=f"Work order {work_order['id']} created through POST /work-orders.",
            actor_agent_id=work_order.get("requested_by_agent_id", "orchestrator"),
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order["id"],
        )
        return work_order

    def _append_event(
        self,
        event_type: str,
        summary: str,
        actor_agent_id: str,
        related_card_id: str | None = None,
        related_work_order_id: str | None = None,
    ) -> None:
        self.events.append(
            {
                "id": f"R19-EVENT-{len(self.events) + 1:03d}",
                "timestamp": _utc_now(),
                "type": event_type,
                "summary": summary,
                "actor_agent_id": actor_agent_id,
                "related_card_id": related_card_id,
                "related_work_order_id": related_work_order_id,
            }
        )


def _utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


store = SeedStore()
app = FastAPI(
    title="AIOffice Orchestrator API",
    version="0.1.0",
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
