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


def create_card_and_work_order(client: TestClient, label: str) -> tuple[dict, dict]:
    card = client.post(
        "/cards",
        json={"title": f"{label} card", "description": f"Card for {label}."},
    ).json()
    work_order = client.post(
        "/work-orders",
        json={
            "card_id": card["id"],
            "title": f"{label} work order",
            "description": f"Work order for {label}.",
            "request_requires_approval": False,
        },
    ).json()
    return card, work_order


def create_handoff(
    client: TestClient, card: dict, work_order: dict, status: str = "proposed"
) -> dict:
    if status in {"proposed", "accepted", "rejected"}:
        handoff = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa").json()
        if status == "accepted":
            return client.post(
                f"/handoffs/{handoff['id']}/accept",
                json={"decision_reason": "Accepted by regression harness.", "decided_by": "pytest"},
            ).json()
        if status == "rejected":
            return client.post(
                f"/handoffs/{handoff['id']}/reject",
                json={"decision_reason": "Rejected by regression harness.", "decided_by": "pytest"},
            ).json()
        return handoff

    return client.post(
        "/handoffs",
        json={
            "source_agent_id": "developer_codex",
            "target_agent_id": "qa_test",
            "source_role": "Developer/Codex",
            "target_role": "QA/Test",
            "card_id": card["id"],
            "work_order_id": work_order["id"],
            "title": f"{status.title()} QA handoff",
            "summary": f"Regression harness handoff in {status}.",
            "status": status,
        },
    ).json()


def valid_qa_result_payload(result: str = "passed") -> dict:
    return {
        "result": result,
        "summary": f"QA result recorded as {result}.",
        "findings": "Regression harness captured structured findings.",
        "recommended_next_action": "Complete work order / repair / block.",
        "qa_agent_id": "qa_test",
    }


def valid_repair_request_payload(label: str = "regression repair") -> dict:
    return {
        "summary": f"{label} summary",
        "repair_instructions": f"Repair instructions for {label}.",
        "requested_by": "operator",
        "assigned_agent_id": "developer_codex",
    }


def create_accepted_qa_result(
    client: TestClient,
    label: str,
    result: str,
) -> tuple[dict, dict, dict, dict]:
    card, work_order = create_card_and_work_order(client, label)
    client.patch(
        f"/work-orders/{work_order['id']}/status",
        json={
            "status": "running",
            "reason": "Ready for QA repair-loop coverage.",
            "requested_by": "pytest",
        },
    )
    handoff = create_handoff(client, card, work_order, status="accepted")
    qa_result_response = client.post(
        f"/handoffs/{handoff['id']}/qa-result",
        json=valid_qa_result_payload(result),
    )
    assert qa_result_response.status_code == 201
    return card, work_order, handoff, qa_result_response.json()


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
    assert status["workflow_iterations_count"] == 1
    assert status["repair_qa_handoffs_count"] == 0
    assert status["repair_qa_results_count"] == 0

    cards_response = client.get("/cards")
    assert cards_response.status_code == 200
    assert cards_response.json()[0]["id"] == "R19-CARD-001"

    approvals_response = client.get("/approvals")
    assert approvals_response.status_code == 200
    assert approvals_response.json()[0]["status"] == "pending"

    handoffs_response = client.get("/handoffs")
    assert handoffs_response.status_code == 200
    assert handoffs_response.json() == []

    qa_results_response = client.get("/qa-results")
    assert qa_results_response.status_code == 200
    assert qa_results_response.json() == []

    repair_requests_response = client.get("/repair-requests")
    assert repair_requests_response.status_code == 200
    assert repair_requests_response.json() == []

    workflow_iterations_response = client.get("/workflow-iterations")
    assert workflow_iterations_response.status_code == 200
    workflow_iterations = workflow_iterations_response.json()
    assert isinstance(workflow_iterations, list)
    assert workflow_iterations[0]["work_order_id"] == "R19-WO-001"
    assert workflow_iterations[0]["work_order_type"] == "original"

    assert status["qa_results_count"] == 0
    assert status["failed_qa_results_count"] == 0
    assert status["blocked_qa_results_count"] == 0
    assert status["repair_requests_count"] == 0
    assert status["open_repair_requests_count"] == 0
    assert status["completed_repair_requests_count"] == 0


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


