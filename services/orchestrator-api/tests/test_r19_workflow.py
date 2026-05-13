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

    cards_response = client.get("/cards")
    assert cards_response.status_code == 200
    assert cards_response.json()[0]["id"] == "R19-CARD-001"

    approvals_response = client.get("/approvals")
    assert approvals_response.status_code == 200
    assert approvals_response.json()[0]["status"] == "pending"


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
