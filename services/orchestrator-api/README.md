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
- `GET /agents`
- `GET /events`
- `GET /evidence`
- `GET /approvals`
- `POST /approvals`
- `POST /approvals/{id}/approve`
- `POST /approvals/{id}/reject`

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

Invalid status values return HTTP 400. Unknown card or work-order IDs return HTTP 404.

## JSON Persistence

The API loads persistent JSON files from `runtime/state/*.json` when present. If a persistent file is missing, it falls back to the matching seed file, for example `cards.seed.json`.

Set `AIO_STATE_DIR` before importing or starting the app to use an alternate state directory for smoke tests.

Mutating endpoints write back to:

- `runtime/state/cards.json`
- `runtime/state/work_orders.json`
- `runtime/state/events.json`
- `runtime/state/evidence.json`
- `runtime/state/approvals.json`

Creating cards and work orders writes event and evidence entries. Work orders must link to an existing `card_id`; invalid card IDs return HTTP 400 with a clear message. Work orders can request an approval gate with `request_requires_approval: true`.

Card and work-order status changes persist to JSON and write `status_transition` evidence plus `*_status_changed` events. Moving a work order to `waiting_approval` creates a pending approval when one is not already pending for that work order. Approving or rejecting a linked pending approval can move a work order from `waiting_approval` to `approved` or `rejected`.

## Test and Smoke Commands

Backend regression harness:

```bash
python -m pytest services/orchestrator-api/tests
```

Backend import smoke from the service directory:

```bash
cd services/orchestrator-api
python -c "from app.main import app; print(app.title)"
```

Live API smoke after starting the backend:

```bash
curl http://127.0.0.1:8000/status
curl -X POST http://127.0.0.1:8000/cards -H "Content-Type: application/json" -d "{\"title\":\"Smoke card\",\"description\":\"Smoke\",\"priority\":\"medium\",\"owner_role\":\"operator\"}"
curl -X PATCH http://127.0.0.1:8000/cards/R19-CARD-002/status -H "Content-Type: application/json" -d "{\"status\":\"planned\",\"requested_by\":\"operator\"}"
```

## Reset Local Runtime State

Delete the generated persistent files and restart the API:

```powershell
Remove-Item runtime\state\cards.json,runtime\state\work_orders.json,runtime\state\events.json,runtime\state\evidence.json,runtime\state\approvals.json -ErrorAction SilentlyContinue
```

The next API load will read the seed JSON files again.

## Current Limitations

- JSON files are the only persistence layer in this slice.
- No authentication, routing, SQLite, background workers, or autonomous agents are implemented.
- Approval gates are minimal operator state, not a full policy engine.
- Status transitions validate allowed target values, but do not enforce a complex workflow policy yet.
- No OpenAI or Codex API invocation is implemented.

## Non-claims

- No autonomous operation is claimed.
- No full product runtime is claimed.
- No R19 closeout, external audit acceptance, main merge, or production release is claimed.
- No solved reliability, solved compaction, or measured no-manual-transfer success is claimed.
