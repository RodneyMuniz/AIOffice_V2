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
- `GET /work-orders`
- `POST /work-orders`
- `GET /agents`
- `GET /events`
- `GET /evidence`
- `GET /approvals`
- `POST /approvals`
- `POST /approvals/{id}/approve`
- `POST /approvals/{id}/reject`

## JSON Persistence

The API loads persistent JSON files from `runtime/state/*.json` when present. If a persistent file is missing, it falls back to the matching seed file, for example `cards.seed.json`.

Mutating endpoints write back to:

- `runtime/state/cards.json`
- `runtime/state/work_orders.json`
- `runtime/state/events.json`
- `runtime/state/evidence.json`
- `runtime/state/approvals.json`

Creating cards and work orders writes event and evidence entries. Work orders must link to an existing `card_id`; invalid card IDs return HTTP 400 with a clear message. Work orders can request an approval gate with `request_requires_approval: true`.

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
- No OpenAI or Codex API invocation is implemented.

## Non-claims

- No autonomous operation is claimed.
- No full product runtime is claimed.
- No R19 closeout, external audit acceptance, main merge, or production release is claimed.
- No solved reliability, solved compaction, or measured no-manual-transfer success is claimed.
