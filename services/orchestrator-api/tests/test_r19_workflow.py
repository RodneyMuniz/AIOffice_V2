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
            "payload_summary": f"Regression harness payload for {work_order['id']}.",
            "validation_summary": "Regression harness validated refs.",
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


def valid_developer_result_payload(
    result_type: str = "implementation",
    summary: str = "Developer result captured by regression harness.",
    changed_paths: list[str] | None = None,
    agent_id: str = "developer_codex",
) -> dict:
    return {
        "result_type": result_type,
        "summary": summary,
        "changed_paths": changed_paths or ["apps/operator-ui/src/App.tsx"],
        "notes": "Regression harness result notes.",
        "agent_id": agent_id,
    }


def valid_repair_request_payload(label: str = "regression repair") -> dict:
    return {
        "summary": f"{label} summary",
        "repair_instructions": f"Repair instructions for {label}.",
        "requested_by": "operator",
        "assigned_agent_id": "developer_codex",
    }


def set_policy(
    client: TestClient,
    mode: str = "enforced",
    require_original: bool = False,
    require_repair: bool = False,
    allow_override: bool = False,
) -> dict:
    response = client.patch(
        "/policy-settings",
        json={
            "qa_handoff_policy_mode": mode,
            "require_developer_result_for_qa": require_original,
            "require_developer_result_for_repair_qa": require_repair,
            "allow_operator_override": allow_override,
            "updated_by": "pytest",
        },
    )
    assert response.status_code == 200
    return response.json()


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


def create_override_handoff(
    client: TestClient,
    label: str,
    override_reason: str,
) -> tuple[dict, dict]:
    _, work_order = create_card_and_work_order(client, label)
    set_policy(client, mode="enforced", require_original=True, allow_override=True)
    handoff_response = client.post(
        f"/work-orders/{work_order['id']}/handoff-to-qa",
        json={
            "override_policy": True,
            "override_reason": override_reason,
            "requested_by": "pytest",
        },
    )
    assert handoff_response.status_code == 201
    return work_order, handoff_response.json()


