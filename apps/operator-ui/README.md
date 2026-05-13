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
- For failed or blocked QA results, create a repair request that creates a linked Developer/Codex repair work order.
- See repair requests in the Repair Requests panel, hand off linked repair work orders back to QA, and complete or cancel created/in-progress repair requests.
- Accept repair QA handoffs from the Handoffs panel and record repair QA results with the existing QA result form.
- See the original and repair loop in the Workflow Iterations panel.
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

Repair-loop actions use:

- `GET /repair-requests`
- `POST /qa-results/{id}/repair-request`
- `POST /repair-requests/{id}/handoff-to-qa`
- `GET /workflow-iterations`
- `POST /repair-requests/{id}/complete`
- `POST /repair-requests/{id}/cancel`

The repair request form appears only for failed or blocked QA results that do not already have a repair request. Creating one refreshes status, work orders, repair requests, QA results, events, and evidence. Linked repair work orders start as `ready`, are assigned to `developer_codex` by default, and do not invoke autonomous repair.

The Repair Requests panel shows any existing repair QA handoff id/status and exposes `Handoff Repair to QA` when a repair work order is linked. The backend rejects duplicate active repair QA handoffs for the same repair request/work order, and the UI displays that API error if it occurs. Accepted repair QA handoffs show the same QA result form used for initial QA. A passed repair QA result can move the repair work order to `completed`; failed or blocked can move it to `blocked` and the existing repair request form can create the next manual repair request.

The Workflow Iterations panel is read-only. It is loaded from `GET /workflow-iterations` and shows the compact chain from original work order to repair iterations, latest handoff, latest QA result, and latest result.

## Build and Smoke

Required frontend regression check:

```bash
npm run build
```

Committed browser smoke:

```bash
npm run smoke
```

The smoke script starts the backend with a temporary copied seed-state directory, starts Vite on a temporary local port, creates a card/work order, updates both statuses, triggers a QA handoff, accepts it, records a failed QA result, creates a repair request, verifies the linked repair work order, hands the repair work order back to QA from the Repair Requests panel, accepts the repair QA handoff, records a passed repair QA result, verifies the Workflow Iterations panel, verifies repair QA events/evidence, and checks for browser console errors.

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
10. If the QA result is failed or blocked, create a repair request from the QA Results panel.
11. Confirm the Repair Requests panel and linked repair work order appear.
12. Click Handoff Repair to QA from the Repair Requests panel.
13. Accept the repair QA handoff in the Handoffs panel.
14. Record a repair QA result and confirm the repair work order status updates.
15. Confirm the Workflow Iterations panel shows the original and repair iteration.
16. Confirm Events and Evidence refresh with repair QA handoff/result entries.
17. Approve or reject a pending approval and confirm the Approvals panel refreshes.

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
- Repair request creation is operator/API-mediated and does not execute autonomous repair or live Developer/Codex agents.
- Repair QA handoffs and repair QA result capture are operator-triggered UI/API flows, not autonomous QA reruns.
- Completing or cancelling a repair request does not automatically create another handoff.
- Status controls validate through the backend, but no complex workflow policy is implemented yet.
- This proves a local operator UI/API workflow slice, not full product runtime.
