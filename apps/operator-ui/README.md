# AIOffice Operator UI

React + TypeScript + Vite console for the R19 product reset operator workflow.

## Setup

```bash
cd apps/operator-ui
npm install
```

## Run

```bash
npm run dev
```

The dev server defaults to `http://127.0.0.1:5173`.

## Backend URL

The UI expects the orchestrator API at `http://localhost:8000` by default.

To override it:

```powershell
set VITE_AIO_API_BASE_URL=http://127.0.0.1:8000
npm run dev
```

On Unix-like shells:

```bash
VITE_AIO_API_BASE_URL=http://127.0.0.1:8000 npm run dev
```

## Operator Flow

- Create a card from the UI.
- Move a card through `intake`, `planned`, `in_progress`, `blocked`, `done`, and `archived`.
- Create a work order linked to an existing card.
- Move a work order through `draft`, `ready`, `running`, `waiting_approval`, `approved`, `rejected`, `completed`, `blocked`, and `cancelled`.
- Optionally request an approval gate while creating a work order.
- Create a separate approval request.
- Approve or reject pending approvals.
- See cards, work orders, approvals, events, and evidence refresh after each action.

Status updates use:

- `PATCH /cards/{id}/status`
- `PATCH /work-orders/{id}/status`

Each successful status update refreshes the status panel, cards, work orders, events, evidence, and approvals. Status changes appear in the Events timeline and Evidence panel.

## Build and Smoke

Required frontend regression check:

```bash
npm run build
```

Manual browser smoke:

1. Start `services/orchestrator-api`.
2. Start the UI with `npm run dev`.
3. Create a card.
4. Create a work order linked to that card.
5. Use the card status dropdown and Update status button.
6. Use the work-order status dropdown and Update status button.
7. Confirm Events and Evidence refresh with status-change entries.
8. Approve or reject a pending approval and confirm the Approvals panel refreshes.

Stable `data-testid` attributes are present for create forms, lists, approvals, and per-record status controls so a later browser automation slice can build on the same workflow without changing UI semantics.

## Local State

Records are served by `services/orchestrator-api` and persisted as JSON under `runtime/state/`. To reset the local demo state, stop the backend, delete generated `runtime/state/*.json` persistence files, then restart the backend.

## Current Limitations

- No authentication or routing yet.
- No long-lived client state management beyond API refreshes.
- No background workers or autonomous agent execution.
- No OpenAI or Codex API invocation is implemented.
- Status controls validate through the backend, but no complex workflow policy is implemented yet.
- This proves a local operator UI/API workflow slice, not full product runtime.