@pytest.fixture()
def client(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> TestClient:
    state_dir = tmp_path / "state"
    state_dir.mkdir()
    for seed_file in (api_main.REPO_ROOT / "runtime" / "state").glob("*.seed.json"):
        shutil.copy(seed_file, state_dir / seed_file.name)

    monkeypatch.setattr(api_main, "store", api_main.JsonStateStore(state_dir=state_dir))
    with TestClient(api_main.app) as test_client:
        yield test_client


def test_state_health_expected_collections_and_read_only(client: TestClient) -> None:
    state_dir = api_main.store.state_dir
    before_persistent_files = sorted(path.name for path in state_dir.glob("*.json"))
    before_events = client.get("/events").json()
    before_evidence = client.get("/evidence").json()

    response = client.get("/state/health")

    assert response.status_code == 200
    health = response.json()
    assert health["state_dir"] == str(state_dir)
    assert health["persistence_mode"] == "json"
    assert health["totals"]["collections"] == len(api_main.STATE_COLLECTIONS)
    assert [entry["name"] for entry in health["collections"]] == list(api_main.STATE_COLLECTIONS)
    assert health["blockers"] == []
    assert health["safe_to_reset"] is True
    cards_health = next(entry for entry in health["collections"] if entry["name"] == "cards")
    assert cards_health["seed_exists"] is True
    assert cards_health["persistent_exists"] is False
    assert cards_health["record_count"] >= 1
    assert cards_health["json_valid"] is True

    assert sorted(path.name for path in state_dir.glob("*.json")) == before_persistent_files
    assert client.get("/events").json() == before_events
    assert client.get("/evidence").json() == before_evidence


def test_state_export_returns_collections_and_non_claims(client: TestClient) -> None:
    response = client.get("/state/export")

    assert response.status_code == 200
    exported = response.json()
    assert exported["persistence_mode"] == "json"
    assert exported["state_dir"] == str(api_main.store.state_dir)
    assert "Not production backup or restore." in exported["non_claims"]
    collection_names = [entry["name"] for entry in exported["collections"]]
    assert collection_names == list(api_main.STATE_COLLECTIONS)
    cards = next(entry for entry in exported["collections"] if entry["name"] == "cards")
    assert cards["source"] == "seed"
    assert cards["record_count"] >= 1
    assert cards["records"][0]["id"] == "R19-CARD-001"
    policy_settings = next(
        entry for entry in exported["collections"] if entry["name"] == "policy_settings"
    )
    assert policy_settings["payload"]["qa_handoff_policy_mode"] == "advisory"


def test_reset_demo_wrong_confirm_does_nothing(client: TestClient) -> None:
    card = client.post(
        "/cards",
        json={"title": "Wrong reset guard", "description": "Should survive failed reset."},
    ).json()
    cards_path = api_main.store.state_dir / "cards.json"
    assert cards_path.exists()
    before_events = client.get("/events").json()

    response = client.post(
        "/state/reset-demo",
        json={
            "reset_reason": "Wrong confirmation coverage.",
            "requested_by": "pytest",
            "confirm": "RESET",
        },
    )

    assert response.status_code == 400
    assert cards_path.exists()
    assert any(item["id"] == card["id"] for item in client.get("/cards").json())
    assert client.get("/events").json() == before_events


def test_reset_demo_correct_confirm_resets_to_seed_and_records_state_event(
    client: TestClient,
) -> None:
    card = client.post(
        "/cards",
        json={"title": "Reset demo card", "description": "Should be removed by reset."},
    ).json()
    assert (api_main.store.state_dir / "cards.json").exists()

    response = client.post(
        "/state/reset-demo",
        json={
            "reset_reason": "Resetting local demo state from pytest.",
            "requested_by": "pytest",
            "confirm": api_main.STATE_RESET_CONFIRMATION,
        },
    )

    assert response.status_code == 200
    summary = response.json()
    assert "cards" in summary["reset_collections"]
    assert "cards.seed.json" in summary["preserved_seed_files"]
    assert not (api_main.store.state_dir / "cards.json").exists()
    cards = client.get("/cards").json()
    assert cards[0]["id"] == "R19-CARD-001"
    assert all(item["id"] != card["id"] for item in cards)
    assert any(event["type"] == "state_reset" for event in client.get("/events").json())
    assert any(
        evidence["kind"] == "state_management"
        and evidence["title"] == "Local demo state reset"
        for evidence in client.get("/evidence").json()
    )


def test_import_state_writes_collections_and_records_state_event(client: TestClient) -> None:
    imported_card = {
        "id": "R19-CARD-999",
        "title": "Imported card",
        "summary": "Imported from local state bundle.",
        "status": "planned",
        "owner_agent_id": "orchestrator",
        "owner_role": "operator",
        "priority": "high",
        "created_at": "2026-05-14T00:00:00Z",
    }
    imported_work_order = {
        "id": "R19-WO-999",
        "card_id": imported_card["id"],
        "title": "Imported work order",
        "summary": "Imported with the card.",
        "status": "ready",
        "requested_by_agent_id": "orchestrator",
        "assigned_agent_id": "developer_codex",
        "approval_required": False,
        "request_requires_approval": False,
        "evidence_refs": [],
        "iteration_number": 1,
        "work_order_type": "original",
        "created_at": "2026-05-14T00:00:00Z",
        "updated_at": "2026-05-14T00:00:00Z",
    }

    response = client.post(
        "/state/import",
        json={
            "collections": {
                "cards": [imported_card],
                "work_orders": [imported_work_order],
            },
            "import_reason": "Restoring local demo state from pytest.",
            "requested_by": "pytest",
        },
    )

    assert response.status_code == 200
    summary = response.json()
    assert summary["imported_collections"] == ["cards", "work_orders"]
    assert "agents" in summary["skipped_collections"]
    assert client.get("/cards").json() == [imported_card]
    assert client.get("/work-orders").json() == [imported_work_order]
    assert any(event["type"] == "state_imported" for event in client.get("/events").json())
    assert any(
        evidence["kind"] == "state_management"
        and evidence["title"] == "Local state imported"
        for evidence in client.get("/evidence").json()
    )


def test_import_state_accepts_export_bundle_shape(client: TestClient) -> None:
    client.post(
        "/cards",
        json={"title": "Export/import card", "description": "Round-trip through export."},
    )
    exported = client.get("/state/export").json()
    reset_response = client.post(
        "/state/reset-demo",
        json={
            "reset_reason": "Prepare for import bundle shape.",
            "requested_by": "pytest",
            "confirm": api_main.STATE_RESET_CONFIRMATION,
        },
    )
    assert reset_response.status_code == 200

    import_response = client.post(
        "/state/import",
        json={
            "collections": exported["collections"],
            "import_reason": "Importing an exported collection array.",
            "requested_by": "pytest",
        },
    )

    assert import_response.status_code == 200
    assert any(card["title"] == "Export/import card" for card in client.get("/cards").json())


def test_import_state_invalid_payload_returns_400(client: TestClient) -> None:
    unknown_response = client.post(
        "/state/import",
        json={"collections": {"not_a_collection": []}, "import_reason": "Invalid."},
    )
    shape_response = client.post(
        "/state/import",
        json={"collections": {"cards": {"id": "not-an-array"}}, "import_reason": "Invalid."},
    )

    assert unknown_response.status_code == 400
    assert shape_response.status_code == 400


def test_state_health_reports_invalid_json_blocker(client: TestClient) -> None:
    cards_path = api_main.store.state_dir / "cards.json"
    cards_path.write_text("{not valid json", encoding="utf-8")

    response = client.get("/state/health")

    assert response.status_code == 200
    health = response.json()
    cards_health = next(entry for entry in health["collections"] if entry["name"] == "cards")
    assert cards_health["json_valid"] is False
    assert "Persistent JSON is invalid" in cards_health["blocker"]
    assert any("cards: Persistent JSON is invalid" in blocker for blocker in health["blockers"])
    assert health["safe_to_reset"] is False


def test_status_and_seed_collections(client: TestClient) -> None:
    status_response = client.get("/status")
    assert status_response.status_code == 200
    status = status_response.json()
    assert status["posture"] == "product_reset_active"
    assert status["branch"] == api_main.APP_BRANCH
    assert status["allowed_card_statuses"] == list(api_main.CARD_STATUSES)
    assert status["allowed_work_order_statuses"] == list(api_main.WORK_ORDER_STATUSES)
    assert status["qa_handoff_policy_mode"] == "advisory"
    assert status["qa_policy_enforced"] is False
    assert status["require_developer_result_for_qa"] is False
    assert status["require_developer_result_for_repair_qa"] is False
    assert status["handoffs_count"] == 0
    assert status["pending_handoffs_count"] == 0
    assert status["workflow_iterations_count"] == 1
    assert status["repair_qa_handoffs_count"] == 0
    assert status["repair_qa_results_count"] == 0
    assert status["developer_results_count"] == 0
    assert status["submitted_developer_results_count"] == 0
    assert status["work_orders_with_developer_results_count"] == 0
    assert status["readiness_warnings_count"] >= 1
    assert status["readiness_blockers_count"] == 0
    assert status["policy_overrides_count"] == 0
    assert status["qa_handoffs_with_override_count"] == 0

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

    developer_results_response = client.get("/developer-results")
    assert developer_results_response.status_code == 200
    assert developer_results_response.json() == []

    policy_overrides_response = client.get("/policy-overrides")
    assert policy_overrides_response.status_code == 200
    assert policy_overrides_response.json() == []

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


def test_policy_settings_defaults_patch_persistence_events_and_evidence(
    client: TestClient,
) -> None:
    response = client.get("/policy-settings")
    assert response.status_code == 200
    policy_settings = response.json()
    assert policy_settings["qa_handoff_policy_mode"] == "advisory"
    assert policy_settings["require_developer_result_for_qa"] is False
    assert policy_settings["require_developer_result_for_repair_qa"] is False
    assert policy_settings["allow_operator_override"] is False
    assert policy_settings["updated_by"] == "system"

    before_events_count = len(client.get("/events").json())
    before_evidence_count = len(client.get("/evidence").json())
    update_response = client.patch(
        "/policy-settings",
        json={
            "qa_handoff_policy_mode": "enforced",
            "require_developer_result_for_qa": True,
            "require_developer_result_for_repair_qa": True,
            "allow_operator_override": False,
            "updated_by": "operator",
        },
    )

    assert update_response.status_code == 200
    updated_settings = update_response.json()
    assert updated_settings["qa_handoff_policy_mode"] == "enforced"
    assert updated_settings["require_developer_result_for_qa"] is True
    assert updated_settings["require_developer_result_for_repair_qa"] is True
    assert updated_settings["allow_operator_override"] is False
    assert updated_settings["updated_by"] == "operator"
    assert updated_settings["updated_at"]

    status = client.get("/status").json()
    assert status["qa_handoff_policy_mode"] == "enforced"
    assert status["qa_policy_enforced"] is True
    assert status["require_developer_result_for_qa"] is True
    assert status["require_developer_result_for_repair_qa"] is True

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert len(events) == before_events_count + 1
    assert len(evidence) == before_evidence_count + 1
    assert any(event["type"] == "policy_settings_updated" for event in events)
    assert any(entry["kind"] == "policy_settings" for entry in evidence)

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    assert reloaded_store.policy_settings["qa_handoff_policy_mode"] == "enforced"
    assert reloaded_store.policy_settings["require_developer_result_for_qa"] is True
    assert reloaded_store.policy_settings["require_developer_result_for_repair_qa"] is True


def test_policy_settings_invalid_mode_returns_400(client: TestClient) -> None:
    response = client.patch(
        "/policy-settings",
        json={
            "qa_handoff_policy_mode": "strict",
            "require_developer_result_for_qa": True,
            "require_developer_result_for_repair_qa": True,
            "allow_operator_override": False,
            "updated_by": "pytest",
        },
    )

    assert response.status_code == 400
    assert "Invalid QA handoff policy mode" in response.json()["detail"]


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


def test_developer_result_validation_events_evidence_status_handoff_and_persistence(
    client: TestClient,
) -> None:
    card, work_order = create_card_and_work_order(client, "developer result")

    missing_work_order_response = client.post(
        "/work-orders/missing/developer-result",
        json=valid_developer_result_payload(),
    )
    assert missing_work_order_response.status_code == 404

    unknown_agent_response = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(agent_id="missing_agent"),
    )
    assert unknown_agent_response.status_code == 400
    assert "Invalid agent_id" in unknown_agent_response.json()["detail"]

    invalid_type_response = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(result_type="not_real"),
    )
    assert invalid_type_response.status_code == 400
    assert "Invalid developer result type" in invalid_type_response.json()["detail"]

    invalid_paths_response = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json={**valid_developer_result_payload(), "changed_paths": "apps/operator-ui/src/App.tsx"},
    )
    assert invalid_paths_response.status_code == 400
    assert "changed_paths must be a list of strings" in invalid_paths_response.json()["detail"]

    result_response = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(
            summary="Original implementation result captured before QA.",
            changed_paths=["services/orchestrator-api/app/main.py"],
        ),
    )
    assert result_response.status_code == 201
    developer_result = result_response.json()
    assert developer_result["card_id"] == card["id"]
    assert developer_result["work_order_id"] == work_order["id"]
    assert developer_result["agent_id"] == "developer_codex"
    assert developer_result["result_type"] == "implementation"
    assert developer_result["status"] == "submitted"
    assert developer_result["changed_paths"] == ["services/orchestrator-api/app/main.py"]
    assert developer_result["created_at"]
    assert developer_result["updated_at"]
    assert f"runtime/state/developer_results.json#{developer_result['id']}" in developer_result["evidence_refs"]

    persisted_work_order = next(
        item for item in client.get("/work-orders").json() if item["id"] == work_order["id"]
    )
    assert persisted_work_order["status"] == "ready"
    assert persisted_work_order["latest_developer_result_id"] == developer_result["id"]
    assert developer_result["id"] in persisted_work_order["developer_result_ids"]

    duplicate_response = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(summary="Duplicate submitted result."),
    )
    assert duplicate_response.status_code == 400
    assert "supersede" in duplicate_response.json()["detail"]

    handoff_response = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa")
    assert handoff_response.status_code == 201
    handoff = handoff_response.json()
    assert handoff["developer_result_id"] == developer_result["id"]
    assert handoff["developer_result_summary"] == developer_result["summary"]
    assert developer_result["summary"] in handoff["payload_summary"]
    assert "Developer result" in handoff["validation_summary"]
    assert f"runtime/state/developer_results.json#{developer_result['id']}" in handoff["evidence_refs"]

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert any(
        event["type"] == "developer_result_recorded"
        and event.get("related_developer_result_id") == developer_result["id"]
        for event in events
    )
    assert any(
        event["type"] == "work_order_ready_from_developer_result"
        and event.get("related_work_order_id") == work_order["id"]
        for event in events
    )
    assert any(
        entry["kind"] == "developer_result"
        and entry.get("related_developer_result_id") == developer_result["id"]
        for entry in evidence
    )

    status = client.get("/status").json()
    assert status["developer_results_count"] == 1
    assert status["submitted_developer_results_count"] == 1
    assert status["work_orders_with_developer_results_count"] == 1

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    persisted_result = next(
        item for item in reloaded_store.developer_results if item["id"] == developer_result["id"]
    )
    assert persisted_result["summary"] == developer_result["summary"]
    assert next(item for item in reloaded_store.handoffs if item["id"] == handoff["id"])[
        "developer_result_id"
    ] == developer_result["id"]

    supersede_response = client.post(f"/developer-results/{developer_result['id']}/supersede")
    assert supersede_response.status_code == 200
    assert supersede_response.json()["status"] == "superseded"
    assert client.post(f"/developer-results/{developer_result['id']}/supersede").status_code == 400
    assert client.post("/developer-results/missing/supersede").status_code == 404

    superseded_status = client.get("/status").json()
    assert superseded_status["developer_results_count"] == 1
    assert superseded_status["submitted_developer_results_count"] == 0
    assert superseded_status["work_orders_with_developer_results_count"] == 0
    assert any(
        event["type"] == "developer_result_superseded"
        and event.get("related_developer_result_id") == developer_result["id"]
        for event in client.get("/events").json()
    )

    replacement_response = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(
            result_type="documentation",
            summary="Replacement developer result after supersede.",
            changed_paths=["packages/aio-contracts/README.md"],
        ),
    )
    assert replacement_response.status_code == 201
    assert replacement_response.json()["result_type"] == "documentation"


