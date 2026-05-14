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
WORK_ORDER_TYPES = ("original", "repair")
HANDOFF_PURPOSES = ("initial_qa", "repair_qa")
DEVELOPER_RESULT_TYPES = ("implementation", "repair", "documentation", "validation", "other")
DEVELOPER_RESULT_STATUSES = ("draft", "submitted", "superseded")
REPAIR_QA_HANDOFF_REPAIR_STATUSES = ("created", "in_progress", "completed")
REPAIR_QA_HANDOFF_WORK_ORDER_STATUSES = ("ready", "completed")
ACTIVE_HANDOFF_STATUSES = ("proposed", "accepted")
READINESS_CHECK_STATUSES = ("passed", "warning", "blocked")
READINESS_LEVELS = ("ready", "warning", "blocked")
QA_HANDOFF_POLICY_MODES = ("advisory", "enforced")
DEFAULT_POLICY_SETTINGS = {
    "qa_handoff_policy_mode": "advisory",
    "require_developer_result_for_qa": False,
    "require_developer_result_for_repair_qa": False,
    "allow_operator_override": False,
    "updated_at": "2026-05-13T00:00:00Z",
    "updated_by": "system",
}

ApprovalStatus = Literal["pending", "approved", "rejected"]
HandoffStatus = Literal["proposed", "accepted", "rejected", "completed", "blocked"]
DeveloperResultStatus = Literal["draft", "submitted", "superseded"]
RepairRequestStatus = Literal["proposed", "created", "in_progress", "completed", "cancelled"]

HANDOFF_STATUSES = ("proposed", "accepted", "rejected", "completed", "blocked")
QA_RESULT_VALUES = ("passed", "failed", "blocked")
REPAIR_REQUEST_STATUSES = ("proposed", "created", "in_progress", "completed", "cancelled")
OPEN_REPAIR_REQUEST_STATUSES = ("proposed", "created", "in_progress")


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
    source_work_order_id: str | None = None
    qa_result_id: str | None = None
    repair_request_id: str | None = None
    iteration_number: int | None = None
    work_order_type: str | None = None
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
    repair_request_id: str | None = None
    qa_result_id: str | None = None
    developer_result_id: str | None = None
    developer_result_summary: str | None = None
    iteration_number: int | None = None
    handoff_purpose: str | None = None
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
    repair_request_id: str | None = None
    source_qa_result_id: str | None = None
    iteration_number: int | None = None


class RepairRequestCreate(BaseModel):
    summary: str
    repair_instructions: str
    requested_by: str = "operator"
    assigned_agent_id: str = "developer_codex"


class RepairRequestDecision(BaseModel):
    decision_reason: str = ""
    decided_by: str = "operator"


class DeveloperResultCreate(BaseModel):
    result_type: str = "implementation"
    summary: str
    changed_paths: Any = Field(default_factory=list)
    notes: str = ""
    agent_id: str = "developer_codex"
    evidence_refs: list[str] = Field(default_factory=list)


class StatusUpdateRequest(BaseModel):
    status: str
    reason: str = ""
    requested_by: str = "operator"