def test_qa_result_error_paths_require_existing_accepted_handoff(client: TestClient) -> None:
    missing_response = client.post("/handoffs/missing/qa-result", json=valid_qa_result_payload())
    assert missing_response.status_code == 404
    assert "Unknown handoff id" in missing_response.json()["detail"]

    card, work_order = create_card_and_work_order(client, "proposed QA result")
    proposed_handoff = create_handoff(client, card, work_order)
    proposed_response = client.post(
        f"/handoffs/{proposed_handoff['id']}/qa-result",
        json=valid_qa_result_payload(),
    )
    assert proposed_response.status_code == 400
    assert "accepted handoffs" in proposed_response.json()["detail"]

    rejected_handoff = create_handoff(client, card, work_order, status="rejected")
    rejected_response = client.post(
        f"/handoffs/{rejected_handoff['id']}/qa-result",
        json=valid_qa_result_payload(),
    )
    assert rejected_response.status_code == 400
    assert "accepted handoffs" in rejected_response.json()["detail"]

    blocked_handoff = create_handoff(client, card, work_order, status="blocked")
    blocked_response = client.post(
        f"/handoffs/{blocked_handoff['id']}/qa-result",
        json=valid_qa_result_payload(),
    )
    assert blocked_response.status_code == 400
    assert "accepted handoffs" in blocked_response.json()["detail"]

    accepted_handoff = create_handoff(client, card, work_order, status="accepted")
    invalid_response = client.post(
        f"/handoffs/{accepted_handoff['id']}/qa-result",
        json=valid_qa_result_payload("not_real"),
    )
    assert invalid_response.status_code == 400
    assert "Invalid QA result status" in invalid_response.json()["detail"]


def test_qa_result_records_events_evidence_status_and_persistence(client: TestClient) -> None:
    card, work_order = create_card_and_work_order(client, "accepted QA result")
    client.patch(
        f"/work-orders/{work_order['id']}/status",
        json={
            "status": "running",
            "reason": "Ready for QA result capture.",
            "requested_by": "pytest",
        },
    )
    handoff = create_handoff(client, card, work_order, status="accepted")

    qa_result_response = client.post(
        f"/handoffs/{handoff['id']}/qa-result",
        json=valid_qa_result_payload("passed"),
    )
    assert qa_result_response.status_code == 201
    qa_result = qa_result_response.json()
    assert qa_result["handoff_id"] == handoff["id"]
    assert qa_result["card_id"] == card["id"]
    assert qa_result["work_order_id"] == work_order["id"]
    assert qa_result["qa_agent_id"] == "qa_test"
    assert qa_result["result"] == "passed"
    assert qa_result["created_at"]
    assert qa_result["updated_at"]
    assert f"runtime/state/qa_results.json#{qa_result['id']}" in qa_result["evidence_refs"]

    duplicate_response = client.post(
        f"/handoffs/{handoff['id']}/qa-result",
        json=valid_qa_result_payload("passed"),
    )
    assert duplicate_response.status_code == 400
    assert "already exists" in duplicate_response.json()["detail"]

    qa_results = client.get("/qa-results").json()
    assert any(item["id"] == qa_result["id"] for item in qa_results)

    persisted_work_order = next(
        item for item in client.get("/work-orders").json() if item["id"] == work_order["id"]
    )
    assert persisted_work_order["status"] == "completed"

    status = client.get("/status").json()
    assert status["qa_results_count"] == 1
    assert status["failed_qa_results_count"] == 0
    assert status["blocked_qa_results_count"] == 0

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(
        event["type"] == "qa_result_recorded"
        and event["related_handoff_id"] == handoff["id"]
        for event in events
    )
    assert any(
        event["type"] == "work_order_completed_from_qa"
        and event["related_work_order_id"] == work_order["id"]
        for event in events
    )
    assert any(
        entry["kind"] == "qa_result"
        and entry["related_handoff_id"] == handoff["id"]
        for entry in evidence
    )

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    persisted_qa_result = next(item for item in reloaded_store.qa_results if item["id"] == qa_result["id"])
    assert persisted_qa_result["result"] == "passed"
    assert next(item for item in reloaded_store.work_orders if item["id"] == work_order["id"])["status"] == "completed"