def test_work_order_qa_readiness_warns_when_developer_result_is_missing(
    client: TestClient,
) -> None:
    _, work_order = create_card_and_work_order(client, "readiness missing developer result")
    before_events_count = len(client.get("/events").json())
    before_evidence_count = len(client.get("/evidence").json())

    response = client.get(f"/work-orders/{work_order['id']}/qa-readiness")

    assert response.status_code == 200
    readiness = response.json()
    assert readiness["work_order_id"] == work_order["id"]
    assert readiness["card_id"] == work_order["card_id"]
    assert readiness["ready_for_qa"] is False
    assert readiness["readiness_level"] == "warning"
    assert readiness["handoff_context"] == "initial_qa"
    assert readiness["policy_mode"] == "advisory"
    assert readiness["policy_enforced"] is False
    assert readiness["advisory_warnings_promoted_to_blockers"] is False
    assert readiness["latest_developer_result_id"] is None
    assert readiness["latest_developer_result_summary"] is None
    assert readiness["latest_developer_result_status"] is None
    assert any("No submitted Developer/Codex result" in item for item in readiness["warnings"])
    assert readiness["blockers"] == []
    assert readiness["overridable_blockers"] == []
    assert readiness["non_overridable_blockers"] == []
    assert readiness["override_available"] is False
    assert any(
        check["id"] == "latest_developer_result_submitted"
        and check["status"] == "warning"
        for check in readiness["checks"]
    )
    assert len(client.get("/events").json()) == before_events_count
    assert len(client.get("/evidence").json()) == before_evidence_count


def test_enforced_policy_blocks_original_qa_until_developer_result_exists(
    client: TestClient,
) -> None:
    _, work_order = create_card_and_work_order(client, "enforced original policy")
    set_policy(client, mode="enforced", require_original=True)

    readiness_response = client.get(f"/work-orders/{work_order['id']}/qa-readiness")

    assert readiness_response.status_code == 200
    readiness = readiness_response.json()
    assert readiness["policy_mode"] == "enforced"
    assert readiness["policy_enforced"] is True
    assert readiness["advisory_warnings_promoted_to_blockers"] is True
    assert readiness["readiness_level"] == "blocked"
    assert readiness["ready_for_qa"] is False
    assert "Developer/Codex result is required by current QA handoff policy." in readiness["blockers"]
    assert readiness["overridable_blockers"] == []
    assert readiness["non_overridable_blockers"] == [
        "Developer/Codex result is required by current QA handoff policy."
    ]
    assert readiness["override_available"] is False
    assert any(
        check["id"] == "latest_developer_result_submitted"
        and check["status"] == "blocked"
        for check in readiness["checks"]
    )

    blocked_handoff_response = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa")
    assert blocked_handoff_response.status_code == 400
    assert "policy enforcement" in blocked_handoff_response.json()["detail"]

    developer_result = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(summary="Required original implementation result."),
    ).json()

    ready_response = client.get(f"/work-orders/{work_order['id']}/qa-readiness")
    assert ready_response.status_code == 200
    ready_readiness = ready_response.json()
    assert ready_readiness["readiness_level"] == "ready"
    assert ready_readiness["ready_for_qa"] is True
    assert ready_readiness["latest_developer_result_id"] == developer_result["id"]
    assert ready_readiness["advisory_warnings_promoted_to_blockers"] is False

    handoff_response = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa")
    assert handoff_response.status_code == 201
    handoff = handoff_response.json()
    assert handoff["developer_result_id"] == developer_result["id"]
    assert "Policy mode: enforced; warnings enforced: no." in handoff["validation_summary"]


def test_operator_override_allows_original_policy_promoted_missing_developer_result(
    client: TestClient,
) -> None:
    _, work_order = create_card_and_work_order(client, "original policy override")
    set_policy(client, mode="enforced", require_original=True, allow_override=True)

    readiness_response = client.get(f"/work-orders/{work_order['id']}/qa-readiness")
    assert readiness_response.status_code == 200
    readiness = readiness_response.json()
    assert readiness["readiness_level"] == "blocked"
    assert readiness["blockers"] == [api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER]
    assert readiness["overridable_blockers"] == [api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER]
    assert readiness["non_overridable_blockers"] == []
    assert readiness["override_available"] is True

    empty_reason_response = client.post(
        f"/work-orders/{work_order['id']}/handoff-to-qa",
        json={"override_policy": True, "override_reason": "   ", "requested_by": "operator"},
    )
    assert empty_reason_response.status_code == 400
    assert "override_reason is required" in empty_reason_response.json()["detail"]

    before_events_count = len(client.get("/events").json())
    before_evidence_count = len(client.get("/evidence").json())
    override_reason = "Operator accepts QA handoff without Developer/Codex result for this case."
    handoff_response = client.post(
        f"/work-orders/{work_order['id']}/handoff-to-qa",
        json={
            "override_policy": True,
            "override_reason": override_reason,
            "requested_by": "pytest",
        },
    )

    assert handoff_response.status_code == 201
    handoff = handoff_response.json()
    assert "developer_result_id" not in handoff
    assert handoff["policy_override_id"].startswith("R19-POLICY-OVERRIDE-")
    assert handoff["policy_override_reason"] == override_reason
    assert "Operator override" in handoff["validation_summary"]
    assert override_reason in handoff["validation_summary"]
    assert f"runtime/state/policy_overrides.json#{handoff['policy_override_id']}" in handoff["evidence_refs"]

    policy_overrides_response = client.get("/policy-overrides")
    assert policy_overrides_response.status_code == 200
    policy_overrides = policy_overrides_response.json()
    assert len(policy_overrides) == 1
    policy_override = policy_overrides[0]
    assert policy_override["id"] == handoff["policy_override_id"]
    assert policy_override["target_type"] == "work_order_qa_handoff"
    assert policy_override["target_id"] == work_order["id"]
    assert policy_override["work_order_id"] == work_order["id"]
    assert "repair_request_id" not in policy_override
    assert policy_override["card_id"] == work_order["card_id"]
    assert policy_override["policy_mode"] == "enforced"
    assert policy_override["overridden_blockers"] == [api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER]
    assert policy_override["non_overridable_blockers"] == []
    assert policy_override["reason"] == override_reason
    assert policy_override["requested_by"] == "pytest"
    assert policy_override["created_at"]

    events = client.get("/events").json()
    evidence = client.get("/evidence").json()
    assert len(events) == before_events_count + 2
    assert len(evidence) == before_evidence_count + 2
    assert any(
        event["type"] == "policy_override_recorded"
        and policy_override["id"] in event["summary"]
        for event in events
    )
    assert any(
        event["type"] == "handoff_created"
        and event["related_handoff_id"] == handoff["id"]
        and policy_override["id"] in event["summary"]
        for event in events
    )
    assert any(
        entry["kind"] == "policy_override"
        and entry["path"] == f"runtime/state/policy_overrides.json#{policy_override['id']}"
        for entry in evidence
    )
    assert any(
        entry["kind"] == "handoff_record"
        and entry["related_handoff_id"] == handoff["id"]
        and policy_override["id"] in entry["summary"]
        for entry in evidence
    )

    status = client.get("/status").json()
    assert status["policy_overrides_count"] == 1
    assert status["qa_handoffs_with_override_count"] == 1

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    assert reloaded_store.policy_overrides[0]["id"] == policy_override["id"]
    assert next(item for item in reloaded_store.handoffs if item["id"] == handoff["id"])[
        "policy_override_id"
    ] == policy_override["id"]


