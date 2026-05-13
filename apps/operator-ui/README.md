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
- Trigger a Developer/Codex to QA/Test handoff from a work order.
- Accept or reject proposed handoffs from the Handoffs panel.
- Record a structured QA/Test result for accepted handoffs.
- See recorded QA results in the QA Results panel.
- Create a separate approval request.
- Approve or reject pending approvals.
- See cards, work orders, handoffs, approvals, events, and evidence refresh after each action.

Status updates use:

- `PATCH /cards/{id}/status`
- `PATCH /work-orders/{id}/status`

Each successful status update refreshes the status panel, cards, work orders, events, evidence, and approvals. Status changes appear in the Events timeline and Evidence panel.

Handoff actions use:

- `GET /handoffs`
- `POST /work-orders/{id}/handoff-to-qa`
- `POST /handoffs/{id}/accept`
- `POST /handoffs/{id}/reject`
- `GET /qa-results`
- `POST /handoffs/{id}/qa-result`

Each successful handoff action refreshes status, work orders, handoffs, events, and evidence. Handoff statuses are `proposed`, `accepted`, `rejected`, `completed`, and `blocked`.

QA result capture is available only for accepted handoffs that do not already have a QA result. Allowed QA result values are `passed`, `failed`, and `blocked`. A passed result can move the linked work order to `completed`; failed and blocked results can move it to `blocked`. Each successful QA result refreshes status, work orders, handoffs, QA results, events, and evidence.

## Build and Smoke

Required frontend regression check:

```bash
npm run build
```

Committed browser smoke:

```bash
npm run smoke
```

The smoke script starts the backend with a temporary copied seed-state directory, starts Vite on a temporary local port, creates a card/work order, updates both statuses, triggers a QA handoff, accepts it, records a passed QA result, verifies the QA Results panel and event/evidence refresh, and checks for browser console errors.

Manual browser smoke:

1. Start `services/orchestrator-api`.
2. Start the UI with `npm run dev`.
3. Create a card.
4. Create a work order linked to that card.
5. Use the card status dropdown and Update status button.
6. Use the work-order status dropdown and Update status button.
7. Click Handoff to QA on the work order.
8. Accept or reject the proposed handoff in the Handoffs panel.
9. For an accepted handoff, submit the QA result form.
10. Confirm the QA Results panel, Events, and Evidence refresh with QA result entries.
11. Approve or reject a pending approval and confirm the Approvals panel refreshes.

Stable `data-testid` attributes are present for create forms, lists, handoffs, approvals, and per-record status controls.

## Local State

Records are served by `services/orchestrator-api` and persisted as JSON under `runtime/state/`. To reset the local demo state, stop the backend, delete generated `runtime/state/*.json` persistence files, then restart the backend.

## Current Limitations

- No authentication or routing yet.
- No long-lived client state management beyond API refreshes.
- No background workers or autonomous agent execution.
- No OpenAI or Codex API invocation is implemented.
- Handoffs are API-mediated dry-run records, not autonomous A2A execution.
- QA result capture is operator/API-mediated and does not execute live QA agents.
- Status controls validate through the backend, but no complex workflow policy is implemented yet.
- This proves a local operator UI/API workflow slice, not full product runtime.
