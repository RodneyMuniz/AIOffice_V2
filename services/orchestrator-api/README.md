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

## State

The API loads small seed JSON files from `runtime/state/`. `POST /cards` and `POST /work-orders` create in-memory records for this slice only.

## Non-claims

- No OpenAI or Codex API invocation is implemented.
- No autonomous operation is claimed.
- No full product runtime is claimed.
- No R19 closeout, external audit acceptance, or main merge is claimed.
- No solved reliability, solved compaction, or measured no-manual-transfer success is claimed.