def test_duplicate_active_handoff_remains_non_overridable_with_operator_override(
    client: TestClient,
) -> None:
    card, work_order = create_card_and_work_order(client, "duplicate override guard")
    existing_handoff = create_handoff(client, card, work_order, status="proposed")
    set_policy(client, mode="enforced", require_original=True, allow_override=True)

    readiness = client.get(f"/work-orders/{work_order['id']}/qa-readiness").json()
    assert readiness["readiness_level"] == "blocked"
    assert api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER in readiness["overridable_blockers"]
    assert any(existing_handoff["id"] in blocker for blocker in readiness["non_overridable_blockers"])
    assert readiness["override_available"] is False

    response = client.post(
        f"/work-orders/{work_order['id']}/handoff-to-qa",
        json={
            "override_policy": True,
            "override_reason": "Operator override should not bypass duplicate handoffs.",
            "requested_by": "pytest",
        },
    )

    assert response.status_code == 400
    assert "non-overridable" in response.json()["detail"]
    assert existing_handoff["id"] in response.json()["detail"]
    assert client.get("/policy-overrides").json() == []


def test_audit_summary_seed_shape_and_read_only(client: TestClient) -> None:
    before_events_count = len(client.get("/events").json())
    before_evidence_count = len(client.get("/evidence").json())

    summary_response = client.get("/audit/summary")
    assert summary_response.status_code == 200
    summary = summary_response.json()
    assert summary["total_policy_overrides"] == 0
    assert summary["total_policy_override_handoffs"] == 0
    assert summary["total_policy_settings_changes"] == 0
    assert summary["total_qa_failures"] == 0
    assert summary["total_qa_blocked_results"] == 0
    assert summary["total_repair_requests"] == 0
    assert summary["open_repair_requests"] == 0
    assert summary["completed_repair_requests"] == 0
    assert "total_hard_blocker_events" in summary
    assert "total_readiness_blockers" in summary
    assert summary["audit_acknowledgement_history_entries"] == 0
    assert summary["audit_acknowledgements_with_history"] == 0
    assert summary["generated_at"]

    exceptions_response = client.get("/audit/exceptions")
    assert exceptions_response.status_code == 200
    assert exceptions_response.json() == []
    history_response = client.get("/audit/acknowledgement-history")
    assert history_response.status_code == 200
    assert history_response.json() == []
    json_export_response = client.get("/audit/export?format=json")
    assert json_export_response.status_code == 200
    assert set(json_export_response.json()) == {"summary", "exceptions"}
    csv_export_response = client.get("/audit/export?format=csv")
    assert csv_export_response.status_code == 200
    assert csv_export_response.headers["content-type"].startswith("text/csv")

    assert len(client.get("/events").json()) == before_events_count
    assert len(client.get("/evidence").json()) == before_evidence_count


def test_audit_summary_counts_policy_override_and_policy_change(client: TestClient) -> None:
    override_reason = "Audit summary override reason."
    work_order, handoff = create_override_handoff(client, "audit summary override", override_reason)

    summary_response = client.get("/audit/summary")
    assert summary_response.status_code == 200
    summary = summary_response.json()
    assert summary["total_policy_overrides"] == 1
    assert summary["total_policy_override_handoffs"] == 1
    assert summary["total_policy_settings_changes"] == 1
    assert summary["total_readiness_blockers"] >= 1

    exceptions = client.get("/audit/exceptions").json()
    assert any(
        entry["exception_type"] == "policy_override"
        and entry["policy_override_id"] == handoff["policy_override_id"]
        and entry["work_order_id"] == work_order["id"]
        for entry in exceptions
    )


def test_audit_exceptions_filters_exports_and_read_only(client: TestClient) -> None:
    override_reason = "Audit exception search override reason."
    work_order, handoff = create_override_handoff(client, "audit exceptions override", override_reason)

    readiness_exceptions = client.get("/audit/exceptions").json()
    assert any(entry["exception_type"] == "duplicate_handoff_blocked" for entry in readiness_exceptions)

    accept_response = client.post(
        f"/handoffs/{handoff['id']}/accept",
        json={"decision_reason": "Accepted for audit exception coverage.", "decided_by": "pytest"},
    )
    assert accept_response.status_code == 200
    failed_qa_response = client.post(
        f"/handoffs/{handoff['id']}/qa-result",
        json=valid_qa_result_payload("failed"),
    )
    assert failed_qa_response.status_code == 201
    failed_qa_result = failed_qa_response.json()
    repair_response = client.post(
        f"/qa-results/{failed_qa_result['id']}/repair-request",
        json=valid_repair_request_payload("audit exception repair"),
    )
    assert repair_response.status_code == 201
    repair_request = repair_response.json()

    _, blocked_work_order, blocked_handoff, blocked_qa_result = create_accepted_qa_result(
        client,
        "audit blocked result",
        "blocked",
    )

    before_events_count = len(client.get("/events").json())
    before_evidence_count = len(client.get("/evidence").json())

    exceptions_response = client.get("/audit/exceptions")
    assert exceptions_response.status_code == 200
    exceptions = exceptions_response.json()
    exception_types = {entry["exception_type"] for entry in exceptions}
    assert "policy_override" in exception_types
    assert "policy_settings_change" in exception_types
    assert "qa_failed" in exception_types
    assert "qa_blocked" in exception_types
    assert "repair_request_created" in exception_types
    assert "handoff_without_developer_result" in exception_types
    assert any(
        entry["exception_type"] == "qa_failed"
        and entry["qa_result_id"] == failed_qa_result["id"]
        for entry in exceptions
    )
    assert any(
        entry["exception_type"] == "qa_blocked"
        and entry["qa_result_id"] == blocked_qa_result["id"]
        and entry["handoff_id"] == blocked_handoff["id"]
        for entry in exceptions
    )
    assert any(
        entry["exception_type"] == "repair_request_created"
        and entry["repair_request_id"] == repair_request["id"]
        for entry in exceptions
    )
    assert any(
        entry["exception_type"] == "handoff_without_developer_result"
        and entry["handoff_id"] == handoff["id"]
        for entry in exceptions
    )

    policy_only_response = client.get(
        "/audit/exceptions",
        params={"exception_type": "policy_override"},
    )
    assert policy_only_response.status_code == 200
    policy_only = policy_only_response.json()
    assert policy_only
    assert all(entry["exception_type"] == "policy_override" for entry in policy_only)

    override_severity_response = client.get(
        "/audit/exceptions",
        params={"severity": "override"},
    )
    assert override_severity_response.status_code == 200
    override_severity = override_severity_response.json()
    assert override_severity
    assert all(entry["severity"] == "override" for entry in override_severity)

    work_order_response = client.get(
        "/audit/exceptions",
        params={"work_order_id": work_order["id"]},
    )
    assert work_order_response.status_code == 200
    assert work_order_response.json()
    assert all(entry["work_order_id"] == work_order["id"] for entry in work_order_response.json())

    search_response = client.get("/audit/exceptions", params={"q": "search override reason"})
    assert search_response.status_code == 200
    search_results = search_response.json()
    assert any(entry["policy_override_id"] == handoff["policy_override_id"] for entry in search_results)

    limited_response = client.get("/audit/exceptions", params={"limit": "1"})
    offset_response = client.get("/audit/exceptions", params={"limit": "1", "offset": "1"})
    assert limited_response.status_code == 200
    assert offset_response.status_code == 200
    assert len(limited_response.json()) == 1
    assert len(offset_response.json()) == 1
    assert limited_response.json()[0]["id"] != offset_response.json()[0]["id"]
    assert client.get("/audit/exceptions", params={"limit": "0"}).status_code == 400
    assert client.get("/audit/exceptions", params={"offset": "-1"}).status_code == 400

    json_export_response = client.get(
        "/audit/export",
        params={"format": "json", "exception_type": "policy_override"},
    )
    assert json_export_response.status_code == 200
    json_export = json_export_response.json()
    assert set(json_export) == {"summary", "exceptions"}
    assert json_export["summary"]["total_policy_overrides"] >= 1
    assert all(entry["exception_type"] == "policy_override" for entry in json_export["exceptions"])

    csv_export_response = client.get(
        "/audit/export",
        params={"format": "csv", "exception_type": "policy_override"},
    )
    assert csv_export_response.status_code == 200
    assert csv_export_response.headers["content-type"].startswith("text/csv")
    csv_text = csv_export_response.text
    assert "id,exception_type,severity,title,card_id,work_order_id,handoff_id" in csv_text
    assert handoff["policy_override_id"] in csv_text
    assert client.get("/audit/export?format=xml").status_code == 400

    assert len(client.get("/events").json()) == before_events_count
    assert len(client.get("/evidence").json()) == before_evidence_count
    assert blocked_work_order["id"]