class PolicySettingsUpdate(BaseModel):
    qa_handoff_policy_mode: Any | None = None
    require_developer_result_for_qa: Any | None = None
    require_developer_result_for_repair_qa: Any | None = None
    allow_operator_override: Any | None = None
    updated_by: str | None = None


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
        self.repair_requests = self._load_collection("repair_requests", [])
        self.developer_results = self._load_collection("developer_results", [])
        self.policy_settings = self._load_policy_settings()

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

    def _load_policy_settings(self) -> dict[str, Any]:
        settings = self._load_collection("policy_settings", DEFAULT_POLICY_SETTINGS)
        return self._normalize_policy_settings(settings)

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
        open_repair_requests_count = sum(
            1
            for repair_request in self.repair_requests
            if repair_request.get("status") in OPEN_REPAIR_REQUEST_STATUSES
        )
        completed_repair_requests_count = sum(
            1 for repair_request in self.repair_requests if repair_request.get("status") == "completed"
        )
        workflow_iterations = self.workflow_iterations()
        repair_qa_handoffs_count = sum(
            1 for handoff in self.handoffs if handoff.get("handoff_purpose") == "repair_qa"
        )
        repair_qa_results_count = sum(
            1
            for qa_result in self.qa_results
            if qa_result.get("repair_request_id") or qa_result.get("source_qa_result_id")
        )
        submitted_developer_results = [
            result for result in self.developer_results if result.get("status") == "submitted"
        ]
        work_orders_with_developer_results_count = len(
            {
                result.get("work_order_id")
                for result in submitted_developer_results
                if result.get("work_order_id")
            }
        )
        readiness_summaries = [
            self._build_qa_readiness(
                work_order_id=str(work_order.get("id") or ""),
                work_order=work_order,
                card_id=str(work_order.get("card_id") or ""),
                handoff_context=(
                    "repair_qa"
                    if self._infer_work_order_type(work_order) == "repair"
                    else "initial_qa"
                ),
                repair_request=(
                    self._find_repair_request(str(work_order.get("repair_request_id")))
                    if work_order.get("repair_request_id")
                    else None
                ),
                repair_request_id=work_order.get("repair_request_id"),
            )
            for work_order in self.work_orders
        ]
        readiness_warnings_count = sum(
            len(readiness.get("warnings", [])) for readiness in readiness_summaries
        )
        readiness_blockers_count = sum(
            len(readiness.get("blockers", [])) for readiness in readiness_summaries
        )
        policy_settings = self.get_policy_settings()

        return {
            **self.status_seed,
            "repo": self.status_seed.get("repo", "RodneyMuniz/AIOffice_V2"),
            "branch": self.status_seed.get("branch", APP_BRANCH),
            "qa_handoff_policy_mode": policy_settings["qa_handoff_policy_mode"],
            "qa_policy_enforced": policy_settings["qa_handoff_policy_mode"] == "enforced",
            "require_developer_result_for_qa": policy_settings["require_developer_result_for_qa"],
            "require_developer_result_for_repair_qa": policy_settings[
                "require_developer_result_for_repair_qa"
            ],
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
            "repair_requests_count": len(self.repair_requests),
            "open_repair_requests_count": open_repair_requests_count,
            "completed_repair_requests_count": completed_repair_requests_count,
            "workflow_iterations_count": len(workflow_iterations),
            "repair_qa_handoffs_count": repair_qa_handoffs_count,
            "repair_qa_results_count": repair_qa_results_count,
            "developer_results_count": len(self.developer_results),
            "submitted_developer_results_count": len(submitted_developer_results),
            "work_orders_with_developer_results_count": work_orders_with_developer_results_count,
            "readiness_warnings_count": readiness_warnings_count,
            "readiness_blockers_count": readiness_blockers_count,
            "events_count": len(self.events),
            "evidence_count": len(self.evidence),
            "allowed_card_statuses": list(CARD_STATUSES),
            "allowed_work_order_statuses": list(WORK_ORDER_STATUSES),
        }

    def get_policy_settings(self) -> dict[str, Any]:
        return dict(self.policy_settings)

    def update_policy_settings(self, payload: PolicySettingsUpdate) -> dict[str, Any]:
        update_data = _model_to_dict(payload)
        next_settings = dict(self.policy_settings)

        if "qa_handoff_policy_mode" in update_data:
            mode = str(update_data["qa_handoff_policy_mode"]).strip().lower()
            if mode not in QA_HANDOFF_POLICY_MODES:
                allowed = ", ".join(QA_HANDOFF_POLICY_MODES)
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid QA handoff policy mode: {mode}. Allowed modes: {allowed}.",
                )
            next_settings["qa_handoff_policy_mode"] = mode

        for field_name in (
            "require_developer_result_for_qa",
            "require_developer_result_for_repair_qa",
            "allow_operator_override",
        ):
            if field_name not in update_data:
                continue
            value = update_data[field_name]
            if not isinstance(value, bool):
                raise HTTPException(status_code=400, detail=f"{field_name} must be a boolean.")
            next_settings[field_name] = value

        updated_by = str(update_data.get("updated_by") or "operator").strip() or "operator"
        next_settings["updated_by"] = updated_by
        next_settings["updated_at"] = _utc_now()
        self.policy_settings = self._normalize_policy_settings(next_settings)

        summary = (
            "QA handoff policy settings updated: "
            f"mode={self.policy_settings['qa_handoff_policy_mode']}, "
            f"require_developer_result_for_qa={self.policy_settings['require_developer_result_for_qa']}, "
            "require_developer_result_for_repair_qa="
            f"{self.policy_settings['require_developer_result_for_repair_qa']}, "
            f"allow_operator_override={self.policy_settings['allow_operator_override']}."
        )
        related_card_id = self._policy_related_card_id()
        self._append_event(
            event_type="policy_settings_updated",
            summary=summary,
            actor_agent_id=updated_by,
            related_card_id=related_card_id,
        )
        self._append_evidence(
            title="QA handoff policy settings updated",
            kind="policy_settings",
            summary=summary,
            path="runtime/state/policy_settings.json",
            related_card_id=related_card_id,
        )

        self._save_collection("policy_settings", self.policy_settings)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return self.get_policy_settings()

    def work_order_qa_readiness(self, work_order_id: str) -> dict[str, Any]:
        work_order = self._find_work_order(work_order_id)
        if work_order is None:
            raise HTTPException(status_code=404, detail=f"Unknown work-order id: {work_order_id}")

        repair_request_id = work_order.get("repair_request_id")
        repair_request = (
            self._find_repair_request(str(repair_request_id)) if repair_request_id else None
        )
        handoff_context = (
            "repair_qa"
            if self._infer_work_order_type(work_order) == "repair"
            else "initial_qa"
        )
        return self._build_qa_readiness(
            work_order_id=work_order_id,
            work_order=work_order,
            card_id=str(work_order.get("card_id") or ""),
            handoff_context=handoff_context,
            repair_request=repair_request,
            repair_request_id=repair_request_id,
        )

    def repair_request_qa_readiness(self, repair_request_id: str) -> dict[str, Any]:
        repair_request = self._find_repair_request(repair_request_id)
        if repair_request is None:
            raise HTTPException(
                status_code=404,
                detail=f"Unknown repair request id: {repair_request_id}",
            )

        repair_work_order_id = str(repair_request.get("repair_work_order_id") or "")
        repair_work_order = (
            self._find_work_order(repair_work_order_id) if repair_work_order_id else None
        )
        return self._build_qa_readiness(
            work_order_id=repair_work_order_id,
            work_order=repair_work_order,
            card_id=str((repair_work_order or repair_request).get("card_id") or ""),
            handoff_context="repair_qa",
            repair_request=repair_request,
            repair_request_id=repair_request_id,
        )

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
        work_order_type = (
            str(
                work_order_data.pop("work_order_type", None)
                or (
                    "repair"
                    if work_order_data.get("repair_request_id")
                    or work_order_data.get("source_work_order_id")
                    else "original"
                )
            )
            .strip()
            .lower()
        )
        _validate_status(work_order_type, WORK_ORDER_TYPES, "work-order type")
        iteration_number = _coerce_iteration_number(
            work_order_data.pop("iteration_number", None),
            2 if work_order_type == "repair" else 1,
        )
        work_order = {
            **work_order_data,
            "id": work_order_data.get("id") or self._next_id(self.work_orders, "R19-WO"),
            "summary": summary,
            "status": status,
            "approval_required": bool(approval_required),
            "work_order_type": work_order_type,
            "iteration_number": iteration_number,
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

    def create_developer_result(
        self, work_order_id: str, payload: DeveloperResultCreate
    ) -> dict[str, Any]:
        work_order = self._find_work_order(work_order_id)
        if work_order is None:
            raise HTTPException(status_code=404, detail=f"Unknown work-order id: {work_order_id}")

        result_data = _model_to_dict(payload)
        agent_id = str(result_data.get("agent_id") or "developer_codex").strip() or "developer_codex"
        if self._find_agent(agent_id) is None:
            raise HTTPException(status_code=400, detail=f"Invalid agent_id: {agent_id}.")

        result_type = str(result_data.get("result_type") or "implementation").strip().lower()
        _validate_status(result_type, DEVELOPER_RESULT_TYPES, "developer result type")
        changed_paths = _normalize_string_list(result_data.get("changed_paths", []), "changed_paths")
        summary = str(result_data.get("summary") or "").strip()
        notes = str(result_data.get("notes") or "").strip()
        if not summary:
            raise HTTPException(status_code=400, detail="Developer result summary is required.")

        existing_submitted_result = self._latest_submitted_developer_result_for_work_order(work_order_id)
        if existing_submitted_result:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Submitted developer result {existing_submitted_result['id']} already exists "
                    f"for work order {work_order_id}; supersede it before recording another."
                ),
            )

        now = _utc_now()
        result_id = self._next_id(self.developer_results, "R19-DEV-RESULT")
        evidence_refs = [
            *result_data.get("evidence_refs", []),
            f"runtime/state/work_orders.json#{work_order_id}",
            f"runtime/state/developer_results.json#{result_id}",
        ]
        developer_result = {
            "id": result_id,
            "card_id": work_order["card_id"],
            "work_order_id": work_order_id,
            "agent_id": agent_id,
            "result_type": result_type,
            "status": "submitted",
            "summary": summary,
            "changed_paths": changed_paths,
            "notes": notes,
            "created_at": now,
            "updated_at": now,
            "evidence_refs": evidence_refs,
        }

        self.developer_results.append(developer_result)
        developer_result_ids = list(work_order.get("developer_result_ids", []))
        developer_result_ids.append(result_id)
        work_order["developer_result_ids"] = developer_result_ids
        work_order["latest_developer_result_id"] = result_id
        work_order["updated_at"] = now

        self._append_event(
            event_type="developer_result_recorded",
            summary=(
                f"Developer/Codex result {result_id} recorded for work order "
                f"{work_order_id} as {result_type}."
            ),
            actor_agent_id=agent_id,
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_developer_result_id=result_id,
        )
        self._append_evidence(
            title=f"Developer result {result_id} recorded",
            kind="developer_result",
            summary=summary,
            path=f"runtime/state/developer_results.json#{result_id}",
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_developer_result_id=result_id,
        )

        if work_order.get("status") in {"draft", "running", "approved"}:
            self._mark_work_order_ready_from_developer_result(work_order, developer_result)

        self._save_collection("developer_results", self.developer_results)
        self._save_collection("work_orders", self.work_orders)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return developer_result

    def supersede_developer_result(self, developer_result_id: str) -> dict[str, Any]:
        developer_result = self._find_developer_result(developer_result_id)
        if developer_result is None:
            raise HTTPException(
                status_code=404,
                detail=f"Unknown developer result id: {developer_result_id}",
            )
        if developer_result.get("status") == "superseded":
            raise HTTPException(
                status_code=400,
                detail=f"Developer result {developer_result_id} is already superseded.",
            )

        developer_result["status"] = "superseded"
        developer_result["updated_at"] = _utc_now()
        work_order_id = str(developer_result["work_order_id"])
        work_order = self._find_work_order(work_order_id)
        latest_submitted_result = self._latest_submitted_developer_result_for_work_order(work_order_id)
        if work_order:
            if latest_submitted_result:
                work_order["latest_developer_result_id"] = latest_submitted_result["id"]
            else:
                work_order.pop("latest_developer_result_id", None)
            work_order["updated_at"] = developer_result["updated_at"]

        self._append_event(
            event_type="developer_result_superseded",
            summary=f"Developer/Codex result {developer_result_id} was superseded.",
            actor_agent_id=developer_result.get("agent_id", "operator"),
            related_card_id=developer_result["card_id"],
            related_work_order_id=work_order_id,
            related_developer_result_id=developer_result_id,
        )
        self._append_evidence(
            title=f"Developer result {developer_result_id} superseded",
            kind="developer_result",
            summary=f"Developer/Codex result {developer_result_id} marked superseded.",
            path=f"runtime/state/developer_results.json#{developer_result_id}",
            related_card_id=developer_result["card_id"],
            related_work_order_id=work_order_id,
            related_developer_result_id=developer_result_id,
        )

        self._save_collection("developer_results", self.developer_results)
        if work_order:
            self._save_collection("work_orders", self.work_orders)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return developer_result

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

        repair_request_id = handoff_data.get("repair_request_id")
        qa_result_id = handoff_data.get("qa_result_id")
        handoff_purpose = (
            str(
                handoff_data.get("handoff_purpose")
                or ("repair_qa" if repair_request_id else "initial_qa")
            )
            .strip()
            .lower()
        )
        _validate_status(handoff_purpose, HANDOFF_PURPOSES, "handoff purpose")
        if handoff_purpose == "repair_qa" and not repair_request_id:
            raise HTTPException(
                status_code=400,
                detail="repair_qa handoffs require repair_request_id.",
            )
        if handoff_purpose == "repair_qa" and not qa_result_id:
            raise HTTPException(
                status_code=400,
                detail="repair_qa handoffs require qa_result_id linkage.",
            )
        if repair_request_id and self._find_repair_request(str(repair_request_id)) is None:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid repair_request_id: {repair_request_id}.",
            )
        if qa_result_id and self._find_qa_result(str(qa_result_id)) is None:
            raise HTTPException(status_code=400, detail=f"Invalid qa_result_id: {qa_result_id}.")
        iteration_number = _coerce_iteration_number(
            handoff_data.get("iteration_number"),
            self._infer_work_order_iteration(work_order),
        )
        developer_result = None
        developer_result_id = handoff_data.get("developer_result_id")
        if developer_result_id:
            developer_result = self._find_developer_result(str(developer_result_id))
            if developer_result is None:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid developer_result_id: {developer_result_id}.",
                )
            if developer_result.get("work_order_id") != work_order_id:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"developer_result_id {developer_result_id} does not belong to "
                        f"work_order_id {work_order_id}."
                    ),
                )
            if developer_result.get("status") != "submitted":
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Developer result {developer_result_id} is "
                        f"{developer_result.get('status')}; QA handoffs require submitted results."
                    ),
                )
        else:
            developer_result = self._latest_submitted_developer_result_for_work_order(work_order_id)

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
        if developer_result:
            developer_result_id = str(developer_result["id"])
            developer_result_summary = (
                str(handoff_data.get("developer_result_summary") or "").strip()
                or str(developer_result.get("summary") or "").strip()
            )
            payload_summary = (
                f"{payload_summary} Developer result {developer_result_id}: "
                f"{developer_result_summary}"
            )
            validation_summary = (
                f"{validation_summary} Developer result {developer_result_id} was attached "
                "to this QA handoff."
            )
        else:
            developer_result_id = None
            developer_result_summary = None
            validation_summary = (
                f"{validation_summary} No developer result recorded before QA handoff."
            )
        handoff_id = handoff_data.get("id") or self._next_id(self.handoffs, "R19-HANDOFF")
        evidence_refs = [
            *handoff_data.get("evidence_refs", []),
            f"runtime/state/handoffs.json#{handoff_id}",
        ]
        if developer_result_id:
            evidence_refs.append(f"runtime/state/developer_results.json#{developer_result_id}")
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
            "handoff_purpose": handoff_purpose,
            "iteration_number": iteration_number,
            "evidence_refs": evidence_refs,
        }
        if developer_result_id:
            handoff["developer_result_id"] = developer_result_id
            handoff["developer_result_summary"] = developer_result_summary or ""
        if repair_request_id:
            handoff["repair_request_id"] = str(repair_request_id)
        if qa_result_id:
            handoff["qa_result_id"] = str(qa_result_id)

        self.handoffs.append(handoff)
        is_repair_qa = handoff_purpose == "repair_qa"
        self._append_event(
            event_type="repair_handoff_created" if is_repair_qa else "handoff_created",
            summary=(
                f"Repair QA handoff {handoff_id} proposed for iteration {iteration_number}."
                if is_repair_qa
                else f"Handoff {handoff_id} proposed from {source_agent_id} to {target_agent_id}."
            ),
            actor_agent_id=source_agent_id,
            related_card_id=card_id,
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
            related_repair_request_id=str(repair_request_id) if repair_request_id else None,
        )
        self._append_evidence(
            title=f"{'Repair QA handoff' if is_repair_qa else 'Handoff'} {handoff_id} created",
            kind="repair_handoff" if is_repair_qa else "handoff_record",
            summary=validation_summary,
            path=f"runtime/state/handoffs.json#{handoff_id}",
            related_card_id=card_id,
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
            related_repair_request_id=str(repair_request_id) if repair_request_id else None,
        )
        if is_repair_qa:
            self._append_evidence(
                title=f"Workflow iteration {iteration_number} repair QA handoff",
                kind="workflow_iteration",
                summary=(
                    f"Repair work order {work_order_id} entered QA iteration "
                    f"{iteration_number} through handoff {handoff_id}."
                ),
                path=f"runtime/state/handoffs.json#{handoff_id}",
                related_card_id=card_id,
                related_work_order_id=work_order_id,
                related_handoff_id=handoff_id,
                related_repair_request_id=str(repair_request_id) if repair_request_id else None,
            )
        self._save_collection("handoffs", self.handoffs)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return handoff

    def handoff_work_order_to_qa(self, work_order_id: str) -> dict[str, Any]:
        work_order = self._find_work_order(work_order_id)
        if work_order is None:
            raise HTTPException(status_code=404, detail=f"Unknown work-order id: {work_order_id}")

        readiness = self.work_order_qa_readiness(work_order_id)
        self._raise_for_readiness_blockers(readiness)

        if self._infer_work_order_type(work_order) == "repair":
            repair_request_id = work_order.get("repair_request_id")
            if not repair_request_id:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Repair work-order {work_order_id} cannot be handed to QA "
                        "without repair_request_id linkage."
                    ),
                )
            return self.handoff_repair_request_to_qa(str(repair_request_id))

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
                handoff_purpose="initial_qa",
                iteration_number=self._infer_work_order_iteration(work_order),
                payload_summary=(
                    f"Work order '{work_order['title']}' is currently {work_order['status']} "
                    f"and assigned to {work_order.get('assigned_agent_id', 'unknown')}."
                ),
                validation_summary=(
                    "API dry-run handoff only: source/target agents, card, and work-order linkage "
                    "were validated; no AI or autonomous agent was invoked."
                    f"{self._readiness_validation_summary(readiness)}"
                ),
                evidence_refs=evidence_refs,
            )
        )

    def handoff_repair_request_to_qa(self, repair_request_id: str) -> dict[str, Any]:
        repair_request = self._find_repair_request(repair_request_id)
        if repair_request is None:
            raise HTTPException(
                status_code=404,
                detail=f"Unknown repair request id: {repair_request_id}",
            )

        readiness = self.repair_request_qa_readiness(repair_request_id)
        self._raise_for_readiness_blockers(readiness)

        repair_status = repair_request.get("status")
        if repair_status not in REPAIR_QA_HANDOFF_REPAIR_STATUSES:
            allowed = ", ".join(REPAIR_QA_HANDOFF_REPAIR_STATUSES)
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair request {repair_request_id} is {repair_status}; "
                    f"repair QA handoffs require status {allowed}."
                ),
            )

        repair_work_order_id = repair_request.get("repair_work_order_id")
        if not repair_work_order_id:
            raise HTTPException(
                status_code=400,
                detail=f"Repair request {repair_request_id} does not have repair_work_order_id.",
            )

        repair_work_order = self._find_work_order(str(repair_work_order_id))
        if repair_work_order is None:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair request {repair_request_id} references missing repair work-order "
                    f"{repair_work_order_id}."
                ),
            )
        if repair_work_order.get("card_id") != repair_request.get("card_id"):
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair work-order {repair_work_order_id} card_id does not match "
                    f"repair request {repair_request_id}."
                ),
            )

        repair_work_order_status = repair_work_order.get("status")
        if repair_work_order_status not in REPAIR_QA_HANDOFF_WORK_ORDER_STATUSES:
            allowed = ", ".join(REPAIR_QA_HANDOFF_WORK_ORDER_STATUSES)
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair work-order {repair_work_order_id} is {repair_work_order_status}; "
                    f"repair QA handoffs require status {allowed}."
                ),
            )

        source_qa_result_id = repair_request.get("qa_result_id")
        if not source_qa_result_id or self._find_qa_result(str(source_qa_result_id)) is None:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair request {repair_request_id} must link to an existing failed or "
                    "blocked QA result before it can be handed to QA."
                ),
            )

        active_handoff = self._find_active_repair_qa_handoff(
            repair_request_id,
            str(repair_work_order_id),
        )
        if active_handoff:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair QA handoff {active_handoff['id']} already exists for "
                    f"repair request {repair_request_id} with status {active_handoff['status']}."
                ),
            )

        source_qa_result = self._find_qa_result(str(source_qa_result_id))
        iteration_number = self._repair_qa_iteration_number(
            repair_request,
            repair_work_order,
            source_qa_result,
        )
        evidence_refs = [
            *repair_request.get("evidence_refs", []),
            *repair_work_order.get("evidence_refs", []),
            f"runtime/state/repair_requests.json#{repair_request_id}",
            f"runtime/state/work_orders.json#{repair_work_order_id}",
        ]
        return self.create_handoff(
            HandoffCreate(
                source_agent_id="developer_codex",
                target_agent_id="qa_test",
                source_role="Developer/Codex",
                target_role="QA/Test",
                card_id=repair_work_order["card_id"],
                work_order_id=str(repair_work_order_id),
                title=f"Repair QA handoff for {repair_work_order_id}",
                summary=(
                    "Developer/Codex requests QA/Test validation for repair "
                    f"iteration {iteration_number}."
                ),
                status="proposed",
                payload_summary=(
                    f"Repair work order '{repair_work_order['title']}' is currently "
                    f"{repair_work_order_status} and linked to repair request {repair_request_id}."
                ),
                validation_summary=(
                    f"Repair QA iteration {iteration_number}: repair request, source QA result, "
                    "card, and repair work-order linkage were validated; no AI or autonomous "
                    "agent was invoked."
                    f"{self._readiness_validation_summary(readiness)}"
                ),
                repair_request_id=repair_request_id,
                qa_result_id=str(source_qa_result_id),
                iteration_number=iteration_number,
                handoff_purpose="repair_qa",
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
        work_order = self._find_work_order(handoff["work_order_id"])
        is_repair_qa = handoff.get("handoff_purpose") == "repair_qa"
        repair_request_id = handoff.get("repair_request_id") if is_repair_qa else None
        source_qa_result_id = handoff.get("qa_result_id") if is_repair_qa else None
        iteration_number = _coerce_iteration_number(
            result_data.get("iteration_number") or handoff.get("iteration_number"),
            self._infer_work_order_iteration(work_order) if work_order else 1,
        )
        now = _utc_now()
        qa_result_id = self._next_id(self.qa_results, "R19-QA-RESULT")
        evidence_refs = [
            f"runtime/state/handoffs.json#{handoff_id}",
            f"runtime/state/qa_results.json#{qa_result_id}",
        ]
        if repair_request_id:
            evidence_refs.append(f"runtime/state/repair_requests.json#{repair_request_id}")
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
            "iteration_number": iteration_number,
            "created_at": now,
            "updated_at": now,
            "evidence_refs": evidence_refs,
        }
        if repair_request_id:
            qa_result["repair_request_id"] = repair_request_id
        if source_qa_result_id:
            qa_result["source_qa_result_id"] = source_qa_result_id

        self.qa_results.append(qa_result)
        self._append_event(
            event_type="qa_result_recorded",
            summary=f"QA result {qa_result_id} recorded as {result} for handoff {handoff_id}.",
            actor_agent_id=qa_agent_id,
            related_card_id=handoff["card_id"],
            related_work_order_id=handoff["work_order_id"],
            related_handoff_id=handoff_id,
            related_repair_request_id=repair_request_id,
        )
        self._append_evidence(
            title=f"QA result {qa_result_id} recorded",
            kind="qa_result",
            summary=qa_result["summary"] or f"QA result recorded as {result}.",
            path=f"runtime/state/qa_results.json#{qa_result_id}",
            related_card_id=handoff["card_id"],
            related_work_order_id=handoff["work_order_id"],
            related_handoff_id=handoff_id,
            related_repair_request_id=repair_request_id,
        )
        if is_repair_qa:
            self._append_event(
                event_type="repair_qa_result_recorded",
                summary=(
                    f"Repair QA result {qa_result_id} recorded as {result} for "
                    f"iteration {iteration_number}."
                ),
                actor_agent_id=qa_agent_id,
                related_card_id=handoff["card_id"],
                related_work_order_id=handoff["work_order_id"],
                related_handoff_id=handoff_id,
                related_repair_request_id=repair_request_id,
            )
            self._append_event(
                event_type=f"repair_iteration_{result}",
                summary=(
                    f"Repair iteration {iteration_number} for work order "
                    f"{handoff['work_order_id']} recorded {result}."
                ),
                actor_agent_id=qa_agent_id,
                related_card_id=handoff["card_id"],
                related_work_order_id=handoff["work_order_id"],
                related_handoff_id=handoff_id,
                related_repair_request_id=repair_request_id,
            )
            self._append_evidence(
                title=f"Repair QA result {qa_result_id} recorded",
                kind="repair_qa_result",
                summary=qa_result["summary"] or f"Repair QA result recorded as {result}.",
                path=f"runtime/state/qa_results.json#{qa_result_id}",
                related_card_id=handoff["card_id"],
                related_work_order_id=handoff["work_order_id"],
                related_handoff_id=handoff_id,
                related_repair_request_id=repair_request_id,
            )
            self._append_evidence(
                title=f"Workflow iteration {iteration_number} repair QA result",
                kind="workflow_iteration",
                summary=(
                    f"Repair iteration {iteration_number} recorded {result} "
                    f"for repair work order {handoff['work_order_id']}."
                ),
                path=f"runtime/state/qa_results.json#{qa_result_id}",
                related_card_id=handoff["card_id"],
                related_work_order_id=handoff["work_order_id"],
                related_handoff_id=handoff_id,
                related_repair_request_id=repair_request_id,
            )

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

    def create_repair_request(
        self, qa_result_id: str, payload: RepairRequestCreate
    ) -> dict[str, Any]:
        qa_result = self._find_qa_result(qa_result_id)
        if qa_result is None:
            raise HTTPException(status_code=404, detail=f"Unknown QA result id: {qa_result_id}")

        result = qa_result.get("result")
        if result not in {"failed", "blocked"}:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"QA result {qa_result_id} is {result}; repair requests can only "
                    "be created for failed or blocked QA results."
                ),
            )

        existing_repair_request = self._find_repair_request_for_qa_result(qa_result_id)
        if existing_repair_request:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair request {existing_repair_request['id']} already exists for "
                    f"QA result {qa_result_id}."
                ),
            )

        source_work_order_id = qa_result["work_order_id"]
        source_work_order = self._find_work_order(source_work_order_id)
        if source_work_order is None:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"QA result {qa_result_id} references missing source work-order "
                    f"{source_work_order_id}."
                ),
            )

        request_data = _model_to_dict(payload)
        requested_by = str(request_data.get("requested_by") or "operator").strip() or "operator"
        assigned_agent_id = (
            str(request_data.get("assigned_agent_id") or "developer_codex").strip()
            or "developer_codex"
        )
        summary = str(request_data.get("summary") or "").strip()
        repair_instructions = str(request_data.get("repair_instructions") or "").strip()
        if not summary:
            raise HTTPException(status_code=400, detail="Repair request summary is required.")
        if not repair_instructions:
            raise HTTPException(status_code=400, detail="Repair instructions are required.")

        now = _utc_now()
        repair_request_id = self._next_id(self.repair_requests, "R19-REPAIR")
        repair_work_order_id = self._next_id(self.work_orders, "R19-WO")
        repair_iteration_number = _coerce_iteration_number(
            qa_result.get("iteration_number"),
            self._infer_work_order_iteration(source_work_order),
        ) + 1
        evidence_refs = [
            f"runtime/state/qa_results.json#{qa_result_id}",
            f"runtime/state/handoffs.json#{qa_result['handoff_id']}",
            f"runtime/state/work_orders.json#{source_work_order_id}",
            f"runtime/state/repair_requests.json#{repair_request_id}",
            f"runtime/state/work_orders.json#{repair_work_order_id}",
        ]

        repair_work_order = {
            "id": repair_work_order_id,
            "card_id": qa_result["card_id"],
            "title": f"Repair: {source_work_order['title']}",
            "summary": repair_instructions,
            "status": "ready",
            "requested_by_agent_id": requested_by,
            "assigned_agent_id": assigned_agent_id,
            "approval_required": False,
            "handoff_target_agent_id": "qa_test",
            "source_work_order_id": source_work_order_id,
            "qa_result_id": qa_result_id,
            "repair_request_id": repair_request_id,
            "iteration_number": repair_iteration_number,
            "work_order_type": "repair",
            "evidence_refs": evidence_refs,
            "created_at": now,
            "updated_at": now,
        }
        repair_request = {
            "id": repair_request_id,
            "qa_result_id": qa_result_id,
            "handoff_id": qa_result["handoff_id"],
            "card_id": qa_result["card_id"],
            "source_work_order_id": source_work_order_id,
            "repair_work_order_id": repair_work_order_id,
            "requested_by": requested_by,
            "assigned_agent_id": assigned_agent_id,
            "status": "created",
            "summary": summary,
            "repair_instructions": repair_instructions,
            "created_at": now,
            "updated_at": now,
            "completed_at": None,
            "evidence_refs": evidence_refs,
        }

        self.work_orders.append(repair_work_order)
        self.repair_requests.append(repair_request)
        self._append_event(
            event_type="repair_request_created",
            summary=f"Repair request {repair_request_id} created for QA result {qa_result_id}.",
            actor_agent_id=requested_by,
            related_card_id=qa_result["card_id"],
            related_work_order_id=source_work_order_id,
            related_handoff_id=qa_result["handoff_id"],
            related_repair_request_id=repair_request_id,
        )
        self._append_event(
            event_type="repair_work_order_created",
            summary=(
                f"Repair work order {repair_work_order_id} created for repair request "
                f"{repair_request_id} and assigned to {assigned_agent_id}."
            ),
            actor_agent_id=requested_by,
            related_card_id=qa_result["card_id"],
            related_work_order_id=repair_work_order_id,
            related_handoff_id=qa_result["handoff_id"],
            related_repair_request_id=repair_request_id,
        )
        self._append_evidence(
            title=f"Repair request {repair_request_id} created",
            kind="repair_request",
            summary=summary,
            path=f"runtime/state/repair_requests.json#{repair_request_id}",
            related_card_id=qa_result["card_id"],
            related_work_order_id=source_work_order_id,
            related_handoff_id=qa_result["handoff_id"],
            related_repair_request_id=repair_request_id,
        )
        self._append_evidence(
            title=f"Repair work order {repair_work_order_id} created",
            kind="repair_work_order",
            summary=(
                f"Ready repair work order linked to source work order {source_work_order_id} "
                f"and QA result {qa_result_id}."
            ),
            path=f"runtime/state/work_orders.json#{repair_work_order_id}",
            related_card_id=qa_result["card_id"],
            related_work_order_id=repair_work_order_id,
            related_handoff_id=qa_result["handoff_id"],
            related_repair_request_id=repair_request_id,
        )

        self._save_collection("work_orders", self.work_orders)
        self._save_collection("repair_requests", self.repair_requests)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return repair_request

    def complete_repair_request(
        self, repair_request_id: str, decision: RepairRequestDecision
    ) -> dict[str, Any]:
        return self._decide_repair_request(repair_request_id, "completed", decision)

    def cancel_repair_request(
        self, repair_request_id: str, decision: RepairRequestDecision
    ) -> dict[str, Any]:
        return self._decide_repair_request(repair_request_id, "cancelled", decision)

    def workflow_iterations(self) -> list[dict[str, Any]]:
        qa_result_by_handoff_id = {
            qa_result.get("handoff_id"): qa_result for qa_result in self.qa_results
        }
        qa_results_by_work_order_id: dict[str, list[dict[str, Any]]] = {}
        for qa_result in self.qa_results:
            qa_results_by_work_order_id.setdefault(str(qa_result.get("work_order_id")), []).append(qa_result)

        items: list[dict[str, Any]] = []
        for work_order in self.work_orders:
            work_order_id = str(work_order.get("id"))
            handoff = self._latest_handoff_for_work_order(work_order_id)
            qa_result = qa_result_by_handoff_id.get(handoff.get("id")) if handoff else None
            if qa_result is None:
                qa_result = self._latest_record(qa_results_by_work_order_id.get(work_order_id, []))

            work_order_type = self._infer_work_order_type(work_order)
            iteration_number = self._infer_work_order_iteration(work_order)
            repair_request_id = (
                work_order.get("repair_request_id")
                or (handoff or {}).get("repair_request_id")
                or (qa_result or {}).get("repair_request_id")
            )
            source_qa_result_id = (
                (qa_result or {}).get("source_qa_result_id")
                or (handoff or {}).get("qa_result_id")
                or work_order.get("qa_result_id")
            )
            latest_result = qa_result.get("result") if qa_result else None
            handoff_status = handoff.get("status") if handoff else None
            summary_parts = [f"work order {work_order.get('status', 'unknown')}"]
            if handoff_status:
                summary_parts.append(f"handoff {handoff_status}")
            if latest_result:
                summary_parts.append(f"QA {latest_result}")

            updated_candidates = [
                work_order.get("updated_at"),
                work_order.get("created_at"),
                (handoff or {}).get("updated_at"),
                (handoff or {}).get("created_at"),
                (qa_result or {}).get("updated_at"),
                (qa_result or {}).get("created_at"),
            ]
            item = {
                "card_id": work_order.get("card_id"),
                "original_work_order_id": self._resolve_original_work_order_id(work_order),
                "work_order_id": work_order_id,
                "work_order_type": work_order_type,
                "repair_request_id": repair_request_id,
                "handoff_id": handoff.get("id") if handoff else None,
                "qa_result_id": qa_result.get("id") if qa_result else None,
                "source_qa_result_id": source_qa_result_id,
                "iteration_number": iteration_number,
                "status_summary": "; ".join(summary_parts),
                "latest_result": latest_result,
                "created_at": work_order.get("created_at"),
                "updated_at": max([value for value in updated_candidates if value] or [""]),
            }
            items.append(item)

        return sorted(
            items,
            key=lambda item: (
                str(item.get("card_id") or ""),
                str(item.get("original_work_order_id") or ""),
                int(item.get("iteration_number") or 1),
                str(item.get("created_at") or ""),
            ),
        )

    def _build_qa_readiness(
        self,
        work_order_id: str,
        work_order: dict[str, Any] | None,
        card_id: str,
        handoff_context: Literal["initial_qa", "repair_qa"],
        repair_request: dict[str, Any] | None = None,
        repair_request_id: str | None = None,
    ) -> dict[str, Any]:
        checks: list[dict[str, str]] = []
        policy_settings = self.get_policy_settings()
        policy_mode = policy_settings["qa_handoff_policy_mode"]
        policy_enforced = policy_mode == "enforced"
        require_developer_result = (
            policy_settings["require_developer_result_for_repair_qa"]
            if handoff_context == "repair_qa"
            else policy_settings["require_developer_result_for_qa"]
        )
        missing_developer_result_promoted = False

        def add_check(
            check_id: str,
            label: str,
            status: Literal["passed", "warning", "blocked"],
            detail: str,
        ) -> None:
            checks.append(
                {
                    "id": check_id,
                    "label": label,
                    "status": status,
                    "detail": detail,
                }
            )

        if work_order:
            add_check(
                "work_order_exists",
                "Work order exists",
                "passed",
                f"Work order {work_order_id} exists.",
            )
        else:
            add_check(
                "work_order_exists",
                "Work order exists",
                "blocked",
                (
                    f"Repair request {repair_request_id} references missing repair work order "
                    f"{work_order_id or 'none'}."
                    if repair_request_id
                    else f"Work order {work_order_id or 'unknown'} is missing."
                ),
            )

        card = self._find_card(card_id) if card_id else None
        if card:
            add_check(
                "card_exists",
                "Card exists",
                "passed",
                f"Card {card_id} exists.",
            )
        else:
            add_check(
                "card_exists",
                "Card exists",
                "blocked",
                f"Card {card_id or 'unknown'} is missing for this QA handoff.",
            )

        assigned_agent_id = str(
            (work_order or {}).get("assigned_agent_id")
            or (repair_request or {}).get("assigned_agent_id")
            or ""
        ).strip()
        if assigned_agent_id and self._find_agent(assigned_agent_id):
            add_check(
                "assigned_agent_exists",
                "Assigned agent exists",
                "passed",
                f"Assigned agent {assigned_agent_id} exists.",
            )
        else:
            add_check(
                "assigned_agent_exists",
                "Assigned agent exists",
                "blocked",
                (
                    f"Assigned agent {assigned_agent_id} is missing."
                    if assigned_agent_id
                    else "No assigned agent is recorded for this work order."
                ),
            )

        latest_developer_result = (
            self._latest_submitted_developer_result_for_work_order(work_order_id)
            if work_order
            else None
        )
        if latest_developer_result:
            add_check(
                "latest_developer_result_submitted",
                "Latest Developer/Codex result submitted",
                "passed",
                f"Submitted Developer/Codex result {latest_developer_result['id']} is available.",
            )
        else:
            missing_developer_result_promoted = policy_enforced and require_developer_result
            add_check(
                "latest_developer_result_submitted",
                "Latest Developer/Codex result submitted",
                "blocked" if missing_developer_result_promoted else "warning",
                (
                    "Developer/Codex result is required by current QA handoff policy."
                    if missing_developer_result_promoted
                    else "No submitted Developer/Codex result has been captured for this work order."
                ),
            )

        work_order_status = str((work_order or {}).get("status") or "")
        if work_order:
            status_check_status, status_check_detail = self._qa_handoff_status_check(
                work_order_status,
                handoff_context,
            )
            add_check(
                "work_order_status_suitable",
                "Work-order status is suitable for QA handoff",
                status_check_status,
                status_check_detail,
            )
        else:
            add_check(
                "work_order_status_suitable",
                "Work-order status is suitable for QA handoff",
                "blocked",
                "Cannot evaluate work-order status because the work order is missing.",
            )

        active_handoff = (
            self._find_active_qa_handoff_for_work_order(work_order_id, handoff_context)
            if work_order_id
            else None
        )
        if active_handoff:
            add_check(
                "no_active_qa_handoff",
                "No active QA handoff already exists",
                "blocked",
                (
                    f"Active {handoff_context} handoff {active_handoff['id']} already "
                    f"exists with status {active_handoff['status']}."
                ),
            )
        else:
            add_check(
                "no_active_qa_handoff",
                "No active QA handoff already exists",
                "passed",
                f"No active {handoff_context} handoff is open for this work order.",
            )

        if handoff_context == "repair_qa":
            if repair_request:
                add_check(
                    "repair_request_exists",
                    "Linked repair request exists",
                    "passed",
                    f"Repair request {repair_request['id']} exists.",
                )
            else:
                add_check(
                    "repair_request_exists",
                    "Linked repair request exists",
                    "blocked",
                    (
                        f"Repair request {repair_request_id} is missing."
                        if repair_request_id
                        else "Repair work orders require repair_request_id linkage."
                    ),
                )

            if repair_request and work_order:
                linked_work_order_id = str(repair_request.get("repair_work_order_id") or "")
                if linked_work_order_id == work_order_id:
                    add_check(
                        "repair_request_work_order_matches",
                        "Repair request points to this repair work order",
                        "passed",
                        f"Repair request {repair_request['id']} links repair work order {work_order_id}.",
                    )
                else:
                    add_check(
                        "repair_request_work_order_matches",
                        "Repair request points to this repair work order",
                        "blocked",
                        (
                            f"Repair request {repair_request['id']} points to repair work order "
                            f"{linked_work_order_id or 'none'}, not {work_order_id}."
                        ),
                    )
            elif repair_request:
                add_check(
                    "repair_request_work_order_matches",
                    "Repair request points to this repair work order",
                    "blocked",
                    (
                        f"Repair request {repair_request['id']} references missing repair work order "
                        f"{repair_request.get('repair_work_order_id') or 'none'}."
                    ),
                )

            if repair_request:
                repair_status = str(repair_request.get("status") or "")
                if repair_status in REPAIR_QA_HANDOFF_REPAIR_STATUSES:
                    add_check(
                        "repair_request_status_suitable",
                        "Repair request status is suitable for repair QA",
                        "passed",
                        f"Repair request {repair_request['id']} is {repair_status}.",
                    )
                else:
                    add_check(
                        "repair_request_status_suitable",
                        "Repair request status is suitable for repair QA",
                        "blocked",
                        (
                            f"Repair request {repair_request['id']} is {repair_status or 'unknown'}; "
                            "repair QA handoffs require created, in_progress, or completed."
                        ),
                    )

                source_qa_result_id = str(repair_request.get("qa_result_id") or "")
                if source_qa_result_id and self._find_qa_result(source_qa_result_id):
                    add_check(
                        "source_qa_result_exists",
                        "Source QA result exists",
                        "passed",
                        f"Source QA result {source_qa_result_id} exists.",
                    )
                else:
                    add_check(
                        "source_qa_result_exists",
                        "Source QA result exists",
                        "blocked",
                        (
                            f"Source QA result {source_qa_result_id or 'none'} is missing "
                            f"for repair request {repair_request['id']}."
                        ),
                    )

        warnings = [check["detail"] for check in checks if check["status"] == "warning"]
        blockers = [check["detail"] for check in checks if check["status"] == "blocked"]
        readiness_level = "blocked" if blockers else "warning" if warnings else "ready"

        readiness = {
            "work_order_id": work_order_id,
            "card_id": card_id,
            "ready_for_qa": readiness_level == "ready",
            "readiness_level": readiness_level,
            "policy_mode": policy_mode,
            "policy_enforced": policy_enforced,
            "advisory_warnings_promoted_to_blockers": missing_developer_result_promoted,
            "checks": checks,
            "warnings": warnings,
            "blockers": blockers,
            "latest_developer_result_id": (
                latest_developer_result.get("id") if latest_developer_result else None
            ),
            "latest_developer_result_summary": (
                latest_developer_result.get("summary") if latest_developer_result else None
            ),
            "latest_developer_result_status": (
                latest_developer_result.get("status") if latest_developer_result else None
            ),
            "work_order_status": work_order_status or None,
            "handoff_context": handoff_context,
            "generated_at": _utc_now(),
        }
        if repair_request_id:
            readiness["repair_request_id"] = str(repair_request_id)
        return readiness

    def _qa_handoff_status_check(
        self,
        work_order_status: str,
        handoff_context: Literal["initial_qa", "repair_qa"],
    ) -> tuple[Literal["passed", "warning", "blocked"], str]:
        if work_order_status not in WORK_ORDER_STATUSES:
            return (
                "blocked",
                f"Work order status {work_order_status or 'unknown'} is not recognized.",
            )
        if work_order_status in {"cancelled", "rejected"}:
            return (
                "blocked",
                f"Work order is {work_order_status}; QA handoff is not suitable.",
            )
        if handoff_context == "repair_qa":
            if work_order_status in REPAIR_QA_HANDOFF_WORK_ORDER_STATUSES:
                return (
                    "passed",
                    f"Repair work order is {work_order_status}, which is suitable for repair QA.",
                )
            allowed = ", ".join(REPAIR_QA_HANDOFF_WORK_ORDER_STATUSES)
            return (
                "blocked",
                (
                    f"Repair work order is {work_order_status}; repair QA handoffs "
                    f"require status {allowed}."
                ),
            )
        if work_order_status in {"draft", "waiting_approval", "blocked"}:
            return (
                "warning",
                (
                    f"Work order is {work_order_status}; this remains an advisory "
                    "preflight warning for initial QA in this slice."
                ),
            )
        return (
            "passed",
            f"Work order is {work_order_status}, which is suitable for initial QA.",
        )

    def _raise_for_readiness_blockers(self, readiness: dict[str, Any]) -> None:
        blockers = readiness.get("blockers", [])
        if not blockers:
            return
        blocked_by_policy = (
            readiness.get("policy_enforced")
            and readiness.get("advisory_warnings_promoted_to_blockers")
        )
        prefix = (
            "QA readiness blocked by policy enforcement"
            if blocked_by_policy
            else "QA readiness blocked"
        )
        raise HTTPException(
            status_code=400,
            detail=(
                f"{prefix} for work order {readiness.get('work_order_id')}: "
                + " ".join(str(blocker) for blocker in blockers)
            ),
        )

    def _readiness_validation_summary(self, readiness: dict[str, Any]) -> str:
        blockers = readiness.get("blockers", [])
        warnings = readiness.get("warnings", [])
        policy_mode = str(readiness.get("policy_mode") or "advisory")
        warnings_enforced = bool(readiness.get("advisory_warnings_promoted_to_blockers"))
        policy_summary = (
            f" Policy mode: {policy_mode}; warnings enforced: "
            f"{'yes' if warnings_enforced else 'no'}."
        )
        if blockers:
            return (
                " Readiness preflight blocked: "
                + " ".join(str(item) for item in blockers)
                + policy_summary
            )
        if warnings:
            return (
                " Readiness preflight warning: "
                + " ".join(str(item) for item in warnings)
                + policy_summary
            )
        return " Readiness preflight ready: all advisory checks passed." + policy_summary

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

    def _decide_repair_request(
        self,
        repair_request_id: str,
        status: RepairRequestStatus,
        decision: RepairRequestDecision,
    ) -> dict[str, Any]:
        repair_request = self._find_repair_request(repair_request_id)
        if repair_request is None:
            raise HTTPException(
                status_code=404,
                detail=f"Unknown repair request id: {repair_request_id}",
            )
        if repair_request.get("status") in {"completed", "cancelled"}:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"Repair request {repair_request_id} is already "
                    f"{repair_request.get('status')}."
                ),
            )

        decision_data = _model_to_dict(decision)
        decided_by = str(decision_data.get("decided_by") or "operator").strip() or "operator"
        reason = (
            str(decision_data.get("decision_reason") or "").strip()
            or f"Operator marked repair request {repair_request_id} {status}."
        )
        now = _utc_now()
        repair_request["status"] = status
        repair_request["updated_at"] = now
        if status == "completed":
            repair_request["completed_at"] = now

        event_type = "repair_request_completed" if status == "completed" else "repair_request_cancelled"

        self._append_event(
            event_type=event_type,
            summary=f"Repair request {repair_request_id} {status}. Reason: {reason}",
            actor_agent_id=decided_by,
            related_card_id=repair_request["card_id"],
            related_work_order_id=repair_request["repair_work_order_id"],
            related_handoff_id=repair_request["handoff_id"],
            related_repair_request_id=repair_request_id,
        )
        self._append_evidence(
            title=f"Repair request {repair_request_id} {status}",
            kind="repair_request",
            summary=reason,
            path=f"runtime/state/repair_requests.json#{repair_request_id}",
            related_card_id=repair_request["card_id"],
            related_work_order_id=repair_request["repair_work_order_id"],
            related_handoff_id=repair_request["handoff_id"],
            related_repair_request_id=repair_request_id,
        )

        self._save_collection("repair_requests", self.repair_requests)
        self._save_collection("events", self.events)
        self._save_collection("evidence", self.evidence)
        return repair_request

    def _mark_work_order_ready_from_developer_result(
        self,
        work_order: dict[str, Any],
        developer_result: dict[str, Any],
    ) -> None:
        previous_status = work_order.get("status")
        work_order["status"] = "ready"
        work_order["updated_at"] = developer_result["updated_at"]
        work_order_id = work_order["id"]
        result_id = developer_result["id"]
        summary = (
            f"Developer result {result_id} moved work order {work_order_id} "
            f"from {previous_status} to ready."
        )

        self._append_event(
            event_type="work_order_ready_from_developer_result",
            summary=summary,
            actor_agent_id=developer_result.get("agent_id", "developer_codex"),
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_developer_result_id=result_id,
        )
        self._append_evidence(
            title=f"Work order {work_order_id} ready from developer result",
            kind="status_transition",
            summary=summary,
            path=f"runtime/state/work_orders.json#{work_order_id}",
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_developer_result_id=result_id,
        )

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
            related_repair_request_id=qa_result.get("repair_request_id"),
        )
        self._append_evidence(
            title=f"Work order {work_order_id} updated from QA",
            kind="status_transition",
            summary=summary,
            path=f"runtime/state/work_orders.json#{work_order_id}",
            related_card_id=work_order["card_id"],
            related_work_order_id=work_order_id,
            related_handoff_id=handoff_id,
            related_repair_request_id=qa_result.get("repair_request_id"),
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

    def _normalize_policy_settings(self, settings: Any) -> dict[str, Any]:
        source = settings if isinstance(settings, dict) else {}
        normalized = dict(DEFAULT_POLICY_SETTINGS)

        mode = str(source.get("qa_handoff_policy_mode") or normalized["qa_handoff_policy_mode"]).strip().lower()
        normalized["qa_handoff_policy_mode"] = mode if mode in QA_HANDOFF_POLICY_MODES else "advisory"

        for field_name in (
            "require_developer_result_for_qa",
            "require_developer_result_for_repair_qa",
            "allow_operator_override",
        ):
            value = source.get(field_name)
            normalized[field_name] = value if isinstance(value, bool) else normalized[field_name]

        updated_at = str(source.get("updated_at") or normalized["updated_at"]).strip()
        updated_by = str(source.get("updated_by") or normalized["updated_by"]).strip()
        normalized["updated_at"] = updated_at or DEFAULT_POLICY_SETTINGS["updated_at"]
        normalized["updated_by"] = updated_by or DEFAULT_POLICY_SETTINGS["updated_by"]
        return normalized

    def _policy_related_card_id(self) -> str:
        if self.cards:
            return str(self.cards[-1].get("id") or "R19-CARD-001")
        return "R19-CARD-001"

    def _append_event(
        self,
        event_type: str,
        summary: str,
        actor_agent_id: str,
        related_card_id: str | None = None,
        related_work_order_id: str | None = None,
        related_approval_id: str | None = None,
        related_handoff_id: str | None = None,
        related_repair_request_id: str | None = None,
        related_developer_result_id: str | None = None,
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
            "related_repair_request_id": related_repair_request_id,
            "related_developer_result_id": related_developer_result_id,
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
        related_repair_request_id: str | None = None,
        related_developer_result_id: str | None = None,
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
            "related_repair_request_id": related_repair_request_id,
            "related_developer_result_id": related_developer_result_id,
            "created_at": _utc_now(),
        }
        self.evidence.append({key: value for key, value in evidence.items() if value is not None})

    def _latest_record(self, records: list[dict[str, Any]]) -> dict[str, Any] | None:
        if not records:
            return None
        return max(
            records,
            key=lambda record: str(
                record.get("updated_at")
                or record.get("created_at")
                or record.get("timestamp")
                or ""
            ),
        )

    def _latest_handoff_for_work_order(self, work_order_id: str) -> dict[str, Any] | None:
        return self._latest_record(
            [
                handoff
                for handoff in self.handoffs
                if handoff.get("work_order_id") == work_order_id
            ]
        )

    def _handoff_context(self, handoff: dict[str, Any]) -> str:
        return str(
            handoff.get("handoff_purpose")
            or ("repair_qa" if handoff.get("repair_request_id") else "initial_qa")
        )

    def _is_active_handoff(self, handoff: dict[str, Any]) -> bool:
        handoff_id = str(handoff.get("id") or "")
        return (
            handoff.get("status") in ACTIVE_HANDOFF_STATUSES
            and handoff_id
            and self._find_qa_result_for_handoff(handoff_id) is None
        )

    def _find_active_qa_handoff_for_work_order(
        self,
        work_order_id: str,
        handoff_context: str,
    ) -> dict[str, Any] | None:
        return self._latest_record(
            [
                handoff
                for handoff in self.handoffs
                if handoff.get("work_order_id") == work_order_id
                and self._handoff_context(handoff) == handoff_context
                and self._is_active_handoff(handoff)
            ]
        )

    def _latest_submitted_developer_result_for_work_order(
        self, work_order_id: str
    ) -> dict[str, Any] | None:
        return self._latest_record(
            [
                result
                for result in self.developer_results
                if result.get("work_order_id") == work_order_id
                and result.get("status") == "submitted"
            ]
        )

    def _infer_work_order_type(self, work_order: dict[str, Any]) -> str:
        work_order_type = str(work_order.get("work_order_type") or "").strip().lower()
        if work_order_type in WORK_ORDER_TYPES:
            return work_order_type
        if (
            work_order.get("repair_request_id")
            or work_order.get("source_work_order_id")
            or str(work_order.get("title") or "").startswith("Repair:")
        ):
            return "repair"
        return "original"

    def _infer_work_order_iteration(
        self,
        work_order: dict[str, Any] | None,
        seen_work_order_ids: set[str] | None = None,
    ) -> int:
        if not work_order:
            return 1

        existing_iteration = work_order.get("iteration_number")
        if existing_iteration is not None:
            return _coerce_iteration_number(existing_iteration, 1)

        if self._infer_work_order_type(work_order) == "original":
            return 1

        qa_result_id = work_order.get("qa_result_id")
        source_qa_result = self._find_qa_result(str(qa_result_id)) if qa_result_id else None
        if source_qa_result and source_qa_result.get("iteration_number") is not None:
            return _coerce_iteration_number(source_qa_result.get("iteration_number"), 1) + 1

        source_work_order_id = work_order.get("source_work_order_id")
        if source_work_order_id:
            seen = set(seen_work_order_ids or set())
            if str(source_work_order_id) in seen:
                return 2
            seen.add(str(work_order.get("id") or ""))
            source_work_order = self._find_work_order(str(source_work_order_id))
            if source_work_order:
                return self._infer_work_order_iteration(source_work_order, seen) + 1

        return 2

    def _resolve_original_work_order_id(self, work_order: dict[str, Any]) -> str:
        current = work_order
        seen: set[str] = set()
        while current.get("source_work_order_id"):
            current_id = str(current.get("id") or "")
            if current_id in seen:
                break
            seen.add(current_id)
            source_work_order = self._find_work_order(str(current["source_work_order_id"]))
            if not source_work_order:
                break
            current = source_work_order
        return str(current.get("id") or work_order.get("id"))

    def _repair_qa_iteration_number(
        self,
        repair_request: dict[str, Any],
        repair_work_order: dict[str, Any],
        source_qa_result: dict[str, Any] | None,
    ) -> int:
        existing_iteration = repair_work_order.get("iteration_number")
        if existing_iteration is not None:
            return _coerce_iteration_number(existing_iteration, 2)
        if source_qa_result and source_qa_result.get("iteration_number") is not None:
            return _coerce_iteration_number(source_qa_result.get("iteration_number"), 1) + 1
        source_work_order = self._find_work_order(str(repair_request.get("source_work_order_id") or ""))
        if source_work_order:
            return self._infer_work_order_iteration(source_work_order) + 1
        return 2

    def _find_active_repair_qa_handoff(
        self,
        repair_request_id: str,
        repair_work_order_id: str,
    ) -> dict[str, Any] | None:
        return self._latest_record(
            [
                handoff
                for handoff in self.handoffs
                if handoff.get("handoff_purpose") == "repair_qa"
                and handoff.get("repair_request_id") == repair_request_id
                and handoff.get("work_order_id") == repair_work_order_id
                and self._is_active_handoff(handoff)
            ]
        )

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

    def _find_developer_result(self, developer_result_id: str) -> dict[str, Any] | None:
        return next(
            (
                result
                for result in self.developer_results
                if result.get("id") == developer_result_id
            ),
            None,
        )

    def _find_qa_result(self, qa_result_id: str) -> dict[str, Any] | None:
        return next(
            (qa_result for qa_result in self.qa_results if qa_result.get("id") == qa_result_id),
            None,
        )

    def _find_qa_result_for_handoff(self, handoff_id: str) -> dict[str, Any] | None:
        return next(
            (qa_result for qa_result in self.qa_results if qa_result.get("handoff_id") == handoff_id),
            None,
        )

    def _find_repair_request(self, repair_request_id: str) -> dict[str, Any] | None:
        return next(
            (
                repair_request
                for repair_request in self.repair_requests
                if repair_request.get("id") == repair_request_id
            ),
            None,
        )

    def _find_repair_request_for_qa_result(self, qa_result_id: str) -> dict[str, Any] | None:
        return next(
            (
                repair_request
                for repair_request in self.repair_requests
                if repair_request.get("qa_result_id") == qa_result_id
            ),
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


def _normalize_string_list(value: Any, field_name: str) -> list[str]:
    if not isinstance(value, list):
        raise HTTPException(status_code=400, detail=f"{field_name} must be a list of strings.")

    normalized: list[str] = []
    for item in value:
        if not isinstance(item, str):
            raise HTTPException(status_code=400, detail=f"{field_name} must be a list of strings.")
        stripped_item = item.strip()
        if stripped_item:
            normalized.append(stripped_item)
    return normalized


def _coerce_iteration_number(value: Any, default: int) -> int:
    try:
        iteration_number = int(value)
    except (TypeError, ValueError):
        iteration_number = int(default)
    return max(1, iteration_number)


def _utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


store = JsonStateStore()
app = FastAPI(
    title="AIOffice Orchestrator API",
    version="0.3.0",
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


@app.get("/policy-settings")
def get_policy_settings() -> dict[str, Any]:
    return store.get_policy_settings()


@app.patch("/policy-settings")
def patch_policy_settings(policy_settings: PolicySettingsUpdate) -> dict[str, Any]:
    return store.update_policy_settings(policy_settings)


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


@app.get("/work-orders/{work_order_id}/qa-readiness")
def get_work_order_qa_readiness(work_order_id: str) -> dict[str, Any]:
    return store.work_order_qa_readiness(work_order_id)


@app.get("/developer-results")
def get_developer_results() -> list[dict[str, Any]]:
    return store.developer_results


@app.get("/workflow-iterations")
def get_workflow_iterations() -> list[dict[str, Any]]:
    return store.workflow_iterations()


@app.post("/work-orders", status_code=201)
def post_work_orders(work_order: WorkOrderCreate) -> dict[str, Any]:
    return store.create_work_order(work_order)


@app.post("/work-orders/{work_order_id}/developer-result", status_code=201)
def post_work_order_developer_result(
    work_order_id: str, developer_result: DeveloperResultCreate
) -> dict[str, Any]:
    return store.create_developer_result(work_order_id, developer_result)


@app.post("/developer-results/{developer_result_id}/supersede")
def post_developer_result_supersede(developer_result_id: str) -> dict[str, Any]:
    return store.supersede_developer_result(developer_result_id)


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


@app.get("/repair-requests")
def get_repair_requests() -> list[dict[str, Any]]:
    return store.repair_requests


@app.get("/repair-requests/{repair_request_id}/qa-readiness")
def get_repair_request_qa_readiness(repair_request_id: str) -> dict[str, Any]:
    return store.repair_request_qa_readiness(repair_request_id)


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


@app.post("/qa-results/{qa_result_id}/repair-request", status_code=201)
def post_qa_result_repair_request(
    qa_result_id: str, repair_request: RepairRequestCreate
) -> dict[str, Any]:
    return store.create_repair_request(qa_result_id, repair_request)


@app.post("/repair-requests/{repair_request_id}/complete")
def post_repair_request_complete(
    repair_request_id: str, decision: RepairRequestDecision | None = None
) -> dict[str, Any]:
    return store.complete_repair_request(repair_request_id, decision or RepairRequestDecision())


@app.post("/repair-requests/{repair_request_id}/cancel")
def post_repair_request_cancel(
    repair_request_id: str, decision: RepairRequestDecision | None = None
) -> dict[str, Any]:
    return store.cancel_repair_request(repair_request_id, decision or RepairRequestDecision())


@app.post("/repair-requests/{repair_request_id}/handoff-to-qa", status_code=201)
def post_repair_request_handoff_to_qa(repair_request_id: str) -> dict[str, Any]:
    return store.handoff_repair_request_to_qa(repair_request_id)
