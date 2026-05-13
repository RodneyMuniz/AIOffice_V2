# AIOffice Contracts

Small shared contract examples for the R19 UI/API product slice.

These schemas document the first local API shapes only. They are not a large contract system, not milestone proof, and not a substitute for a runnable UI/API demo.

## Included examples

- `schemas/status-response.schema.json`
- `schemas/card.schema.json`
- `schemas/create-card-request.schema.json`
- `schemas/update-card-status-request.schema.json`
- `schemas/work-order.schema.json`
- `schemas/create-work-order-request.schema.json`
- `schemas/update-work-order-status-request.schema.json`
- `schemas/handoff.schema.json`
- `schemas/create-handoff-request.schema.json`
- `schemas/handoff-decision-request.schema.json`
- `schemas/qa-result.schema.json`
- `schemas/create-qa-result-request.schema.json`
- `schemas/repair-request.schema.json`
- `schemas/create-repair-request.schema.json`
- `schemas/repair-request-decision.schema.json`
- `schemas/agent.schema.json`
- `schemas/approval.schema.json`
- `schemas/create-approval-request.schema.json`
- `schemas/event.schema.json`
- `schemas/evidence-entry.schema.json`

The structures are intentionally JSON-first so they can map later to TypeScript types, Python models, and SQLite-backed state.

Allowed card statuses are `intake`, `planned`, `in_progress`, `blocked`, `done`, and `archived`.

Allowed work-order statuses are `draft`, `ready`, `running`, `waiting_approval`, `approved`, `rejected`, `completed`, `blocked`, and `cancelled`.

Allowed handoff statuses are `proposed`, `accepted`, `rejected`, `completed`, and `blocked`.

Allowed QA result values are `passed`, `failed`, and `blocked`.

Allowed repair request statuses are `proposed`, `created`, `in_progress`, `completed`, and `cancelled`.

The handoff contracts describe an API-mediated dry-run role handoff. They do not claim autonomous A2A execution, background workers, OpenAI/Codex API invocation, or full product runtime.

The QA result contracts describe structured operator/API-mediated result capture after an accepted handoff. They do not claim autonomous QA execution, live agent testing, autonomous A2A, or no-manual-transfer success.

The repair request contracts describe an operator/API-mediated repair loop for failed or blocked QA results. Creating a repair request creates a linked Developer/Codex repair work order, but it does not claim autonomous repair, live agent execution, or automatic QA reruns.