def test_audit_acknowledgement_triage_persists_and_enriches_audit(
    client: TestClient,
) -> None:
    assert client.get("/audit/acknowledgements").status_code == 200
    assert client.get("/audit/acknowledgements").json() == []

    override_reason = "Audit acknowledgement source override reason."
    _, handoff = create_override_handoff(client, "audit acknowledgement", override_reason)
    policy_exception = next(
        entry
        for entry in client.get(
            "/audit/exceptions",
            params={"exception_type": "policy_override"},
        ).json()
        if entry["policy_override_id"] == handoff["policy_override_id"]
    )
    source_policy_overrides = client.get("/policy-overrides").json()

    missing_ref_response = client.post(
        "/audit/acknowledgements",
        json={
            "status": "acknowledged",
            "reason": "Reviewed but missing durable refs.",
            "acknowledged_by": "pytest",
        },
    )
    assert missing_ref_response.status_code == 400
    assert "exception_source_ref or exception_id" in missing_ref_response.json()["detail"]

    empty_reason_response = client.post(
        "/audit/acknowledgements",
        json={
            "exception_id": policy_exception["id"],
            "exception_source_ref": policy_exception["source_ref"],
            "exception_type": policy_exception["exception_type"],
            "status": "acknowledged",
            "reason": "   ",
            "acknowledged_by": "pytest",
        },
    )
    assert empty_reason_response.status_code == 400
    assert "reason is required" in empty_reason_response.json()["detail"]

    invalid_status_response = client.post(
        "/audit/acknowledgements",
        json={
            "exception_id": policy_exception["id"],
            "exception_source_ref": policy_exception["source_ref"],
            "exception_type": policy_exception["exception_type"],
            "status": "reviewed",
            "reason": "Invalid status coverage.",
            "acknowledged_by": "pytest",
        },
    )
    assert invalid_status_response.status_code == 400
    assert "Invalid audit acknowledgement status" in invalid_status_response.json()["detail"]

    before_events_count = len(client.get("/events").json())
    before_evidence_count = len(client.get("/evidence").json())
    create_response = client.post(
        "/audit/acknowledgements",
        json={
            "exception_id": policy_exception["id"],
            "exception_source_ref": policy_exception["source_ref"],
            "exception_type": policy_exception["exception_type"],
            "status": "acknowledged",
            "reason": "Reviewed and accepted as intentional.",
            "acknowledged_by": "pytest",
        },
    )
    assert create_response.status_code == 201
    acknowledgement = create_response.json()
    assert acknowledgement["id"].startswith("R19-AUDIT-ACK-")
    assert acknowledgement["exception_id"] == policy_exception["id"]
    assert acknowledgement["exception_source_ref"] == policy_exception["source_ref"]
    assert acknowledgement["exception_type"] == "policy_override"
    assert acknowledgement["status"] == "acknowledged"
    assert acknowledgement["reason"] == "Reviewed and accepted as intentional."
    assert acknowledgement["acknowledged_by"] == "pytest"
    assert acknowledgement["created_at"]
    assert acknowledgement["updated_at"]
    assert acknowledgement["resolved_at"] is None
    assert f"runtime/state/audit_acknowledgements.json#{acknowledgement['id']}" in acknowledgement["evidence_refs"]
    assert any(
        ref.startswith("runtime/state/audit_acknowledgement_history.json#")
        for ref in acknowledgement["evidence_refs"]
    )

    history_response = client.get("/audit/acknowledgement-history")
    assert history_response.status_code == 200
    history = history_response.json()
    assert len(history) == 1
    assert history[0]["acknowledgement_id"] == acknowledgement["id"]
    assert history[0]["exception_id"] == policy_exception["id"]
    assert history[0]["exception_source_ref"] == policy_exception["source_ref"]
    assert history[0]["exception_type"] == "policy_override"
    assert history[0]["previous_status"] is None
    assert history[0]["new_status"] == "acknowledged"
    assert history[0]["reason"] == "Reviewed and accepted as intentional."
    assert history[0]["changed_by"] == "pytest"
    assert history[0]["changed_at"] == acknowledgement["updated_at"]
    assert f"runtime/state/audit_acknowledgement_history.json#{history[0]['id']}" in history[0]["evidence_refs"]

    marker_history_response = client.get(f"/audit/acknowledgements/{acknowledgement['id']}/history")
    assert marker_history_response.status_code == 200
    assert marker_history_response.json() == history

    assert client.get(
        "/audit/acknowledgement-history",
        params={"acknowledgement_id": acknowledgement["id"]},
    ).json() == history
    assert client.get(
        "/audit/acknowledgement-history",
        params={"exception_source_ref": policy_exception["source_ref"]},
    ).json() == history
    assert client.get(
        "/audit/acknowledgement-history",
        params={"exception_type": "policy_override"},
    ).json() == history
    assert client.get(
        "/audit/acknowledgement-history",
        params={"changed_by": "pytest"},
    ).json() == history
    assert client.get(
        "/audit/acknowledgement-history",
        params={"status": "acknowledged"},
    ).json() == history
    assert client.get(
        "/audit/acknowledgement-history",
        params={"q": "accepted as intentional"},
    ).json() == history

    acknowledged_events = [
        event
        for event in client.get("/events").json()
        if event["type"] == "audit_exception_acknowledged"
    ]
    assert len(acknowledged_events) == 1
    assert "Reviewed and accepted as intentional." in acknowledged_events[0]["summary"]
    acknowledgement_evidence = [
        evidence
        for evidence in client.get("/evidence").json()
        if evidence["kind"] == "audit_acknowledgement"
    ]
    assert len(acknowledgement_evidence) == 1
    assert acknowledgement_evidence[0]["path"].endswith(f"#{acknowledgement['id']}")
    assert len(client.get("/events").json()) == before_events_count + 1
    assert len(client.get("/evidence").json()) == before_evidence_count + 1

    enriched_exception = next(
        entry
        for entry in client.get(
            "/audit/exceptions",
            params={"exception_type": "policy_override"},
        ).json()
        if entry["policy_override_id"] == handoff["policy_override_id"]
    )
    assert enriched_exception["acknowledgement_id"] == acknowledgement["id"]
    assert enriched_exception["acknowledgement_status"] == "acknowledged"
    assert enriched_exception["acknowledgement_reason"] == "Reviewed and accepted as intentional."
    assert enriched_exception["acknowledged_by"] == "pytest"
    assert enriched_exception["acknowledged_at"] == acknowledgement["created_at"]
    assert enriched_exception["resolved_at"] is None
    assert enriched_exception["acknowledgement_history_count"] == 1
    assert enriched_exception["latest_acknowledgement_change_at"] == history[0]["changed_at"]

    acknowledged_response = client.get(
        "/audit/exceptions",
        params={"acknowledgement_status": "acknowledged"},
    )
    assert acknowledged_response.status_code == 200
    assert any(
        entry["id"] == policy_exception["id"] for entry in acknowledged_response.json()
    )
    assert all(
        entry["acknowledgement_status"] == "acknowledged"
        for entry in acknowledged_response.json()
    )

    acknowledged_summary = client.get("/audit/summary").json()
    assert acknowledged_summary["acknowledged_exceptions"] == 1
    assert acknowledged_summary["resolved_exceptions"] == 0
    assert acknowledged_summary["dismissed_exceptions"] == 0
    assert acknowledged_summary["unreviewed_exceptions"] >= 1
    assert acknowledged_summary["audit_acknowledgement_history_entries"] == 1
    assert acknowledged_summary["audit_acknowledgements_with_history"] == 1

    reloaded_store = api_main.JsonStateStore(state_dir=api_main.store.state_dir)
    assert reloaded_store.audit_acknowledgements[0]["id"] == acknowledgement["id"]
    assert reloaded_store.audit_acknowledgement_history[0]["id"] == history[0]["id"]

    upsert_response = client.post(
        "/audit/acknowledgements",
        json={
            "exception_id": policy_exception["id"],
            "exception_source_ref": policy_exception["source_ref"],
            "exception_type": policy_exception["exception_type"],
            "status": "dismissed",
            "reason": "Reclassified as not requiring follow-up.",
            "acknowledged_by": "pytest",
        },
    )
    assert upsert_response.status_code == 201
    upserted_acknowledgement = upsert_response.json()
    assert upserted_acknowledgement["id"] == acknowledgement["id"]
    assert upserted_acknowledgement["status"] == "dismissed"
    assert upserted_acknowledgement["reason"] == "Reclassified as not requiring follow-up."
    assert len(client.get("/audit/acknowledgements").json()) == 1
    upsert_history = client.get(f"/audit/acknowledgements/{acknowledgement['id']}/history").json()
    assert len(upsert_history) == 2
    assert [entry["new_status"] for entry in upsert_history] == ["acknowledged", "dismissed"]
    assert upsert_history[1]["previous_status"] == "acknowledged"
    assert upsert_history[1]["reason"] == "Reclassified as not requiring follow-up."
    assert client.get(
        "/audit/acknowledgement-history",
        params={"status": "dismissed"},
    ).json() == [upsert_history[1]]

    patch_response = client.patch(
        f"/audit/acknowledgements/{acknowledgement['id']}",
        json={
            "status": "resolved",
            "reason": "Follow-up completed.",
            "acknowledged_by": "pytest",
        },
    )
    assert patch_response.status_code == 200
    resolved_acknowledgement = patch_response.json()
    assert resolved_acknowledgement["id"] == acknowledgement["id"]
    assert resolved_acknowledgement["status"] == "resolved"
    assert resolved_acknowledgement["reason"] == "Follow-up completed."
    assert resolved_acknowledgement["resolved_at"]
    resolved_history_response = client.get(f"/audit/acknowledgements/{acknowledgement['id']}/history")
    assert resolved_history_response.status_code == 200
    resolved_history = resolved_history_response.json()
    assert len(resolved_history) == 3
    assert [entry["new_status"] for entry in resolved_history] == [
        "acknowledged",
        "dismissed",
        "resolved",
    ]
    assert resolved_history[2]["previous_status"] == "dismissed"
    assert resolved_history[2]["reason"] == "Follow-up completed."
    assert client.get(
        "/audit/acknowledgement-history",
        params={"status": "resolved"},
    ).json() == [resolved_history[2]]
    assert client.get(
        "/audit/acknowledgement-history",
        params={"q": "follow-up completed"},
    ).json() == [resolved_history[2]]

    resolved_events = [
        event
        for event in client.get("/events").json()
        if event["type"] == "audit_exception_resolved"
    ]
    dismissed_events = [
        event
        for event in client.get("/events").json()
        if event["type"] == "audit_exception_dismissed"
    ]
    assert len(resolved_events) == 1
    assert len(dismissed_events) == 1
    assert len(
        [
            evidence
            for evidence in client.get("/evidence").json()
            if evidence["kind"] == "audit_acknowledgement"
        ]
    ) == 3

    unknown_patch_response = client.patch(
        "/audit/acknowledgements/R19-AUDIT-ACK-999",
        json={
            "status": "resolved",
            "reason": "Unknown id coverage.",
            "acknowledged_by": "pytest",
        },
    )
    assert unknown_patch_response.status_code == 404
    unknown_history_response = client.get("/audit/acknowledgements/R19-AUDIT-ACK-999/history")
    assert unknown_history_response.status_code == 404

    resolved_response = client.get(
        "/audit/exceptions",
        params={"acknowledgement_status": "resolved"},
    )
    assert resolved_response.status_code == 200
    assert any(entry["id"] == policy_exception["id"] for entry in resolved_response.json())
    assert all(entry["acknowledgement_status"] == "resolved" for entry in resolved_response.json())

    none_response = client.get(
        "/audit/exceptions",
        params={"acknowledgement_status": "none"},
    )
    assert none_response.status_code == 200
    assert all(not entry.get("acknowledgement_status") for entry in none_response.json())
    assert all(entry["id"] != policy_exception["id"] for entry in none_response.json())

    resolved_summary = client.get("/audit/summary").json()
    assert resolved_summary["acknowledged_exceptions"] == 0
    assert resolved_summary["resolved_exceptions"] == 1
    assert resolved_summary["dismissed_exceptions"] == 0
    assert resolved_summary["audit_acknowledgement_history_entries"] == 3
    assert resolved_summary["audit_acknowledgements_with_history"] == 1
    resolved_enriched_exception = next(
        entry
        for entry in client.get(
            "/audit/exceptions",
            params={"exception_type": "policy_override"},
        ).json()
        if entry["policy_override_id"] == handoff["policy_override_id"]
    )
    assert resolved_enriched_exception["acknowledgement_history_count"] == 3
    assert (
        resolved_enriched_exception["latest_acknowledgement_change_at"]
        == resolved_history[2]["changed_at"]
    )

    json_export_response = client.get(
        "/audit/export",
        params={"format": "json", "acknowledgement_status": "resolved"},
    )
    assert json_export_response.status_code == 200
    json_export = json_export_response.json()
    assert json_export["exceptions"]
    assert json_export["exceptions"][0]["acknowledgement_id"] == acknowledgement["id"]
    assert json_export["exceptions"][0]["acknowledgement_status"] == "resolved"
    assert json_export["exceptions"][0]["acknowledgement_reason"] == "Follow-up completed."
    assert "acknowledgement_history" not in json_export

    history_export_response = client.get(
        "/audit/export",
        params={
            "format": "json",
            "acknowledgement_status": "resolved",
            "include_history": "true",
        },
    )
    assert history_export_response.status_code == 200
    history_export = history_export_response.json()
    assert set(history_export) == {"summary", "exceptions", "acknowledgement_history"}
    assert history_export["acknowledgement_history"] == resolved_history

    csv_export_response = client.get(
        "/audit/export",
        params={"format": "csv", "acknowledgement_status": "resolved"},
    )
    assert csv_export_response.status_code == 200
    csv_text = csv_export_response.text
    assert "acknowledgement_status,acknowledgement_reason" in csv_text
    assert "resolved,Follow-up completed." in csv_text

    assert client.get("/policy-overrides").json() == source_policy_overrides


