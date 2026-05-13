from __future__ import annotations

import shutil
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient


SERVICE_ROOT = Path(__file__).resolve().parents[1]
if str(SERVICE_ROOT) not in sys.path:
    sys.path.insert(0, str(SERVICE_ROOT))

from app import main as api_main  # noqa: E402


@pytest.fixture()
def client(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> TestClient:
    state_dir = tmp_path / "state"
    state_dir.mkdir()
    for seed_file in (api_main.REPO_ROOT / "runtime" / "state").glob("*.seed.json"):
        shutil.copy(seed_file, state_dir / seed_file.name)

    monkeypatch.setattr(api_main, "store", api_main.JsonStateStore(state_dir=state_dir))
    with TestClient(api_main.app) as test_client:
        yield test_client


def test_status_and_seed_collections(client: TestClient) -> None:
    status_response = client.get("/status")
    assert status_response.status_code == 200
    status = status_response.json()
    assert status["posture"] == "product_reset_active"
    assert status["branch"] == api_main.APP_BRANCH
    assert status["allowed_card_statuses"] == list(api_main.CARD_STATUSES)
    assert status["allowed_work_order_statuses"] == list(api_main.WORK_ORDER_STATUSES)
    assert status["handoffs_count"] == 0
    assert status["pending_handoffs_count"] == 0

    cards_response = client.get("/cards")
    assert cards_response.status_code == 200
    assert cards_response.json()[0]["id"] == "R19-CARD-001"

    approvals_response = client.get("/approvals")
    assert approvals_response.status_code == 200
    assert approvals_response.json()[0]["status"] == "pending"

    handoffs_response = client.get("/handoffs")
    assert handoffs_response.status_code == 200
    assert handoffs_response.json() == []


def test_card_work_order_status_workflow_and_persistence(client: TestClient) -> None:
    card_response = client.post(
        "/cards",
        json={
            "title": "Regression card",
            "description": "Protect the current R19 workflow.",
            "priority": "high",
        },
    )
    assert card_response.status_code == 201
    card = card_response.json()
    assert card["status"] == "intake"

    invalid_work_order_response = client.post(
        "/work-orders",
        json={
            "card_id": "missing-card",
            "title": "Invalid work order",
            "description": "Should fail.",
        },
    )
    assert invalid_work_order_response.status_code == 400

    work_order_response = client.post(
        "/work-orders",
        json={
            "card_id": card["id"],
            "title": "Regression work order",
            "description": "Exercise status updates.",
            "request_requires_approval": False,
        },
    )
    assert work_order_response.status_code == 201
    work_order = work_order_response.json()
    assert work_order["status"] == "draft"

    patched_card_response = client.patch(
        f"/cards/{card['id']}/status",
        json={
            "status": "planned",
            "reason": "Regression harness planned the card.",
            "requested_by": "pytest",
        },
    )
    assert patched_card_response.status_code == 200
    assert patched_card_response.json()["status"] == "planned"

    assert client.patch(
        f"/cards/{card['id']}/status",
        json={"status": "not_real", "requested_by": "pytest"},
    ).status_code == 400
    assert client.patch(
        "/cards/missing/status",
        json={"status": "planned", "requested_by": "pytest"},
    ).status_code == 404

    patched_work_order_response = client.patch(
        f"/work-orders/{work_order['id']}/status",
        json={
            "status": "running",
            "reason": "Regression harness started the work order.",
            "requested_by": "pytest",
        },
    )
    assert patched_work_order_response.status_code == 200
    assert patched_work_order_response.json()["status"] == "running"

    assert client.patch(
        f"/work-orders/{work_order['id']}/status",
        json={"status": "not_real", "requested_by": "pytest"},
    ).status_code == 400
    assert client.patch(
        "/work-orders/missing/status",
        json={"status": "running", "requested_by": "pytest"},
    ).status_code == 404

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(event["type"] == "card_status_changed" for event in events)
    assert any(event["type"] == "work_order_status_changed" for event in events)
    assert any(entry["kind"] == "status_transition" and entry["related_card_id"] == card["id"] for entry in evidence)
    assert any(
        entry["kind"] == "status_transition" and entry.get("related_work_order_id") == work_order["id"]
        for entry in evidence
    )

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    assert next(item for item in reloaded_store.cards if item["id"] == card["id"])["status"] == "planned"
    assert next(item for item in reloaded_store.work_orders if item["id"] == work_order["id"])["status"] == "running"


def test_approval_approve_and_reject_flow(client: TestClient) -> None:
    card = client.post(
        "/cards",
        json={"title": "Approval card", "description": "Card for approval checks."},
    ).json()
    work_order = client.post(
        "/work-orders",
        json={
            "card_id": card["id"],
            "title": "Approval work order",
            "description": "Work order awaiting approval.",
            "request_requires_approval": True,
        },
    ).json()
    assert work_order["status"] == "waiting_approval"

    approvals = client.get("/approvals").json()
    approval = next(item for item in approvals if item["related_work_order_id"] == work_order["id"])
    assert approval["status"] == "pending"

    approve_response = client.post(
        f"/approvals/{approval['id']}/approve",
        json={"decision_reason": "Approved by regression harness.", "decided_by": "pytest"},
    )
    assert approve_response.status_code == 200
    assert approve_response.json()["status"] == "approved"

    rejected_approval_response = client.post(
        "/approvals",
        json={
            "title": "Reject regression flow",
            "description": "Second manual approval test.",
            "related_card_id": card["id"],
            "requested_by": "pytest",
        },
    )
    assert rejected_approval_response.status_code == 201
    rejected_approval = rejected_approval_response.json()
    assert rejected_approval["status"] == "pending"
    reject_response = client.post(
        f"/approvals/{rejected_approval['id']}/reject",
        json={"decision_reason": "Rejected by regression harness.", "decided_by": "pytest"},
    )
    assert reject_response.status_code == 200
    assert reject_response.json()["status"] == "rejected"

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(event["type"] == "approval_approved" for event in events)
    assert any(event["type"] == "approval_rejected" for event in events)
    assert any(entry["kind"] == "approval_decision" and "Approved" in entry["summary"] for entry in evidence)
    assert any(entry["kind"] == "approval_decision" and "Rejected" in entry["summary"] for entry in evidence)


def test_create_handoff_validation_events_evidence_and_persistence(client: TestClient) -> None:
    card = client.post(
        "/cards",
        json={"title": "Handoff card", "description": "Card for handoff checks."},
    ).json()
    second_card = client.post(
        "/cards",
        json={"title": "Second handoff card", "description": "Card for mismatch checks."},
    ).json()
    work_order = client.post(
        "/work-orders",
        json={
            "card_id": card["id"],
            "title": "Handoff work order",
            "description": "Exercise API-mediated handoffs.",
            "request_requires_approval": False,
        },
    ).json()

    valid_response = client.post(
        "/handoffs",
        json={
            "source_agent_id": "developer_codex",
            "target_agent_id": "qa_test",
            "source_role": "Developer/Codex",
            "target_role": "QA/Test",
            "card_id": card["id"],
            "work_order_id": work_order["id"],
            "title": "Manual QA handoff",
            "summary": "Dry-run QA handoff.",
            "payload_summary": "Code is ready for a local QA pass.",
            "validation_summary": "Regression harness validated refs.",
        },
    )
    assert valid_response.status_code == 201
    handoff = valid_response.json()
    assert handoff["status"] == "proposed"
    assert handoff["source_agent_id"] == "developer_codex"
    assert handoff["target_agent_id"] == "qa_test"
    assert handoff["card_id"] == card["id"]
    assert handoff["work_order_id"] == work_order["id"]

    base_payload = {
        "source_agent_id": "developer_codex",
        "target_agent_id": "qa_test",
        "source_role": "Developer/Codex",
        "target_role": "QA/Test",
        "card_id": card["id"],
        "work_order_id": work_order["id"],
        "title": "Invalid handoff",
    }
    assert client.post("/handoffs", json={**base_payload, "source_agent_id": "missing"}).status_code == 400
    assert client.post("/handoffs", json={**base_payload, "target_agent_id": "missing"}).status_code == 400
    assert client.post("/handoffs", json={**base_payload, "card_id": "missing"}).status_code == 400
    assert client.post("/handoffs", json={**base_payload, "work_order_id": "missing"}).status_code == 400
    mismatch_response = client.post("/handoffs", json={**base_payload, "card_id": second_card["id"]})
    assert mismatch_response.status_code == 400
    assert "does not belong" in mismatch_response.json()["detail"]
    assert client.post("/handoffs", json={**base_payload, "status": "not_real"}).status_code == 400

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(event["type"] == "handoff_created" and event["related_handoff_id"] == handoff["id"] for event in events)
    assert any(
        entry["kind"] == "handoff_record" and entry["related_handoff_id"] == handoff["id"]
        for entry in evidence
    )

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    persisted_handoff = next(item for item in reloaded_store.handoffs if item["id"] == handoff["id"])
    assert persisted_handoff["status"] == "proposed"


def test_work_order_handoff_to_qa_accept_reject_and_error_paths(client: TestClient) -> None:
    card = client.post(
        "/cards",
        json={"title": "QA handoff card", "description": "Card for QA handoff checks."},
    ).json()
    work_order = client.post(
        "/work-orders",
        json={
            "card_id": card["id"],
            "title": "QA handoff work order",
            "description": "Exercise the first role-to-role handoff.",
            "request_requires_approval": False,
        },
    ).json()

    missing_work_order_response = client.post("/work-orders/missing/handoff-to-qa")
    assert missing_work_order_response.status_code == 404

    handoff_response = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa")
    assert handoff_response.status_code == 201
    handoff = handoff_response.json()
    assert handoff["source_agent_id"] == "developer_codex"
    assert handoff["target_agent_id"] == "qa_test"
    assert handoff["source_role"] == "Developer/Codex"
    assert handoff["target_role"] == "QA/Test"
    assert handoff["status"] == "proposed"
    assert "no AI or autonomous agent was invoked" in handoff["validation_summary"]

    accept_response = client.post(
        f"/handoffs/{handoff['id']}/accept",
        json={"decision_reason": "QA accepted the handoff for validation.", "decided_by": "pytest"},
    )
    assert accept_response.status_code == 200
    accepted_handoff = accept_response.json()
    assert accepted_handoff["status"] == "accepted"
    assert accepted_handoff["decision_reason"] == "QA accepted the handoff for validation."
    assert accepted_handoff["decided_at"]

    duplicate_response = client.post(
        f"/handoffs/{handoff['id']}/reject",
        json={"decision_reason": "Duplicate terminal decision.", "decided_by": "pytest"},
    )
    assert duplicate_response.status_code == 400
    assert "only proposed handoffs" in duplicate_response.json()["detail"]

    reject_handoff = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa").json()
    reject_response = client.post(
        f"/handoffs/{reject_handoff['id']}/reject",
        json={"decision_reason": "QA rejected the handoff.", "decided_by": "pytest"},
    )
    assert reject_response.status_code == 200
    assert reject_response.json()["status"] == "rejected"

    assert client.post("/handoffs/missing/accept", json={"decision_reason": "Missing."}).status_code == 404
    assert client.post("/handoffs/missing/reject", json={"decision_reason": "Missing."}).status_code == 404

    status = client.get("/status").json()
    assert status["handoffs_count"] == 2
    assert status["pending_handoffs_count"] == 0

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(event["type"] == "handoff_accepted" for event in events)
    assert any(event["type"] == "handoff_rejected" for event in events)
    assert any(entry["kind"] == "handoff_decision" and "accepted" in entry["title"] for entry in evidence)
    assert any(entry["kind"] == "handoff_decision" and "rejected" in entry["title"] for entry in evidence)
