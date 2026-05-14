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
- Record a structured Developer/Codex result for an original or repair work order before QA handoff.
- Use the Policy Settings panel to switch QA handoff readiness between advisory and enforced mode.
- Enable the narrow operator override option for policy-promoted missing Developer/Codex result blockers.
- See Developer/Codex results in the Developer Results panel.
- Check QA readiness/preflight before original or repair QA handoff.
- Trigger a Developer/Codex to QA/Test handoff from a work order.
- Trigger a QA handoff with an override reason only when readiness says the blocker is policy-overridable.
- See the linked `developer_result_id` and result summary on QA handoffs when a submitted result exists.
- See override id/reason metadata in the Handoffs and Policy Overrides panels.
- Review policy overrides and workflow exceptions in the Audit Review panel.
- Mark audit exceptions as acknowledged, resolved, or dismissed with a required reason.
- Show the append-only acknowledgement history for reviewed audit exceptions.
- Filter audit exceptions by type, severity, acknowledgement status, work order id, card id, and text search.
- Export the current audit review as lightweight JSON or CSV text, including acknowledgement status and reason, with optional history for JSON export.
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

Policy settings use:

- `GET /policy-settings`
- `PATCH /policy-settings`
- `GET /policy-overrides`

The Policy Settings panel shows the current QA handoff policy mode, whether Developer/Codex results are required for original QA and repair QA, the operator override flag, and the last updated timestamp/by fields. Saving policy settings refreshes status, policy settings, readiness fallback state, events, and evidence. `allow_operator_override` only enables overrides for policy-promoted missing Developer/Codex result blockers in enforced mode. It does not bypass duplicate active handoffs, missing records, broken repair linkage, invalid repair work orders, or other hard system blockers.

Developer/Codex result capture uses:

- `GET /developer-results`
- `POST /work-orders/{id}/developer-result`
- `POST /developer-results/{id}/supersede`

The work-order list shows the developer-result count and latest submitted result id for each work order. The inline form defaults original work orders to `implementation` and repair work orders to `repair`; changed paths can be comma- or newline-separated. Submitting a result refreshes status, work orders, developer results, handoffs, events, and evidence. This remains operator/API-mediated result capture and does not invoke Codex/OpenAI.

QA readiness checks use:

- `GET /work-orders/{id}/qa-readiness`
- `GET /repair-requests/{id}/qa-readiness`

Each work-order row shows a compact QA readiness section and a `Check QA readiness` button. Each repair request with a linked repair work order shows repair QA readiness and a `Check Repair QA readiness` button. Readiness can be `ready`, `warning`, or `blocked`. Missing Developer/Codex result capture is a warning and does not disable handoff. Active duplicate QA handoffs and broken required linkage are blockers and disable only the related handoff button.

In advisory policy mode, missing Developer/Codex result capture remains warning-level and the relevant handoff button stays enabled unless another hard blocker exists. In enforced mode, the UI shows missing Developer/Codex result capture as blocked when the matching original or repair requirement flag is enabled, and disables the normal related handoff button until the operator records the Developer/Codex result or uses an available override. Readiness shows `Policy-overridable blockers`, `Non-overridable blockers`, and whether an override is available.

Handoff actions use:

- `GET /handoffs`
- `POST /work-orders/{id}/handoff-to-qa`
- `POST /handoffs/{id}/accept`
- `POST /handoffs/{id}/reject`
- `GET /qa-results`
- `POST /handoffs/{id}/qa-result`

Each successful handoff action refreshes status, work orders, handoffs, events, and evidence. Handoff statuses are `proposed`, `accepted`, `rejected`, `completed`, and `blocked`.

When a submitted Developer/Codex result exists for the work order, the handoff panel shows its id and summary. If a handoff was created without a developer result, the panel displays a warning-style note. Override-approved handoffs show `policy_override_id` and `policy_override_reason`; if they have no developer result, the Handoffs panel explicitly warns that the handoff was operator override-approved.

The Work Orders and Repair Requests panels show an override reason field and override handoff button only when backend readiness reports `override_available: true`. The override button is disabled until the reason is non-empty. The override request body sent to the backend is:

```json
{
  "override_policy": true,
  "override_reason": "Operator accepts QA handoff without Developer/Codex result for this case.",
  "requested_by": "operator"
}
```

The Policy Overrides panel lists the logged override records with target type/id, work order id, repair request id when present, overridden blockers, non-overridable blockers, reason, requested by, and created timestamp.