def test_work_order_qa_readiness_is_ready_with_submitted_developer_result(
    client: TestClient,
) -> None:
    _, work_order = create_card_and_work_order(client, "readiness ready developer result")
    developer_result = client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(summary="Readiness-ready implementation result."),
    ).json()

    response = client.get(f"/work-orders/{work_order['id']}/qa-readiness")

    assert response.status_code == 200
    readiness = response.json()
    assert readiness["ready_for_qa"] is True
    assert readiness["readiness_level"] == "ready"
    assert readiness["warnings"] == []
    assert readiness["blockers"] == []
    assert readiness["latest_developer_result_id"] == developer_result["id"]
    assert readiness["latest_developer_result_summary"] == developer_result["summary"]
    assert readiness["latest_developer_result_status"] == "submitted"


def test_work_order_qa_readiness_missing_work_order_returns_404(client: TestClient) -> None:
    response = client.get("/work-orders/missing/qa-readiness")
    assert response.status_code == 404
    assert "Unknown work-order id" in response.json()["detail"]


def test_work_order_qa_readiness_blocks_existing_active_handoff(
    client: TestClient,
) -> None:
    card, work_order = create_card_and_work_order(client, "readiness active handoff")
    handoff = create_handoff(client, card, work_order, status="proposed")

    proposed_readiness = client.get(f"/work-orders/{work_order['id']}/qa-readiness").json()
    assert proposed_readiness["readiness_level"] == "blocked"
    assert any(handoff["id"] in blocker for blocker in proposed_readiness["blockers"])

    accepted_handoff = client.post(
        f"/handoffs/{handoff['id']}/accept",
        json={"decision_reason": "Accepted by readiness test.", "decided_by": "pytest"},
    ).json()
    accepted_readiness = client.get(f"/work-orders/{work_order['id']}/qa-readiness").json()
    assert accepted_handoff["status"] == "accepted"
    assert accepted_readiness["readiness_level"] == "blocked"
    assert any(handoff["id"] in blocker for blocker in accepted_readiness["blockers"])


