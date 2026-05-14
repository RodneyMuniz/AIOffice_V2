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

Invalid status values return HTTP 400. Unknown card or work-order IDs return HTTP 404.

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

QA handoff creation attaches the latest submitted Developer/Codex result for the work order as `developer_result_id` and `developer_result_summary` when one exists. Handoffs are still allowed without a developer result in this slice, but `validation_summary` records `No developer result recorded before QA handoff.` as a visible soft warning.

`GET /work-orders/{id}/qa-readiness` and `GET /repair-requests/{id}/qa-readiness` return a derived, read-only readiness/preflight response. Unknown work orders or repair requests return HTTP 404. Readiness levels are `ready`, `warning`, and `blocked`; individual checks are `passed`, `warning`, or `blocked`. Missing Developer/Codex result capture is a warning. Missing card/work-order/repair linkage, invalid repair work-order linkage, missing assigned agent, cancelled/rejected work-order state, or an active duplicate proposed/accepted QA handoff is a blocker. GET readiness calls do not create events or evidence.

The convenience handoff endpoints reuse readiness before creating QA handoffs. Warning-level readiness remains advisory and does not block handoff creation. Blocker-level readiness returns HTTP 400. Active accepted/proposed handoffs are considered duplicate blockers only until a QA result exists for that handoff.

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

Mutating endpoints write back to:

- `runtime/state/cards.json`
- `runtime/state/work_orders.json`
- `runtime/state/events.json`
- `runtime/state/evidence.json`
- `runtime/state/approvals.json`
- `runtime/state/handoffs.json`
- `runtime/state/developer_results.json`
- `runtime/state/qa_results.json`
- `runtime/state/repair_requests.json`

Creating cards and work orders writes event and evidence entries. Work orders must link to an existing `card_id`; invalid card IDs return HTTP 400 with a clear message. Work orders can request an approval gate with `request_requires_approval: true`.

Card and work-order status changes persist to JSON and write `status_transition` evidence plus `*_status_changed` events. Moving a work order to `waiting_approval` creates a pending approval when one is not already pending for that work order. Approving or rejecting a linked pending approval can move a work order from `waiting_approval` to `approved` or `rejected`.

Handoff create/accept/reject actions persist to JSON and write `handoff_*` events plus `handoff_record` or `handoff_decision` evidence.

Developer result capture persists to `developer_results.json`, updates developer-result pointers on the work order, and writes `developer_result` evidence. Superseding a result writes `developer_result_superseded` and removes the work order's latest submitted result pointer when no replacement exists.

QA result capture persists to JSON and writes `qa_result_recorded` events plus `qa_result` evidence. When the simple status mapping applies, the API also writes `work_order_completed_from_qa` or `work_order_blocked_from_qa` events.

Repair request creation persists to JSON, creates a linked `ready` repair work order, and writes `repair_request_created`, `repair_work_order_created`, `repair_request`, and `repair_work_order` records. Completing or cancelling writes `repair_request_completed` or `repair_request_cancelled` plus `repair_request` evidence.

Repair QA handoff creation persists to `handoffs.json` and writes `repair_handoff_created`, `repair_handoff`, and `workflow_iteration` records. Repair QA result capture persists to `qa_results.json` and writes `repair_qa_result_recorded`, `repair_iteration_passed`/`repair_iteration_failed`/`repair_iteration_blocked`, `repair_qa_result`, and `workflow_iteration` records.

## Test and Smoke Commands

Backend regression harness:

```bash
python -m pytest services/orchestrator-api/tests
```

The pytest harness covers seed reads, card/work-order/status updates, approvals, Developer/Codex result validation/capture/supersede/persistence, QA readiness warning/ready/blocker paths, repair QA readiness warning/ready/blocker paths, readiness 404s, QA handoff developer-result references and soft warnings, QA result creation/error paths, repair request creation/error paths, linked repair work-order creation, repair QA handoff/result iteration flow, duplicate active repair handoff rejection, workflow iteration derivation, event/evidence writes, JSON persistence, repair completion/cancellation, and the small QA-result-to-work-order status mapping.

Backend import smoke from the service directory:

```bash
cd services/orchestrator-api
python -c "from app.main import app; print(app.title)"
```

Live API smoke after starting the backend:

```bash
curl http://127.0.0.1:8000/status
curl http://127.0.0.1:8000/developer-results
curl http://127.0.0.1:8000/workflow-iterations
curl http://127.0.0.1:8000/handoffs
curl http://127.0.0.1:8000/qa-results
curl http://127.0.0.1:8000/repair-requests
curl -X POST http://127.0.0.1:8000/cards -H "Content-Type: application/json" -d "{\"title\":\"Smoke card\",\"description\":\"Smoke\",\"priority\":\"medium\",\"owner_role\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/cards/R19-CARD-002/status -H "Content-Type: application/json" -d "{\"status\":\"planned\",\"requested_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/work-orders -H "Content-Type: application/json" -d "{\"card_id\":\"R19-CARD-002\",\"title\":\"Smoke work order\",\"description\":\"Smoke work order\",\"assigned_agent_id\":\"developer_codex\",\"request_requires_approval\":false}"
curl http://127.0.0.1:8000/work-orders/R19-WO-002/qa-readiness
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-002/developer-result -H "Content-Type: application/json" -d "{\"result_type\":\"implementation\",\"summary\":\"Smoke implementation result.\",\"changed_paths\":[\"apps/operator-ui/src/App.tsx\"],\"notes\":\"Manual smoke result.\",\"agent_id\":\"developer_codex\"}"
curl http://127.0.0.1:8000/work-orders/R19-WO-002/qa-readiness
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-002/handoff-to-qa
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-001/accept -H "Content-Type: application/json" -d "{\"decision_reason\":\"Accepted for QA smoke.\",\"decided_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-001/qa-result -H "Content-Type: application/json" -d "{\"result\":\"failed\",\"summary\":\"QA failed.\",\"findings\":\"Repair needed.\",\"recommended_next_action\":\"Create repair work order.\",\"qa_agent_id\":\"qa_test\"}"
curl -X POST http://127.0.0.1:8000/qa-results/R19-QA-RESULT-001/repair-request -H "Content-Type: application/json" -d "{\"summary\":\"Repair failed QA\",\"repair_instructions\":\"Fix the failed QA path.\",\"requested_by\":\"operator\",\"assigned_agent_id\":\"developer_codex\"}"
curl http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/qa-readiness
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-003/developer-result -H "Content-Type: application/json" -d "{\"result_type\":\"repair\",\"summary\":\"Smoke repair result.\",\"changed_paths\":[\"apps/operator-ui/src/App.tsx\"],\"notes\":\"Manual smoke repair result.\",\"agent_id\":\"developer_codex\"}"
curl http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/qa-readiness
curl -X POST http://127.0.0.1:8000/repair-requests/R19-REPAIR-001/handoff-to-qa
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-002/accept -H "Content-Type: application/json" -d "{\"decision_reason\":\"Accepted repair QA smoke.\",\"decided_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-002/qa-result -H "Content-Type: application/json" -d "{\"result\":\"passed\",\"summary\":\"Repair QA passed.\",\"findings\":\"Repair verified.\",\"recommended_next_action\":\"Complete repair work order.\",\"qa_agent_id\":\"qa_test\"}"
```

## Reset Local Runtime State

Delete the generated persistent files and restart the API:

```powershell
Remove-Item runtime\state\cards.json,runtime\state\work_orders.json,runtime\state\events.json,runtime\state\evidence.json,runtime\state\approvals.json,runtime\state\handoffs.json,runtime\state\developer_results.json,runtime\state\qa_results.json,runtime\state\repair_requests.json -ErrorAction SilentlyContinue
```

The next API load will read the seed JSON files again.

## Current Limitations

- JSON files are the only persistence layer in this slice.
- No authentication, routing, SQLite, background workers, or autonomous agents are implemented.
- Approval gates are minimal operator state, not a full policy engine.
- Handoffs are API-mediated dry-run records and operator decisions only; they do not execute agent work.
- Developer/Codex result capture is operator/API-mediated metadata capture, not autonomous Codex execution or autonomous coding.
- QA results are operator/API-mediated records after accepted handoffs, not autonomous QA agent execution.
- Repair requests and linked repair work orders are operator/API-mediated records, not autonomous repair execution.
- Repair QA iteration handoffs and results are operator/API-mediated records, not autonomous QA reruns.
- QA readiness is advisory except for narrow blockers such as duplicate active handoffs and broken required linkage; it is not a full workflow policy engine.
- Status transitions validate allowed target values, but do not enforce a complex workflow policy yet.
- No OpenAI or Codex API invocation is implemented.

## Non-claims

- No autonomous operation is claimed.
- No full product runtime is claimed.
- No R19 closeout, external audit acceptance, main merge, or production release is claimed.
- No solved reliability, solved compaction, or measured no-manual-transfer success is claimed.