@pytest.mark.parametrize(
    ("result", "expected_status", "expected_event_type"),
    [
        ("failed", "blocked", "work_order_blocked_from_qa"),
        ("blocked", "blocked", "work_order_blocked_from_qa"),
    ],
)
def test_qa_result_failed_and_blocked_map_work_order_safely(
    client: TestClient,
    result: str,
    expected_status: str,
    expected_event_type: str,
) -> None:
    card, work_order = create_card_and_work_order(client, f"{result} QA result")
    client.patch(
        f"/work-orders/{work_order['id']}/status",
        json={
            "status": "running",
            "reason": "Ready for QA result mapping.",
            "requested_by": "pytest",
        },
    )
    handoff = create_handoff(client, card, work_order, status="accepted")

    response = client.post(
        f"/handoffs/{handoff['id']}/qa-result",
        json=valid_qa_result_payload(result),
    )
    assert response.status_code == 201
    assert response.json()["result"] == result

    persisted_work_order = next(
        item for item in client.get("/work-orders").json() if item["id"] == work_order["id"]
    )
    assert persisted_work_order["status"] == expected_status

    status = client.get("/status").json()
    assert status["qa_results_count"] == 1
    if result == "failed":
        assert status["failed_qa_results_count"] == 1
        assert status["blocked_qa_results_count"] == 0
    else:
        assert status["failed_qa_results_count"] == 0
        assert status["blocked_qa_results_count"] == 1

    events = client.get("/events").json()
    assert any(
        event["type"] == expected_event_type
        and event["related_work_order_id"] == work_order["id"]
        for event in events
    )


def test_repair_request_missing_and_passed_qa_result_error_paths(client: TestClient) -> None:
    missing_response = client.post(
        "/qa-results/missing/repair-request",
        json=valid_repair_request_payload("missing QA result"),
    )
    assert missing_response.status_code == 404
    assert "Unknown QA result id" in missing_response.json()["detail"]

    _, _, _, passed_qa_result = create_accepted_qa_result(client, "passed repair guard", "passed")
    passed_response = client.post(
        f"/qa-results/{passed_qa_result['id']}/repair-request",
        json=valid_repair_request_payload("passed QA result"),
    )
    assert passed_response.status_code == 400
    assert "failed or blocked" in passed_response.json()["detail"]


@pytest.mark.parametrize("result", ["failed", "blocked"])
def test_repair_request_creates_linked_repair_work_order_events_evidence_and_persists(
    client: TestClient,
    result: str,
) -> None:
    card, source_work_order, handoff, qa_result = create_accepted_qa_result(
        client,
        f"{result} repair loop",
        result,
    )

    response = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload(f"{result} repair loop"),
    )
    assert response.status_code == 201
    repair_request = response.json()
    assert repair_request["qa_result_id"] == qa_result["id"]
    assert repair_request["handoff_id"] == handoff["id"]
    assert repair_request["card_id"] == card["id"]
    assert repair_request["source_work_order_id"] == source_work_order["id"]
    assert repair_request["repair_work_order_id"]
    assert repair_request["assigned_agent_id"] == "developer_codex"
    assert repair_request["status"] == "created"
    assert repair_request["completed_at"] is None
    assert f"runtime/state/repair_requests.json#{repair_request['id']}" in repair_request["evidence_refs"]
    assert f"runtime/state/work_orders.json#{repair_request['repair_work_order_id']}" in repair_request["evidence_refs"]

    duplicate_response = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload(f"{result} duplicate repair loop"),
    )
    assert duplicate_response.status_code == 400
    assert "already exists" in duplicate_response.json()["detail"]

    repair_work_order = next(
        item
        for item in client.get("/work-orders").json()
        if item["id"] == repair_request["repair_work_order_id"]
    )
    assert repair_work_order["card_id"] == card["id"]
    assert repair_work_order["title"] == f"Repair: {source_work_order['title']}"
    assert repair_work_order["summary"] == f"Repair instructions for {result} repair loop."
    assert repair_work_order["status"] == "ready"
    assert repair_work_order["assigned_agent_id"] == "developer_codex"
    assert repair_work_order["approval_required"] is False
    assert repair_work_order["source_work_order_id"] == source_work_order["id"]
    assert repair_work_order["qa_result_id"] == qa_result["id"]
    assert repair_work_order["repair_request_id"] == repair_request["id"]
    assert repair_work_order["work_order_type"] == "repair"
    assert repair_work_order["iteration_number"] == 2

    status = client.get("/status").json()
    assert status["repair_requests_count"] == 1
    assert status["open_repair_requests_count"] == 1
    assert status["completed_repair_requests_count"] == 0

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(
        event["type"] == "repair_request_created"
        and event["related_repair_request_id"] == repair_request["id"]
        for event in events
    )
    assert any(
        event["type"] == "repair_work_order_created"
        and event["related_work_order_id"] == repair_request["repair_work_order_id"]
        for event in events
    )
    assert any(
        entry["kind"] == "repair_request"
        and entry["related_repair_request_id"] == repair_request["id"]
        for entry in evidence
    )
    assert any(
        entry["kind"] == "repair_work_order"
        and entry["related_work_order_id"] == repair_request["repair_work_order_id"]
        for entry in evidence
    )

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    persisted_repair_request = next(
        item for item in reloaded_store.repair_requests if item["id"] == repair_request["id"]
    )
    persisted_repair_work_order = next(
        item
        for item in reloaded_store.work_orders
        if item["id"] == repair_request["repair_work_order_id"]
    )
    assert persisted_repair_request["repair_work_order_id"] == repair_request["repair_work_order_id"]
    assert persisted_repair_work_order["repair_request_id"] == repair_request["id"]