def test_duplicate_active_handoff_blocks_in_advisory_and_enforced_policy(
    client: TestClient,
) -> None:
    card, work_order = create_card_and_work_order(client, "duplicate policy active handoff")
    client.post(
        f"/work-orders/{work_order['id']}/developer-result",
        json=valid_developer_result_payload(summary="Duplicate policy developer result."),
    )
    handoff = create_handoff(client, card, work_order, status="proposed")

    advisory_readiness = client.get(f"/work-orders/{work_order['id']}/qa-readiness").json()
    assert advisory_readiness["policy_mode"] == "advisory"
    assert advisory_readiness["readiness_level"] == "blocked"
    assert any(handoff["id"] in blocker for blocker in advisory_readiness["blockers"])

    set_policy(client, mode="enforced", require_original=True)
    enforced_readiness = client.get(f"/work-orders/{work_order['id']}/qa-readiness").json()
    assert enforced_readiness["policy_mode"] == "enforced"
    assert enforced_readiness["readiness_level"] == "blocked"
    assert enforced_readiness["advisory_warnings_promoted_to_blockers"] is False
    assert any(handoff["id"] in blocker for blocker in enforced_readiness["blockers"])


def test_terminal_handoff_with_qa_result_does_not_block_future_repair_readiness(
    client: TestClient,
) -> None:
    _, _, _, failed_qa_result = create_accepted_qa_result(
        client,
        "terminal handoff repair readiness",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{failed_qa_result['id']}/repair-request",
        json=valid_repair_request_payload("terminal handoff repair readiness"),
    ).json()

    repair_readiness = client.get(
        f"/repair-requests/{repair_request['id']}/qa-readiness"
    ).json()

    assert repair_readiness["handoff_context"] == "repair_qa"
    assert repair_readiness["readiness_level"] == "warning"
    assert repair_readiness["blockers"] == []
    assert any(
        "No active repair_qa handoff" in check["detail"]
        for check in repair_readiness["checks"]
        if check["id"] == "no_active_qa_handoff"
    )


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
    assert "Readiness preflight warning" in handoff["validation_summary"]
    assert "No developer result recorded before QA handoff." in handoff["validation_summary"]
    assert "developer_result_id" not in handoff

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

    active_duplicate_response = client.post(f"/work-orders/{work_order['id']}/handoff-to-qa")
    assert active_duplicate_response.status_code == 400
    assert "QA readiness blocked" in active_duplicate_response.json()["detail"]
    assert handoff["id"] in active_duplicate_response.json()["detail"]

    _, reject_work_order = create_card_and_work_order(client, "rejected QA handoff")
    reject_handoff = client.post(f"/work-orders/{reject_work_order['id']}/handoff-to-qa").json()
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


def test_repair_request_qa_readiness_warns_when_repair_developer_result_is_missing(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "repair readiness missing developer result",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair readiness missing developer result"),
    ).json()

    response = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness")

    assert response.status_code == 200
    readiness = response.json()
    assert readiness["work_order_id"] == repair_request["repair_work_order_id"]
    assert readiness["repair_request_id"] == repair_request["id"]
    assert readiness["handoff_context"] == "repair_qa"
    assert readiness["readiness_level"] == "warning"
    assert readiness["ready_for_qa"] is False
    assert readiness["policy_mode"] == "advisory"
    assert readiness["policy_enforced"] is False
    assert readiness["advisory_warnings_promoted_to_blockers"] is False
    assert readiness["blockers"] == []
    assert any("No submitted Developer/Codex result" in item for item in readiness["warnings"])


def test_enforced_policy_blocks_repair_qa_until_repair_developer_result_exists(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "enforced repair policy",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("enforced repair policy"),
    ).json()
    set_policy(client, mode="enforced", require_repair=True)

    readiness_response = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness")

    assert readiness_response.status_code == 200
    readiness = readiness_response.json()
    assert readiness["policy_mode"] == "enforced"
    assert readiness["policy_enforced"] is True
    assert readiness["advisory_warnings_promoted_to_blockers"] is True
    assert readiness["readiness_level"] == "blocked"
    assert "Developer/Codex result is required by current QA handoff policy." in readiness["blockers"]
    assert readiness["overridable_blockers"] == []
    assert readiness["non_overridable_blockers"] == [
        "Developer/Codex result is required by current QA handoff policy."
    ]
    assert readiness["override_available"] is False
    assert any(
        check["id"] == "latest_developer_result_submitted"
        and check["status"] == "blocked"
        for check in readiness["checks"]
    )

    blocked_handoff_response = client.post(f"/repair-requests/{repair_request['id']}/handoff-to-qa")
    assert blocked_handoff_response.status_code == 400
    assert "policy enforcement" in blocked_handoff_response.json()["detail"]

    repair_work_order_id = repair_request["repair_work_order_id"]
    developer_result = client.post(
        f"/work-orders/{repair_work_order_id}/developer-result",
        json=valid_developer_result_payload(
            result_type="repair",
            summary="Required repair implementation result.",
        ),
    ).json()

    ready_response = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness")
    assert ready_response.status_code == 200
    ready_readiness = ready_response.json()
    assert ready_readiness["readiness_level"] == "ready"
    assert ready_readiness["ready_for_qa"] is True
    assert ready_readiness["latest_developer_result_id"] == developer_result["id"]
    assert ready_readiness["advisory_warnings_promoted_to_blockers"] is False

    handoff_response = client.post(f"/repair-requests/{repair_request['id']}/handoff-to-qa")
    assert handoff_response.status_code == 201
    handoff = handoff_response.json()
    assert handoff["developer_result_id"] == developer_result["id"]
    assert "Policy mode: enforced; warnings enforced: no." in handoff["validation_summary"]


