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
- `PATCH /work-orders/{id}/status`
- `POST /work-orders/{id}/handoff-to-qa`
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
- `POST /qa-results/{id}/repair-request`
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

Invalid status values return HTTP 400. Unknown card or work-order IDs return HTTP 404.

`POST /handoffs` validates source and target agents, the card, the work order, and that the work order belongs to the card. `POST /work-orders/{id}/handoff-to-qa` is the first product-facing convenience flow: it creates a `developer_codex` to `qa_test` handoff with `source_role` `Developer/Codex` and `target_role` `QA/Test`. Accepting or rejecting a handoff records the operator decision but does not invoke AI, call Codex/OpenAI APIs, or run autonomous agents.

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
- `runtime/state/qa_results.json`
- `runtime/state/repair_requests.json`

Creating cards and work orders writes event and evidence entries. Work orders must link to an existing `card_id`; invalid card IDs return HTTP 400 with a clear message. Work orders can request an approval gate with `request_requires_approval: true`.

Card and work-order status changes persist to JSON and write `status_transition` evidence plus `*_status_changed` events. Moving a work order to `waiting_approval` creates a pending approval when one is not already pending for that work order. Approving or rejecting a linked pending approval can move a work order from `waiting_approval` to `approved` or `rejected`.

Handoff create/accept/reject actions persist to JSON and write `handoff_*` events plus `handoff_record` or `handoff_decision` evidence.

QA result capture persists to JSON and writes `qa_result_recorded` events plus `qa_result` evidence. When the simple status mapping applies, the API also writes `work_order_completed_from_qa` or `work_order_blocked_from_qa` events.

Repair request creation persists to JSON, creates a linked `ready` repair work order, and writes `repair_request_created`, `repair_work_order_created`, `repair_request`, and `repair_work_order` records. Completing or cancelling writes `repair_request_completed` or `repair_request_cancelled` plus `repair_request` evidence.

## Test and Smoke Commands

Backend regression harness:

```bash
python -m pytest services/orchestrator-api/tests
```

The pytest harness covers seed reads, card/work-order/status updates, approvals, handoffs, QA result creation/error paths, repair request creation/error paths, linked repair work-order creation, event/evidence writes, JSON persistence, repair completion/cancellation, and the small QA-result-to-work-order status mapping.

Backend import smoke from the service directory:

```bash
cd services/orchestrator-api
python -c "from app.main import app; print(app.title)"
```

Live API smoke after starting the backend:

```bash
curl http://127.0.0.1:8000/status
curl http://127.0.0.1:8000/handoffs
curl http://127.0.0.1:8000/qa-results
curl http://127.0.0.1:8000/repair-requests
curl -X POST http://127.0.0.1:8000/cards -H "Content-Type: application/json" -d "{\"title\":\"Smoke card\",\"description\":\"Smoke\",\"priority\":\"medium\",\"owner_role\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/cards/R19-CARD-002/status -H "Content-Type: application/json" -d "{\"status\":\"planned\",\"requested_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/work-orders/R19-WO-001/handoff-to-qa
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-001/accept -H "Content-Type: application/json" -d "{\"decision_reason\":\"Accepted for QA smoke.\",\"decided_by\":\"operator\"}"
curl -X POST http://127.0.0.1:8000/handoffs/R19-HANDOFF-001/qa-result -H "Content-Type: application/json" -d "{\"result\":\"failed\",\"summary\":\"QA failed.\",\"findings\":\"Repair needed.\",\"recommended_next_action\":\"Create repair work order.\",\"qa_agent_id\":\"qa_test\"}"
curl -X POST http://127.0.0.1:8000/qa-results/R19-QA-RESULT-001/repair-request -H "Content-Type: application/json" -d "{\"summary\":\"Repair failed QA\",\"repair_instructions\":\"Fix the failed QA path.\",\"requested_by\":\"operator\",\"assigned_agent_id\":\"developer_codex\"}"
```

## Reset Local Runtime State

Delete the generated persistent files and restart the API:

```powershell
Remove-Item runtime\state\cards.json,runtime\state\work_orders.json,runtime\state\events.json,runtime\state\evidence.json,runtime\state\approvals.json,runtime\state\handoffs.json,runtime\state\qa_results.json,runtime\state\repair_requests.json -ErrorAction SilentlyContinue
```

The next API load will read the seed JSON files again.

## Current Limitations

- JSON files are the only persistence layer in this slice.
- No authentication, routing, SQLite, background workers, or autonomous agents are implemented.
- Approval gates are minimal operator state, not a full policy engine.
- Handoffs are API-mediated dry-run records and operator decisions only; they do not execute agent work.
- QA results are operator/API-mediated records after accepted handoffs, not autonomous QA agent execution.
- Repair requests and linked repair work orders are operator/API-mediated records, not autonomous repair execution.
- Repair completion/cancellation does not re-run QA or create a new QA handoff.
- Status transitions validate allowed target values, but do not enforce a complex workflow policy yet.
- No OpenAI or Codex API invocation is implemented.

## Non-claims

- No autonomous operation is claimed.
- No full product runtime is claimed.
- No R19 closeout, external audit acceptance, main merge, or production release is claimed.
- No solved reliability, solved compaction, or measured no-manual-transfer success is claimed.