Audit review uses:

- `GET /audit/summary`
- `GET /audit/acknowledgements`
- `GET /audit/acknowledgement-history`
- `GET /audit/acknowledgements/{id}/history`
- `POST /audit/acknowledgements`
- `PATCH /audit/acknowledgements/{id}`
- `GET /audit/exceptions`
- `GET /audit/export`

The Audit Review panel loads on demand from the backend. It shows summary cards for policy overrides, QA failures, QA blocked results, repair requests, open repairs, policy changes, unreviewed exceptions, acknowledged exceptions, resolved exceptions, dismissed exceptions, history entries, and markers with history. Filters include exception type, severity, acknowledgement status, free-text search, work order id, and card id. `Unreviewed` maps to `acknowledgement_status=none`.

Each exception row shows its current review status, history count, latest acknowledgement change timestamp, and a compact triage form. The operator can choose `acknowledged`, `resolved`, or `dismissed`, enter a required reason, and save. The UI calls POST for an unreviewed exception and PATCH for an exception with an existing marker. A successful save refreshes the audit summary/exceptions and the main dashboard events/evidence. For reviewed exceptions, Show History fetches `GET /audit/acknowledgements/{id}/history` and displays chronological `previous_status -> new_status` rows with reason, changed by, and changed at. Export buttons call the backend export endpoint and show JSON or CSV text in the panel. JSON includes acknowledgement fields; checking Include history in JSON export calls `include_history=true` and includes history entries. CSV remains latest-marker only with `acknowledgement_status` and `acknowledgement_reason`. The panel is a lightweight operator triage surface for exceptions, not full audit acceptance, not ticketing, and not an external audit package.

QA result capture is available only for accepted handoffs that do not already have a QA result. Allowed QA result values are `passed`, `failed`, and `blocked`. A passed result can move the linked work order to `completed`; failed and blocked results can move it to `blocked`. Each successful QA result refreshes status, work orders, handoffs, QA results, events, and evidence.

Repair-loop actions use:

- `GET /repair-requests`
- `POST /qa-results/{id}/repair-request`
- `POST /repair-requests/{id}/handoff-to-qa`
- `GET /workflow-iterations`
- `POST /repair-requests/{id}/complete`
- `POST /repair-requests/{id}/cancel`

The repair request form appears only for failed or blocked QA results that do not already have a repair request. Creating one refreshes status, work orders, repair requests, QA results, events, and evidence. Linked repair work orders start as `ready`, are assigned to `developer_codex` by default, and do not invoke autonomous repair.

The Repair Requests panel shows any existing repair QA handoff id/status and exposes `Handoff Repair to QA` when a repair work order is linked. Repair QA readiness warns when the repair Developer/Codex result is missing, can expose `Handoff Repair to QA with Override` for the narrow policy-promoted missing-result case, and blocks duplicate active repair QA handoffs. The backend rejects duplicate active repair QA handoffs for the same repair request/work order, and the UI displays that API error if it occurs. Accepted repair QA handoffs show the same QA result form used for initial QA. A passed repair QA result can move the repair work order to `completed`; failed or blocked can move it to `blocked` and the existing repair request form can create the next manual repair request.

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

The smoke script starts the backend with a temporary copied seed-state directory, starts Vite on a temporary local port, verifies the Policy Settings panel starts in advisory mode, switches original QA policy to enforced, enables operator override, creates a card/work order, verifies missing Developer/Codex result blocks normal handoff, verifies the override option appears and requires a reason, creates the original QA handoff with override, verifies Handoffs and Policy Overrides show the override id/reason and no `developer_result_id`, verifies duplicate active handoff remains blocked, accepts it, records a failed QA result, creates a repair request, enables the repair QA Developer/Codex result requirement, confirms repair QA handoff is blocked, creates the repair QA handoff with override and reason, accepts it, records a passed repair QA result, verifies the Workflow Iterations panel, verifies override/repair QA events/evidence, refreshes the Audit Review panel, verifies policy override/QA failed/repair request exceptions, applies exception-type and text filters, acknowledges then resolves a policy override exception, shows acknowledgement history, verifies acknowledged and resolved history rows with previous/new statuses, verifies acknowledgement-status filters including `none`, verifies compact JSON export, verifies JSON export with history, verifies CSV export acknowledgement fields, verifies audit acknowledgement event/evidence entries, and checks for browser console errors.

Manual browser smoke:

1. Start `services/orchestrator-api`.
2. Start the UI with `npm run dev`.
3. Create a card.
4. Create a work order linked to that card.
5. Use the card status dropdown and Update status button.
6. Confirm advisory policy mode leaves missing Developer/Codex result as a readiness warning and does not disable Handoff to QA.
7. Switch policy mode to enforced, require Developer/Codex result for original QA, and enable operator override.
8. Click Check QA readiness and confirm the missing-result warning is now blocked, Handoff to QA is disabled, and Handoff to QA with Override appears.
9. Confirm the override button is disabled until a reason is entered.
10. Enter an override reason and click Handoff to QA with Override.
11. Confirm the Handoffs panel shows the override id/reason and no developer result id.
12. Confirm the Policy Overrides panel lists the override.
13. Confirm duplicate active handoff remains blocked.
14. Accept or reject the proposed handoff in the Handoffs panel.
15. For an accepted handoff, submit the QA result form.
16. If the QA result is failed or blocked, create a repair request from the QA Results panel.
17. Confirm the Repair Requests panel and linked repair work order appear.
18. Confirm the Repair Requests panel shows repair QA readiness warning before repair result capture.
19. Enable the repair QA Developer/Codex result requirement and keep operator override enabled in the Policy Settings panel.
20. Confirm repair QA readiness becomes blocked, Handoff Repair to QA is disabled, and Handoff Repair to QA with Override appears.
21. Enter an override reason and click Handoff Repair to QA with Override.
22. Confirm the repair QA handoff shows the override id/reason and no developer result id.
23. Accept the repair QA handoff in the Handoffs panel.
24. Record a repair QA result and confirm the repair work order status updates.
25. Confirm the Workflow Iterations panel shows the original and repair iteration.
26. Confirm Events and Evidence refresh with policy settings, policy override, and repair QA handoff/result entries.
27. Refresh the Audit Review panel and confirm the summary shows at least one policy override.
28. Confirm the Audit Review exception list includes `policy_override`, `qa_failed`, and `repair_request_created`.
29. Filter Audit Review by `policy_override` and then search for the override reason.
30. Mark the policy override exception acknowledged with a reason and confirm the row status updates.
31. Filter by Acknowledged and confirm the exception remains.
32. Mark the same exception resolved with a new reason and confirm the row status updates.
33. Click Show History and confirm the trail shows acknowledged and resolved rows with previous/new statuses.
34. Filter by Resolved and confirm the exception remains, then filter by Unreviewed and confirm it is excluded.
35. Use Export JSON and confirm the compact export omits history by default.
36. Check Include history in JSON export, export JSON again, and confirm acknowledgement history entries appear.
37. Use Export CSV and confirm the textarea contains latest acknowledgement fields.
38. Confirm Events and Evidence show audit acknowledgement entries.
39. Approve or reject a pending approval and confirm the Approvals panel refreshes.

Stable `data-testid` attributes are present for create forms, lists, handoffs, approvals, and per-record status controls.

## Local State

Records are served by `services/orchestrator-api` and persisted as JSON under `runtime/state/`. To reset the local demo state, stop the backend, delete generated `runtime/state/*.json` persistence files, then restart the backend.

## Current Limitations

- No authentication or routing yet.
- No long-lived client state management beyond API refreshes.
- No background workers or autonomous agent execution.
- No OpenAI or Codex API invocation is implemented.
- Developer/Codex result capture is operator/API-mediated metadata capture, not autonomous Codex execution or autonomous coding.
- Handoffs are API-mediated dry-run records, not autonomous A2A execution.
- QA result capture is operator/API-mediated and does not execute live QA agents.
- Repair request creation is operator/API-mediated and does not execute autonomous repair or live Developer/Codex agents.
- Repair QA handoffs and repair QA result capture are operator-triggered UI/API flows, not autonomous QA reruns.
- QA readiness is advisory by default. Enforced mode is limited to operator-controlled Developer/Codex result requirements for QA handoff readiness and is not a full policy engine.
- Operator override is a narrow logged exception path for policy-promoted missing Developer/Codex result blockers only; it is not auth, not reusable permission, and not a bypass for hard system blockers.
- Audit Review acknowledgement history is append-only lightweight operator triage, not external audit acceptance, not a ticketing system, not a large reporting engine, and not a proof-package generator.
- Completing or cancelling a repair request does not automatically create another handoff.
- Status controls validate through the backend, but no complex workflow policy is implemented yet.
- This proves a local operator UI/API workflow slice, not full product runtime.