def test_repair_work_order_can_handoff_back_to_qa_and_record_iteration_result(
    client: TestClient,
) -> None:
    card, source_work_order, initial_handoff, failed_qa_result = create_accepted_qa_result(
        client,
        "repair QA iteration",
        "failed",
    )
    repair_request_response = client.post(
        f"/qa-results/{failed_qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair QA iteration"),
    )
    assert repair_request_response.status_code == 201
    repair_request = repair_request_response.json()
    repair_work_order_id = repair_request["repair_work_order_id"]

    repair_handoff_response = client.post(
        f"/repair-requests/{repair_request['id']}/handoff-to-qa"
    )
    assert repair_handoff_response.status_code == 201
    repair_handoff = repair_handoff_response.json()
    assert repair_handoff["status"] == "proposed"
    assert repair_handoff["work_order_id"] == repair_work_order_id
    assert repair_handoff["repair_request_id"] == repair_request["id"]
    assert repair_handoff["qa_result_id"] == failed_qa_result["id"]
    assert repair_handoff["handoff_purpose"] == "repair_qa"
    assert repair_handoff["iteration_number"] == 2

    duplicate_response = client.post(f"/repair-requests/{repair_request['id']}/handoff-to-qa")
    assert duplicate_response.status_code == 400
    assert "already exists" in duplicate_response.json()["detail"]

    accepted_repair_handoff_response = client.post(
        f"/handoffs/{repair_handoff['id']}/accept",
        json={"decision_reason": "Accepted repair QA handoff.", "decided_by": "pytest"},
    )
    assert accepted_repair_handoff_response.status_code == 200
    assert accepted_repair_handoff_response.json()["status"] == "accepted"

    repair_qa_result_response = client.post(
        f"/handoffs/{repair_handoff['id']}/qa-result",
        json=valid_qa_result_payload("passed"),
    )
    assert repair_qa_result_response.status_code == 201
    repair_qa_result = repair_qa_result_response.json()
    assert repair_qa_result["result"] == "passed"
    assert repair_qa_result["repair_request_id"] == repair_request["id"]
    assert repair_qa_result["source_qa_result_id"] == failed_qa_result["id"]
    assert repair_qa_result["iteration_number"] == 2

    repair_work_order = next(
        item for item in client.get("/work-orders").json() if item["id"] == repair_work_order_id
    )
    assert repair_work_order["status"] == "completed"

    workflow_iterations = client.get("/workflow-iterations").json()
    original_iteration = next(
        item for item in workflow_iterations if item["work_order_id"] == source_work_order["id"]
    )
    repair_iteration = next(
        item for item in workflow_iterations if item["work_order_id"] == repair_work_order_id
    )
    assert original_iteration["work_order_type"] == "original"
    assert original_iteration["iteration_number"] == 1
    assert original_iteration["qa_result_id"] == failed_qa_result["id"]
    assert original_iteration["latest_result"] == "failed"
    assert repair_iteration["work_order_type"] == "repair"
    assert repair_iteration["original_work_order_id"] == source_work_order["id"]
    assert repair_iteration["repair_request_id"] == repair_request["id"]
    assert repair_iteration["handoff_id"] == repair_handoff["id"]
    assert repair_iteration["qa_result_id"] == repair_qa_result["id"]
    assert repair_iteration["source_qa_result_id"] == failed_qa_result["id"]
    assert repair_iteration["iteration_number"] == 2
    assert repair_iteration["latest_result"] == "passed"

    status = client.get("/status").json()
    assert status["workflow_iterations_count"] == len(workflow_iterations)
    assert status["repair_qa_handoffs_count"] == 1
    assert status["repair_qa_results_count"] == 1

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(
        event["type"] == "repair_handoff_created"
        and event["related_repair_request_id"] == repair_request["id"]
        for event in events
    )
    assert any(
        event["type"] == "repair_qa_result_recorded"
        and event["related_handoff_id"] == repair_handoff["id"]
        for event in events
    )
    assert any(
        event["type"] == "repair_iteration_passed"
        and event["related_work_order_id"] == repair_work_order_id
        for event in events
    )
    assert any(
        entry["kind"] == "repair_handoff"
        and entry["related_handoff_id"] == repair_handoff["id"]
        for entry in evidence
    )
    assert any(
        entry["kind"] == "repair_qa_result"
        and entry["related_handoff_id"] == repair_handoff["id"]
        for entry in evidence
    )
    assert any(
        entry["kind"] == "workflow_iteration"
        and entry["related_repair_request_id"] == repair_request["id"]
        for entry in evidence
    )

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    assert next(item for item in reloaded_store.handoffs if item["id"] == repair_handoff["id"])[
        "handoff_purpose"
    ] == "repair_qa"
    assert next(item for item in reloaded_store.qa_results if item["id"] == repair_qa_result["id"])[
        "repair_request_id"
    ] == repair_request["id"]
    assert next(item for item in reloaded_store.work_orders if item["id"] == repair_work_order_id)[
        "status"
    ] == "completed"
    assert any(
        item["work_order_id"] == repair_work_order_id and item["latest_result"] == "passed"
        for item in reloaded_store.workflow_iterations()
    )