def test_operator_override_allows_repair_policy_promoted_missing_developer_result(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "repair policy override",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair policy override"),
    ).json()
    set_policy(client, mode="enforced", require_repair=True, allow_override=True)

    readiness = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness").json()
    assert readiness["handoff_context"] == "repair_qa"
    assert readiness["readiness_level"] == "blocked"
    assert readiness["blockers"] == [api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER]
    assert readiness["overridable_blockers"] == [api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER]
    assert readiness["non_overridable_blockers"] == []
    assert readiness["override_available"] is True

    override_reason = "Operator accepts repair QA handoff without repair Developer/Codex result."
    handoff_response = client.post(
        f"/repair-requests/{repair_request['id']}/handoff-to-qa",
        json={
            "override_policy": True,
            "override_reason": override_reason,
            "requested_by": "pytest",
        },
    )

    assert handoff_response.status_code == 201
    handoff = handoff_response.json()
    assert handoff["handoff_purpose"] == "repair_qa"
    assert handoff["repair_request_id"] == repair_request["id"]
    assert handoff["work_order_id"] == repair_request["repair_work_order_id"]
    assert "developer_result_id" not in handoff
    assert handoff["policy_override_id"].startswith("R19-POLICY-OVERRIDE-")
    assert handoff["policy_override_reason"] == override_reason
    assert "Operator override" in handoff["validation_summary"]

    policy_override = client.get("/policy-overrides").json()[0]
    assert policy_override["id"] == handoff["policy_override_id"]
    assert policy_override["target_type"] == "repair_qa_handoff"
    assert policy_override["target_id"] == repair_request["id"]
    assert policy_override["work_order_id"] == repair_request["repair_work_order_id"]
    assert policy_override["repair_request_id"] == repair_request["id"]
    assert policy_override["overridden_blockers"] == [api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER]
    assert policy_override["non_overridable_blockers"] == []

    assert any(
        event["type"] == "policy_override_recorded"
        and event.get("related_repair_request_id") == repair_request["id"]
        for event in client.get("/events").json()
    )
    assert any(
        entry["kind"] == "policy_override"
        and entry.get("related_repair_request_id") == repair_request["id"]
        for entry in client.get("/evidence").json()
    )


def test_repair_policy_override_does_not_bypass_hard_linkage_blocker(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "repair hard blocker override guard",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair hard blocker override guard"),
    ).json()
    api_main.store.repair_requests[-1]["repair_work_order_id"] = "missing-work-order"
    set_policy(client, mode="enforced", require_repair=True, allow_override=True)

    readiness = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness").json()
    assert readiness["readiness_level"] == "blocked"
    assert api_main.POLICY_MISSING_DEVELOPER_RESULT_BLOCKER in readiness["overridable_blockers"]
    assert readiness["non_overridable_blockers"]
    assert any("missing repair work order" in blocker for blocker in readiness["non_overridable_blockers"])
    assert readiness["override_available"] is False

    response = client.post(
        f"/repair-requests/{repair_request['id']}/handoff-to-qa",
        json={
            "override_policy": True,
            "override_reason": "Operator override must not bypass broken repair linkage.",
            "requested_by": "pytest",
        },
    )

    assert response.status_code == 400
    assert "non-overridable" in response.json()["detail"]
    assert "missing repair work order" in response.json()["detail"]
    assert client.get("/policy-overrides").json() == []


def test_repair_request_qa_readiness_is_ready_when_repair_developer_result_exists(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "repair readiness ready developer result",
        "blocked",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair readiness ready developer result"),
    ).json()
    repair_work_order_id = repair_request["repair_work_order_id"]
    developer_result = client.post(
        f"/work-orders/{repair_work_order_id}/developer-result",
        json=valid_developer_result_payload(
            result_type="repair",
            summary="Readiness-ready repair developer result.",
        ),
    ).json()

    response = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness")

    assert response.status_code == 200
    readiness = response.json()
    assert readiness["readiness_level"] == "ready"
    assert readiness["ready_for_qa"] is True
    assert readiness["warnings"] == []
    assert readiness["blockers"] == []
    assert readiness["latest_developer_result_id"] == developer_result["id"]


def test_repair_request_qa_readiness_missing_repair_request_returns_404(
    client: TestClient,
) -> None:
    response = client.get("/repair-requests/missing/qa-readiness")
    assert response.status_code == 404
    assert "Unknown repair request id" in response.json()["detail"]


def test_repair_request_qa_readiness_invalid_repair_linkage_returns_blocker(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "repair readiness invalid linkage",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair readiness invalid linkage"),
    ).json()
    api_main.store.repair_requests[-1]["repair_work_order_id"] = "missing-work-order"

    response = client.get(f"/repair-requests/{repair_request['id']}/qa-readiness")

    assert response.status_code == 200
    readiness = response.json()
    assert readiness["readiness_level"] == "blocked"
    assert any("missing repair work order" in blocker for blocker in readiness["blockers"])
    assert any(
        check["id"] == "repair_request_work_order_matches"
        and check["status"] == "blocked"
        for check in readiness["checks"]
    )


def test_repair_handoff_without_developer_result_includes_readiness_warning(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "repair handoff warning without developer result",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("repair handoff warning without developer result"),
    ).json()

    response = client.post(f"/repair-requests/{repair_request['id']}/handoff-to-qa")

    assert response.status_code == 201
    handoff = response.json()
    assert handoff["handoff_purpose"] == "repair_qa"
    assert handoff["repair_request_id"] == repair_request["id"]
    assert "developer_result_id" not in handoff
    assert "Readiness preflight warning" in handoff["validation_summary"]
    assert "No developer result recorded before QA handoff." in handoff["validation_summary"]


def test_duplicate_active_repair_handoff_blocks_in_advisory_and_enforced_policy(
    client: TestClient,
) -> None:
    _, _, _, qa_result = create_accepted_qa_result(
        client,
        "duplicate repair policy active handoff",
        "failed",
    )
    repair_request = client.post(
        f"/qa-results/{qa_result['id']}/repair-request",
        json=valid_repair_request_payload("duplicate repair policy active handoff"),
    ).json()
    repair_work_order_id = repair_request["repair_work_order_id"]
    client.post(
        f"/work-orders/{repair_work_order_id}/developer-result",
        json=valid_developer_result_payload(
            result_type="repair",
            summary="Duplicate repair policy developer result.",
        ),
    )
    handoff = client.post(f"/repair-requests/{repair_request['id']}/handoff-to-qa").json()

    advisory_readiness = client.get(
        f"/repair-requests/{repair_request['id']}/qa-readiness"
    ).json()
    assert advisory_readiness["policy_mode"] == "advisory"
    assert advisory_readiness["readiness_level"] == "blocked"
    assert any(handoff["id"] in blocker for blocker in advisory_readiness["blockers"])

    set_policy(client, mode="enforced", require_repair=True)
    enforced_readiness = client.get(
        f"/repair-requests/{repair_request['id']}/qa-readiness"
    ).json()
    assert enforced_readiness["policy_mode"] == "enforced"
    assert enforced_readiness["readiness_level"] == "blocked"
    assert enforced_readiness["advisory_warnings_promoted_to_blockers"] is False
    assert any(handoff["id"] in blocker for blocker in enforced_readiness["blockers"])


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

    repair_developer_result_response = client.post(
        f"/work-orders/{repair_work_order_id}/developer-result",
        json=valid_developer_result_payload(
            result_type="repair",
            summary="Repair implementation result captured before QA.",
            changed_paths=["services/orchestrator-api/app/main.py"],
        ),
    )
    assert repair_developer_result_response.status_code == 201
    repair_developer_result = repair_developer_result_response.json()
    assert repair_developer_result["work_order_id"] == repair_work_order_id
    assert repair_developer_result["result_type"] == "repair"

    repair_handoff_response = client.post(
        f"/repair-requests/{repair_request['id']}/handoff-to-qa"
    )
    assert repair_handoff_response.status_code == 201
    repair_handoff = repair_handoff_response.json()
    assert repair_handoff["status"] == "proposed"
    assert repair_handoff["work_order_id"] == repair_work_order_id
    assert repair_handoff["repair_request_id"] == repair_request["id"]
    assert repair_handoff["qa_result_id"] == failed_qa_result["id"]
    assert repair_handoff["developer_result_id"] == repair_developer_result["id"]
    assert repair_handoff["developer_result_summary"] == repair_developer_result["summary"]
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
    assert "missing repair work order" in invalid_response.json()["detail"]


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
