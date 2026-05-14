# AIOffice Orchestrator API

Minimal FastAPI backend for the R19 product reset UI/API slice.

## Setup

```powershell
cd services/orchestrator-api
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

On Unix-like shells:

```bash
cd services/orchestrator-api
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run

```bash
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

## Endpoints

- `GET /status`
- `GET /state/health`
- `GET /state/export`
- `POST /state/compare-import`
- `POST /state/import`
- `POST /state/reset-demo`
- `GET /policy-settings`
- `GET /policy-overrides`
- `PATCH /policy-settings`
- `GET /audit/summary`
- `GET /audit/acknowledgements`
- `GET /audit/acknowledgement-history`
- `GET /audit/acknowledgements/{id}/history`
- `POST /audit/acknowledgements`
- `PATCH /audit/acknowledgements/{id}`
- `GET /audit/exceptions`
- `GET /audit/export`
- `GET /cards`
- `POST /cards`
- `PATCH /cards/{id}/status`
- `GET /work-orders`
- `POST /work-orders`
- `GET /work-orders/{id}/qa-readiness`
- `GET /developer-results`
- `POST /work-orders/{id}/developer-result`
- `POST /developer-results/{id}/supersede`
- `PATCH /work-orders/{id}/status`
- `POST /work-orders/{id}/handoff-to-qa`
- `GET /workflow-iterations`
- `GET /agents`
- `GET /events`
- `GET /evidence`
- `GET /approvals`
- `POST /approvals`
- `POST /approvals/{id}/approve`
- `POST /approvals/{id}/reject`
- `GET /handoffs`
- `POST /handoffs`
- `POST /handoffs/{id}/accept`
- `POST /handoffs/{id}/reject`
- `GET /qa-results`
- `POST /handoffs/{id}/qa-result`
- `GET /repair-requests`
- `GET /repair-requests/{id}/qa-readiness`
- `POST /qa-results/{id}/repair-request`
- `POST /repair-requests/{id}/handoff-to-qa`
- `POST /repair-requests/{id}/complete`
- `POST /repair-requests/{id}/cancel`

Status update request body:

```json
{
  "status": "planned",
  "reason": "Short optional reason",
  "requested_by": "operator"
}
```

Allowed card statuses: `intake`, `planned`, `in_progress`, `blocked`, `done`, `archived`.

Allowed work-order statuses: `draft`, `ready`, `running`, `waiting_approval`, `approved`, `rejected`, `completed`, `blocked`, `cancelled`.

Allowed handoff statuses: `proposed`, `accepted`, `rejected`, `completed`, `blocked`.

Allowed QA result values: `passed`, `failed`, `blocked`.

Allowed repair request statuses: `proposed`, `created`, `in_progress`, `completed`, `cancelled`.

Allowed Developer/Codex result types: `implementation`, `repair`, `documentation`, `validation`, `other`.

Allowed Developer/Codex result statuses: `draft`, `submitted`, `superseded`.

Allowed QA handoff policy modes: `advisory`, `enforced`.

Invalid status values return HTTP 400. Unknown card or work-order IDs return HTTP 404.

`GET /policy-settings` returns the persisted QA handoff policy model from `runtime/state/policy_settings.json`, falling back to `runtime/state/policy_settings.seed.json`.

`PATCH /policy-settings` updates the small product policy setting used by QA readiness and handoff creation. It validates policy mode and boolean fields, persists the JSON settings, writes a `policy_settings_updated` event, and writes `policy_settings` evidence.

Policy settings request body:

```json
{
  "qa_handoff_policy_mode": "enforced",
  "require_developer_result_for_qa": true,
  "require_developer_result_for_repair_qa": true,
  "allow_operator_override": false,
  "updated_by": "operator"
}
```

In `advisory` mode, missing Developer/Codex result capture remains a warning and does not block original or repair QA handoff creation. In `enforced` mode, missing Developer/Codex result capture becomes a blocker for original QA when `require_developer_result_for_qa` is true, and for repair QA when `require_developer_result_for_repair_qa` is true. When `allow_operator_override` is true, the readiness response can expose an override option only for that policy-promoted missing-result blocker. The flag does not bypass duplicate active handoffs, missing records, broken repair linkage, invalid repair work orders, or any other hard blocker.

`GET /policy-overrides` returns logged override records from `runtime/state/policy_overrides.json`, falling back to `runtime/state/policy_overrides.seed.json`.

`GET /audit/summary` returns a derived summary for operator exception review. Counts include policy overrides, override-backed handoffs, policy settings changes, failed and blocked QA results, repair requests, open and completed repairs, hard-blocker events when derivable from events, readiness blockers when derivable from current readiness, acknowledgement counts (`acknowledged_exceptions`, `resolved_exceptions`, `dismissed_exceptions`, `unreviewed_exceptions`), acknowledgement history counts (`audit_acknowledgement_history_entries`, `audit_acknowledgements_with_history`), and `generated_at`.

`GET /audit/acknowledgements` returns persisted lightweight triage markers from `runtime/state/audit_acknowledgements.json`, falling back to `runtime/state/audit_acknowledgements.seed.json`.

`POST /audit/acknowledgements` creates or updates one marker for an audit exception. `status` must be `acknowledged`, `resolved`, or `dismissed`; `reason` is required and must be non-empty; `acknowledged_by` defaults to `operator`; and either `exception_source_ref` or `exception_id` is required. POST uses upsert semantics for the same `exception_source_ref` when present, falling back to `exception_id` when no source ref is supplied. It does not mutate the underlying exception source record.

Create body:

```json
{
  "exception_id": "audit-policy-override-R19-POLICY-OVERRIDE-001",
  "exception_source_ref": "runtime/state/policy_overrides.json#R19-POLICY-OVERRIDE-001",
  "exception_type": "policy_override",
  "status": "acknowledged",
  "reason": "Reviewed and accepted as intentional.",
  "acknowledged_by": "operator"
}
```

`PATCH /audit/acknowledgements/{id}` updates an existing marker's `status`, `reason`, `acknowledged_by`, `updated_at`, and `resolved_at` when the status is `resolved`. Unknown acknowledgement ids return HTTP 404.

Patch body:

```json
{
  "status": "resolved",
  "reason": "Follow-up completed.",
  "acknowledged_by": "operator"
}
```

Acknowledgement create/update writes `audit_exception_acknowledged`, `audit_exception_resolved`, or `audit_exception_dismissed` events plus `audit_acknowledgement` evidence. Every create, upsert, or patch also appends one entry to `runtime/state/audit_acknowledgement_history.json`; previous history entries are not deleted or rewritten. History entries record `previous_status`, `new_status`, reason, changed by, changed at, exception refs, and evidence refs.

`GET /audit/acknowledgement-history` returns the append-only acknowledgement history sorted oldest to newest. Filters are `acknowledgement_id`, `exception_source_ref`, `exception_type`, `status` matching `new_status`, `changed_by`, free-text `q` across reason/id/source/type/status fields, `limit` defaulting to `100`, and `offset` defaulting to `0`.

`GET /audit/acknowledgements/{id}/history` returns the oldest-to-newest trail for one marker. Unknown acknowledgement ids return HTTP 404.

`GET /audit/exceptions` returns derived audit exception entries from existing JSON state enriched with acknowledgement fields when a marker matches by `source_ref` or exception id. Reviewed exceptions also include `acknowledgement_history_count` and `latest_acknowledgement_change_at`. Supported filters are `exception_type`, `severity`, `acknowledgement_status`, `card_id`, `work_order_id`, `handoff_id`, and free-text `q`; `acknowledgement_status=none` returns only exceptions without a marker. `q` searches titles, summaries, related ids, source refs, override reasons carried in summaries, and acknowledgement status/reason. `limit` defaults to `100`, `offset` defaults to `0`, `limit` must be between `1` and `500`, and `offset` must be `>= 0`; invalid pagination values return HTTP 400.

Audit exception types currently include `policy_override`, `policy_settings_change`, `qa_failed`, `qa_blocked`, `repair_request_created`, `handoff_without_developer_result`, `duplicate_handoff_blocked`, and `readiness_blocker`. Severities are `info`, `warning`, `blocker`, and `override`.

`GET /audit/export` supports the same filters plus `format=json` or `format=csv`. JSON returns `{ "summary": ..., "exceptions": [...] }` including acknowledgement fields. Add `include_history=true` to JSON export to include `acknowledgement_history` entries for the exported reviewed exceptions. CSV remains latest-marker only with core fields plus `acknowledgement_status` and `acknowledgement_reason`. Invalid export formats return HTTP 400. This is a lightweight operator review endpoint with triage markers and append-only triage history, not external audit acceptance, not ticketing, and not a reporting engine.

`POST /work-orders/{id}/developer-result` records a submitted Developer/Codex result for a work order before QA handoff. Missing work orders return HTTP 404. Unknown `agent_id`, invalid `result_type`, and non-list `changed_paths` return HTTP 400. A submitted result writes `developer_result_recorded` event/evidence and can move a simple `draft`, `running`, or `approved` work order to `ready` with `work_order_ready_from_developer_result`. Duplicate submitted results for the same work order are rejected until the current result is superseded.

Developer result request body:

```json
{
  "result_type": "implementation",
  "summary": "Implementation summary",
  "changed_paths": ["apps/operator-ui/src/App.tsx"],
  "notes": "Additional notes",
  "agent_id": "developer_codex"
}
```

`POST /developer-results/{id}/supersede` marks an existing result as `superseded`, records event/evidence, and allows a replacement submitted result to be recorded later. It does not inspect git diffs and does not invoke Codex/OpenAI.

`POST /handoffs` validates source and target agents, the card, the work order, and that the work order belongs to the card. `POST /work-orders/{id}/handoff-to-qa` is the first product-facing convenience flow: it creates a `developer_codex` to `qa_test` handoff with `source_role` `Developer/Codex` and `target_role` `QA/Test`. Original work-order handoffs use `handoff_purpose: initial_qa`. Repair work-order handoffs are detected from `work_order_type: repair` or `repair_request_id` and use the repair QA behavior. Accepting or rejecting a handoff records the operator decision but does not invoke AI, call Codex/OpenAI APIs, or run autonomous agents.

QA handoff creation attaches the latest submitted Developer/Codex result for the work order as `developer_result_id` and `developer_result_summary` when one exists. Handoffs are still allowed without a developer result in advisory mode, but `validation_summary` records `No developer result recorded before QA handoff.` as a visible soft warning. In enforced mode, configured missing-result blockers return HTTP 400 before the handoff record is created unless the immediate handoff request includes a valid operator override and there are no non-overridable blockers.

The convenience handoff endpoints accept an optional body:

```json
{
  "override_policy": true,
  "override_reason": "Operator accepts QA handoff without Developer/Codex result for this case.",
  "requested_by": "operator"
}
```

`override_reason` is required and must be non-empty when `override_policy` is true. A valid override creates a `policy_override` record, writes `policy_override_recorded` event/evidence, proceeds with handoff creation, and sets `policy_override_id` plus `policy_override_reason` on the handoff. Overrides are immediate request exceptions only; they do not change policy settings and are not reusable permissions.

`GET /work-orders/{id}/qa-readiness` and `GET /repair-requests/{id}/qa-readiness` return a derived, read-only readiness/preflight response. Unknown work orders or repair requests return HTTP 404. Readiness levels are `ready`, `warning`, and `blocked`; individual checks are `passed`, `warning`, or `blocked`. Responses include `policy_mode`, `policy_enforced`, `advisory_warnings_promoted_to_blockers`, `overridable_blockers`, `non_overridable_blockers`, and `override_available`. Missing Developer/Codex result capture is a warning in advisory mode. In enforced mode, the missing-result check becomes blocked only when the relevant policy requirement flag is true. Missing card/work-order/repair linkage, invalid repair work-order linkage, missing assigned agent, cancelled/rejected work-order state, or an active duplicate proposed/accepted QA handoff is a blocker in all modes and is classified as non-overridable. GET readiness calls do not create events or evidence.

The convenience handoff endpoints reuse readiness before creating QA handoffs. Warning-level readiness remains advisory and does not block handoff creation. Blocker-level readiness returns HTTP 400. Policy-promoted blockers mention policy enforcement in the HTTP 400 detail. Active accepted/proposed handoffs are considered duplicate blockers only until a QA result exists for that handoff. An override may bypass only the policy-promoted missing Developer/Codex result blocker when `override_available` is true.

`POST /handoffs/{id}/qa-result` records a structured QA/Test result only after a handoff is accepted. Missing handoff IDs return HTTP 404. Proposed, rejected, blocked, or completed handoffs return HTTP 400. Duplicate QA results for the same handoff return HTTP 400. Invalid QA result values return HTTP 400.

QA result request body:

```json
{
  "result": "passed",
  "summary": "QA result summary",
  "findings": "Detailed findings",
  "recommended_next_action": "Complete work order / repair / block",
  "qa_agent_id": "qa_test"
}
```

QA result status mapping is intentionally small: `passed` can move the linked work order to `completed`; `failed` and `blocked` can move it to `blocked`. This is a local operator/API state transition, not live QA agent execution.

`POST /qa-results/{id}/repair-request` creates a repair request only for failed or blocked QA results. Missing QA results return HTTP 404, passed QA results return HTTP 400, and duplicate repair requests for the same QA result return HTTP 400. The endpoint also creates a linked repair work order assigned to `developer_codex` by default. The repair work order is created with status `ready`, because it is ready for a manual Developer/Codex implementation pass and does not require another approval gate in this narrow slice.

Repair request body:

```json
{
  "summary": "Repair summary",
  "repair_instructions": "What Developer/Codex should repair",
  "requested_by": "operator",
  "assigned_agent_id": "developer_codex"
}
```

Completing or cancelling a repair request updates only the repair request state and records events/evidence. It does not automatically re-run QA or create a new handoff.

`POST /repair-requests/{id}/handoff-to-qa` creates a proposed repair QA handoff for a linked repair work order. Missing repair requests return HTTP 404. The repair request must be `created`, `in_progress`, or `completed`; the linked repair work order must exist and be `ready` or `completed`. The handoff uses `handoff_purpose: repair_qa`, links `repair_request_id`, carries the failed or blocked source `qa_result_id`, and sets `iteration_number` to the repair iteration. Duplicate active repair QA handoffs for the same repair request/work order return HTTP 400 with the existing handoff id and status.

Accepted repair QA handoffs use the same `POST /handoffs/{id}/qa-result` endpoint as initial QA handoffs. A passed repair QA result can move the repair work order to `completed`; failed or blocked can move it to `blocked`. The source repair request is not automatically completed by the handoff flow. Failed or blocked repair QA results can be used by the operator to create another repair request through the existing repair request endpoint.

`GET /workflow-iterations` returns a lightweight read-only view derived from work orders, handoffs, QA results, and repair requests. It is not persisted as a separate workflow model. Each item shows the original work order, current work order, work-order type, repair request, latest handoff, latest QA result, iteration number, and status summary.

## JSON Persistence

The API loads persistent JSON files from `runtime/state/*.json` when present. If a persistent file is missing, it falls back to the matching seed file, for example `cards.seed.json`.

Set `AIO_STATE_DIR` before importing or starting the app to use an alternate state directory for smoke tests.

Local state management endpoints:

- `GET /state/health` returns a read-only derived health model for known JSON collections. It reports the state directory, `persistence_mode: json`, seed/persistent file presence, record counts, JSON validity, warnings, blockers, totals, and `safe_to_reset`. Missing persistent files are seed-fallback warnings, not blockers. Missing required seed files and invalid JSON are blockers. The endpoint does not write events or evidence.
- `GET /state/export` returns a direct JSON payload with `export_id`, `exported_at`, `persistence_mode`, `state_dir`, collection payloads, collection source (`persistent` or `seed`), record counts, and non-claims. It does not include logs, virtualenvs, `node_modules`, backups, or unrelated files.
- `POST /state/compare-import` accepts the same collection object or exported collection array shape as import and returns a read-only preview. It reports collection-level current/incoming counts, added/removed/changed/unchanged counts, top-level warning/blocker counts, `safe_to_import`, and up to five sample ids for each added/removed/changed category. Changed means the same id has different normalized JSON with sorted keys; no deep field diff is generated. Object collections such as `status` and `policy_settings` compare as a single object with the collection name as id. Records without `id` are compared by list index and receive a limitation warning. Unknown collections are reported as blockers because the current import endpoint rejects them. The endpoint does not write state, events, or evidence.
- `POST /state/import` accepts either a `collections` object keyed by known collection name or the exported collection array from `GET /state/export`. It lightly validates known collection names and array/object shape, writes persistent `runtime/state/*.json` files for supplied collections, preserves seed files, and writes `state_imported` event plus `state_management` evidence.
- `POST /state/reset-demo` requires the exact confirmation string `RESET_R19_DEMO_STATE`. Wrong or missing confirmation returns HTTP 400 and does nothing. Correct confirmation removes only known persistent `runtime/state/<collection>.json` files, preserves `*.seed.json`, reloads seed state, and writes a fresh `state_reset` event plus `state_management` evidence.

These endpoints are local developer/demo-state management only. The compare flow is local JSON demo-state import preview, not production backup/restore, migration tooling, a database migration framework, autonomous agent execution, external audit acceptance, or a proof-package system.

Mutating endpoints write back to:

- `runtime/state/status.json`
- `runtime/state/cards.json`
- `runtime/state/work_orders.json`
- `runtime/state/events.json`
- `runtime/state/evidence.json`
- `runtime/state/approvals.json`
- `runtime/state/handoffs.json`
- `runtime/state/developer_results.json`
- `runtime/state/qa_results.json`
- `runtime/state/repair_requests.json`
- `runtime/state/policy_settings.json`
- `runtime/state/policy_overrides.json`
- `runtime/state/audit_acknowledgements.json`
- `runtime/state/audit_acknowledgement_history.json`

Creating cards and work orders writes event and evidence entries. Work orders must link to an existing `card_id`; invalid card IDs return HTTP 400 with a clear message. Work orders can request an approval gate with `request_requires_approval: true`.

Card and work-order status changes persist to JSON and write `status_transition` evidence plus `*_status_changed` events. Moving a work order to `waiting_approval` creates a pending approval when one is not already pending for that work order. Approving or rejecting a linked pending approval can move a work order from `waiting_approval` to `approved` or `rejected`.

Handoff create/accept/reject actions persist to JSON and write `handoff_*` events plus `handoff_record` or `handoff_decision` evidence.

Developer result capture persists to `developer_results.json`, updates developer-result pointers on the work order, and writes `developer_result` evidence. Superseding a result writes `developer_result_superseded` and removes the work order's latest submitted result pointer when no replacement exists.

QA result capture persists to JSON and writes `qa_result_recorded` events plus `qa_result` evidence. When the simple status mapping applies, the API also writes `work_order_completed_from_qa` or `work_order_blocked_from_qa` events.

Repair request creation persists to JSON, creates a linked `ready` repair work order, and writes `repair_request_created`, `repair_work_order_created`, `repair_request`, and `repair_work_order` records. Completing or cancelling writes `repair_request_completed` or `repair_request_cancelled` plus `repair_request` evidence.

Repair QA handoff creation persists to `handoffs.json` and writes `repair_handoff_created`, `repair_handoff`, and `workflow_iteration` records. Repair QA result capture persists to `qa_results.json` and writes `repair_qa_result_recorded`, `repair_iteration_passed`/`repair_iteration_failed`/`repair_iteration_blocked`, `repair_qa_result`, and `workflow_iteration` records.

Policy settings updates persist to `policy_settings.json` and write `policy_settings_updated` plus `policy_settings` evidence. Policy overrides persist to `policy_overrides.json` and write `policy_override_recorded` plus `policy_override` evidence. Audit acknowledgement triage markers persist to `audit_acknowledgements.json`, append history to `audit_acknowledgement_history.json`, and write `audit_exception_*` events plus `audit_acknowledgement` evidence. This is a product policy setting, narrow logged exception path, and lightweight audit triage layer, not a governance document flow, full policy engine, ticketing system, or external audit acceptance.

Most audit review endpoints remain read-only. `GET /audit/summary`, `GET /audit/exceptions`, `GET /audit/acknowledgement-history`, `GET /audit/acknowledgements/{id}/history`, and `GET /audit/export` derive their payloads from the current JSON state and do not append events or write evidence. Only `/audit/acknowledgements` persists the lightweight triage marker, append-only history row, and event/evidence record.

## Test and Smoke Commands

Backend regression harness:

```bash
python -m pytest services/orchestrator-api/tests
```

The pytest harness covers seed reads, state health read-only behavior, state export non-claims, compare-import read-only behavior, unchanged current-export preview, added/changed/removed card counts and sample ids, invalid compare payloads, object collection comparison for `policy_settings`, import after compare, guarded reset wrong-confirm no-op behavior, reset-to-seed behavior, import writes and validation errors, imported card/work-order reads, state import/reset event/evidence writes, invalid JSON health blockers, policy settings defaults/update/persistence/invalid modes/event/evidence writes, policy override listing/persistence/event/evidence writes, override-available readiness classification, empty override reason rejection, successful original and repair override handoffs, duplicate active handoff non-overridable blockers, repair linkage non-overridable blockers, audit summary shape/counts including history counts, filterable audit exceptions, audit JSON/CSV export, JSON export with optional history, invalid audit export formats, audit pagination validation, audit GET endpoint read-only behavior, audit acknowledgement create/update validation, acknowledgement event/evidence writes, acknowledgement history append/filter/endpoints/404s, acknowledgement and history persistence across `JsonStateStore` reload, acknowledgement filters/counts/export fields, source exception non-mutation, card/work-order/status updates, approvals, Developer/Codex result validation/capture/supersede/persistence, QA readiness advisory warning/ready/blocker paths, enforced policy promotion for original and repair QA, handoff endpoint enforcement, duplicate active handoff blockers in advisory and enforced modes, repair QA readiness warning/ready/blocker paths, readiness 404s, QA handoff developer-result references and soft warnings, QA result creation/error paths, repair request creation/error paths, linked repair work-order creation, repair QA handoff/result iteration flow, workflow iteration derivation, event/evidence writes, JSON persistence, repair completion/cancellation, and the small QA-result-to-work-order status mapping.

Backend import smoke from the service directory:

```bash
cd services/orchestrator-api
python -c "from app.main import app; print(app.title)"
```

Live API smoke after starting the backend:

```bash
curl http://127.0.0.1:8000/status
curl http://127.0.0.1:8000/state/health
curl http://127.0.0.1:8000/state/export
curl -X POST http://127.0.0.1:8000/state/compare-import -H "Content-Type: application/json" -d "{\"collections\":{\"cards\":[{\"id\":\"R19-CARD-900\",\"title\":\"Preview smoke card\",\"summary\":\"Preview smoke card.\",\"status\":\"planned\",\"owner_agent_id\":\"orchestrator\",\"owner_role\":\"operator\",\"priority\":\"medium\"}]},\"compare_reason\":\"Live smoke import preview.\",\"requested_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/state/reset-demo -H "Content-Type: application/json" -d "{\"reset_reason\":\"Wrong confirmation smoke.\",\"requested_by\":\"operator\",\"confirm\":\"RESET\"}"
curl -X POST http://127.0.0.1:8000/state/import -H "Content-Type: application/json" -d "{\"collections\":{\"cards\":[{\"id\":\"R19-CARD-900\",\"title\":\"Imported smoke card\",\"summary\":\"Imported smoke card.\",\"status\":\"planned\",\"owner_agent_id\":\"orchestrator\",\"owner_role\":\"operator\",\"priority\":\"medium\"}],\"work_orders\":[{\"id\":\"R19-WO-900\",\"card_id\":\"R19-CARD-900\",\"title\":\"Imported smoke work order\",\"summary\":\"Imported smoke work order.\",\"status\":\"ready\",\"requested_by_agent_id\":\"orchestrator\",\"assigned_agent_id\":\"developer_codex\",\"approval_required\":false,\"request_requires_approval\":false,\"evidence_refs\":[],\"iteration_number\":1,\"work_order_type\":\"original\"}]},\"import_reason\":\"Live smoke import.\",\"requested_by\":\"operator\"}"
curl http://127.0.0.1:8000/cards
curl -X POST http://127.0.0.1:8000/state/reset-demo -H "Content-Type: application/json" -d "{\"reset_reason\":\"Live smoke reset.\",\"requested_by\":\"operator\",\"confirm\":\"RESET_R19_DEMO_STATE\"}"
curl http://127.0.0.1:8000/policy-settings
curl -X PATCH http://127.0.0.1:8000/policy-settings -H "Content-Type: application/json" -d "{\"qa_handoff_policy_mode\":\"advisory\",\"require_developer_result_for_qa\":false,\"require_developer_result_for_repair_qa\":false,\"allow_operator_override\":false,\"updated_by\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/policy-settings -H "Content-Type: application/json" -d "{\"qa_handoff_policy_mode\":\"invalid\",\"require_developer_result_for_qa\":true,\"require_developer_result_for_repair_qa\":true,\"allow_operator_override\":false,\"updated_by\":\"operator\"}"
curl http://127.0.0.1:8000/developer-results
curl http://127.0.0.1:8000/workflow-iterations
curl http://127.0.0.1:8000/handoffs
curl http://127.0.0.1:8000/qa-results
curl http://127.0.0.1:8000/repair-requests
curl -X POST http://127.0.0.1:8000/cards -H "Content-Type: application/json" -d "{\"title\":\"Smoke card\",\"description\":\"Smoke\",\"priority\":\"medium\",\"owner_role\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/cards/R19-CARD-002/status -H "Content-Type: application/json" -d "{\"status\":\"planned\",\"requested_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/work-orders -H "Content-Type: application/json" -d "{\"card_id\":\"R19-CARD-002\",\"title\":\"Smoke work order\",\"description\":\"Smoke work order\",\"assigned_agent_id\":\"developer_codex\",\"request_requires_approval\":false}"
curl http://127.0.0.1:8000/work-orders/R19-WO-002/qa-readiness
curl -X PATCH http://127.0.0.1:8000/policy-settings -H "Content-Type: application/json" -d "{\"qa_handoff_policy_mode\":\"enforced\",\"require_developer_result_for_qa\":true,\"require_developer_result_for_repair_qa\":false,\"allow_operator_override\":false,\"updated_by\":\"operator\"}"
curl http://127.0.0.1:8000/work-orders/R19-WO-002/qa-readiness
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-002/handoff-to-qa
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-002/developer-result -H "Content-Type: application/json" -d "{\"result_type\":\"implementation\",\"summary\":\"Smoke implementation result.\",\"changed_paths\":[\"apps/operator-ui/src/App.tsx\"],\"notes\":\"Manual smoke result.\",\"agent_id\":\"developer_codex\"}"
curl http://127.0.0.1:8000/work-orders/R19-WO-002/qa-readiness
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-002/handoff-to-qa
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-001/accept -H "Content-Type: application/json" -d "{\"decision_reason\":\"Accepted for QA smoke.\",\"decided_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-001/qa-result -H "Content-Type: application/json" -d "{\"result\":\"failed\",\"summary\":\"QA failed.\",\"findings\":\"Repair needed.\",\"recommended_next_action\":\"Create repair work order.\",\"qa_agent_id\":\"qa_test\"}"
curl -X POST http://127.0.0.1:8000/qa-results/R19-QA-RESULT-001/repair-request -H "Content-Type: application/json" -d "{\"summary\":\"Repair failed QA\",\"repair_instructions\":\"Fix the failed QA path.\",\"requested_by\":\"operator\",\"assigned_agent_id\":\"developer_codex\"}"
curl http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/qa-readiness
curl -X PATCH http://127.0.0.1:8000/policy-settings -H "Content-Type: application/json" -d "{\"qa_handoff_policy_mode\":\"enforced\",\"require_developer_result_for_qa\":true,\"require_developer_result_for_repair_qa\":true,\"allow_operator_override\":false,\"updated_by\":\"operator\"}"
curl http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/qa-readiness
curl -X POST http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/handoff-to-qa
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-003/developer-result -H "Content-Type: application/json" -d "{\"result_type\":\"repair\",\"summary\":\"Smoke repair result.\",\"changed_paths\":[\"apps/operator-ui/src/App.tsx\"],\"notes\":\"Manual smoke repair result.\",\"agent_id\":\"developer_codex\"}"
curl http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/qa-readiness
curl -X POST http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/handoff-to-qa
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-002/accept -H "Content-Type: application/json" -d "{\"decision_reason\":\"Accepted repair QA smoke.\",\"decided_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-002/qa-result -H "Content-Type: application/json" -d "{\"result\":\"passed\",\"summary\":\"Repair QA passed.\",\"findings\":\"Repair verified.\",\"recommended_next_action\":\"Complete repair work order.\",\"qa_agent_id\":\"qa_test\"}"
curl http://127.0.0.1:8000/audit/summary
curl http://127.0.0.1:8000/audit/exceptions
curl "http://127.0.0.1:8000/audit/exceptions?exception_type=policy_override"
curl "http://127.0.0.1:8000/audit/exceptions?acknowledgement_status=none"
curl "http://127.0.0.1:8000/audit/exceptions?severity=override"
curl "http://127.0.0.1:8000/audit/exceptions?q=Smoke"
curl http://127.0.0.1:8000/audit/acknowledgements
curl -X POST http://127.0.0.1:8000/audit/acknowledgements -H "Content-Type: application/json" -d "{\"exception_id\":\"audit-policy-override-R19-POLICY-OVERRIDE-001\",\"exception_source_ref\":\"runtime/state/policy_overrides.json#R19-POLICY-OVERRIDE-001\",\"exception_type\":\"policy_override\",\"status\":\"acknowledged\",\"reason\":\"Reviewed and accepted as intentional.\",\"acknowledged_by\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/audit/acknowledgements/R19-AUDIT-ACK-001 -H "Content-Type: application/json" -d "{\"status\":\"resolved\",\"reason\":\"Follow-up completed.\",\"acknowledged_by\":\"operator\"}"
curl http://127.0.0.1:8000/audit/acknowledgement-history
curl "http://127.0.0.1:8000/audit/acknowledgement-history?acknowledgement_id=R19-AUDIT-ACK-001"
curl "http://127.0.0.1:8000/audit/acknowledgement-history?exception_source_ref=runtime/state/policy_overrides.json%23R19-POLICY-OVERRIDE-001"
curl "http://127.0.0.1:8000/audit/acknowledgement-history?exception_type=policy_override"
curl "http://127.0.0.1:8000/audit/acknowledgement-history?status=resolved"
curl "http://127.0.0.1:8000/audit/acknowledgement-history?q=Follow-up"
curl http://127.0.0.1:8000/audit/acknowledgements/R19-AUDIT-ACK-001/history
curl http://127.0.0.1:8000/audit/acknowledgements/R19-AUDIT-ACK-999/history
curl -X POST http://127.0.0.1:8000/audit/acknowledgements -H "Content-Type: application/json" -d "{\"exception_id\":\"audit-policy-override-R19-POLICY-OVERRIDE-001\",\"exception_source_ref\":\"runtime/state/policy_overrides.json#R19-POLICY-OVERRIDE-001\",\"exception_type\":\"policy_override\",\"status\":\"acknowledged\",\"reason\":\"\",\"acknowledged_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/audit/acknowledgements -H "Content-Type: application/json" -d "{\"exception_id\":\"audit-policy-override-R19-POLICY-OVERRIDE-001\",\"exception_source_ref\":\"runtime/state/policy_overrides.json#R19-POLICY-OVERRIDE-001\",\"exception_type\":\"policy_override\",\"status\":\"reviewed\",\"reason\":\"Invalid status coverage.\",\"acknowledged_by\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/audit/acknowledgements/R19-AUDIT-ACK-999 -H "Content-Type: application/json" -d "{\"status\":\"resolved\",\"reason\":\"Unknown id coverage.\",\"acknowledged_by\":\"operator\"}"
curl "http://127.0.0.1:8000/audit/exceptions?acknowledgement_status=resolved"
curl "http://127.0.0.1:8000/audit/export?format=json"
curl "http://127.0.0.1:8000/audit/export?format=json&include_history=true"
curl "http://127.0.0.1:8000/audit/export?format=csv"
curl "http://127.0.0.1:8000/audit/export?format=xml"
curl http://127.0.0.1:8000/events
curl http://127.0.0.1:8000/evidence
```

## Reset Local Demo State

Preferred reset path while the API is running:

```bash
curl -X POST http://127.0.0.1:8000/state/reset-demo -H "Content-Type: application/json" -d "{\"reset_reason\":\"Resetting local demo state\",\"requested_by\":\"operator\",\"confirm\":\"RESET_R19_DEMO_STATE\"}"
```

The endpoint deletes only known persistent `runtime/state/<collection>.json` files, preserves `*.seed.json`, and writes fresh `state_reset` event/evidence. The hard guard is the exact `RESET_R19_DEMO_STATE` confirmation string.

Manual cleanup is still possible if the API is stopped:

```powershell
Remove-Item runtime\state\status.json,runtime\state\cards.json,runtime\state\work_orders.json,runtime\state\events.json,runtime\state\evidence.json,runtime\state\approvals.json,runtime\state\handoffs.json,runtime\state\developer_results.json,runtime\state\qa_results.json,runtime\state\repair_requests.json,runtime\state\policy_settings.json,runtime\state\policy_overrides.json,runtime\state\audit_acknowledgements.json,runtime\state\audit_acknowledgement_history.json -ErrorAction SilentlyContinue
```

The next API load will read the seed JSON files again.

## Current Limitations

- JSON files are the only persistence layer in this slice.
- State health/export/import/reset is local demo/developer state management only; it is not production backup/restore or a migration framework.
- No authentication, routing, SQLite, background workers, or autonomous agents are implemented.
- Approval gates are minimal operator state, not a full policy engine.
- Policy enforcement is limited to operator-controlled QA handoff readiness gates; it is not a general policy engine.
- Operator override is a narrow logged exception for policy-promoted missing Developer/Codex result blockers only; it is not authentication, reusable permission, or a hard-blocker bypass.
- Handoffs are API-mediated dry-run records and operator decisions only; they do not execute agent work.
- Developer/Codex result capture is operator/API-mediated metadata capture, not autonomous Codex execution or autonomous coding.
- QA results are operator/API-mediated records after accepted handoffs, not autonomous QA agent execution.
- Repair requests and linked repair work orders are operator/API-mediated records, not autonomous repair execution.
- Repair QA iteration handoffs and results are operator/API-mediated records, not autonomous QA reruns.
- QA readiness is advisory by default; enforced mode promotes only configured missing Developer/Codex result warnings to blockers. Duplicate active handoffs and broken required linkage remain non-overridable blockers in all modes.
- Audit acknowledgement is lightweight operator triage for exception rows. It is not ticketing, external audit acceptance, a large reporting engine, or a proof-package generator.
- Status transitions validate allowed target values, but do not enforce a complex workflow policy yet.
- No OpenAI or Codex API invocation is implemented.

## Non-claims

- No autonomous operation is claimed.
- No full product runtime is claimed.
- No R19 closeout, external audit acceptance, main merge, or production release is claimed.
- No solved reliability, solved compaction, or measured no-manual-transfer success is claimed.