def test_repair_handoff_missing_and_invalid_repair_work_order_errors(client: TestClient) -> None:
    missing_response = client.post("/repair-requests/missing/handoff-to-qa")
    assert missing_response.status_code == 404
    assert "Unknown repair request id" in missing_response.json()["detail"]

    _, _, _, qa_result = create_accepted_qa_result(client, "invalid repair handoff", "blocked")
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("invalid repair handoff"),
    ).json()
    api_main.store.repair_requests[-1]["repair_work_order_id"] = "missing-work-order"

    invalid_response = client.post(f"/repair-requests/{repair_request['id']}/handoff-to-qa")
    assert invalid_response.status_code == 400
    assert "missing repair work-order" in invalid_response.json()["detail"]


@pytest.mark.parametrize(
    ("endpoint", "expected_status", "expected_event_type"),
    [
        ("complete", "completed", "repair_request_completed"),
        ("cancel", "cancelled", "repair_request_cancelled"),
    ],
)
def test_repair_request_complete_and_cancel_update_status_events_and_evidence(
    client: TestClient,
    endpoint: str,
    expected_status: str,
    expected_event_type: str,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(client, f"{endpoint} repair request", "failed")
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload(f"{endpoint} repair request"),
    ).json()

    response = client.post(
        f"/repair-requests/{repair_request['id']}/{endpoint}",
        json={"decision_reason": f"Operator chose to {endpoint}.", "decided_by": "pytest"},
    )
    assert response.status_code == 200
    decided_repair_request = response.json()
    assert decided_repair_request["status"] == expected_status
    assert decided_repair_request["updated_at"]
    if expected_status == "completed":
        assert decided_repair_request["completed_at"]
    else:
        assert decided_repair_request["completed_at"] is None

    status = client.get("/status").json()
    assert status["repair_requests_count"] == 1
    assert status["open_repair_requests_count"] == 0
    assert status["completed_repair_requests_count"] == (1 if expected_status == "completed" else 0)

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(
        event["type"] == expected_event_type
        and event["related_repair_request_id"] == repair_request["id"]
        for event in events
    )
    assert any(
        entry["kind"] == "repair_request"
        and entry["related_repair_request_id"] == repair_request["id"]
        and f"Operator chose to {endpoint}." in entry["summary"]
        for entry in evidence
    )

    duplicate_response = client.post(
        f"/repair-requests/{repair_request['id']}/{endpoint}",
        json={"decision_reason": "Duplicate terminal decision.", "decided_by": "pytest"},
    )
    assert duplicate_response.status_code == 400
    assert "already" in duplicate_response.json()["detail"]


def test_unknown_repair_request_complete_cancel_return_404(client: TestClient) -> None:
    assert client.post(
        "/repair-requests/missing/complete",
        json={"decision_reason": "Missing repair request."},
    ).status_code == 404
    assert client.post(
        "/repair-requests/missing/cancel",
        json={"decision_reason": "Missing repair request."},
    ).status_code == 404
