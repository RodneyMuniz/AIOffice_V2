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
- `schemas/agent.schema.json`
- `schemas/approval.schema.json`
- `schemas/create-approval-request.schema.json`
- `schemas/event.schema.json`
- `schemas/evidence-entry.schema.json`

The structures are intentionally JSON-first so they can map later to TypeScript types, Python models, and SQLite-backed state.

Allowed card statuses are `intake`, `planned`, `in_progress`, `blocked`, `done`, and `archived`.

Allowed work-order statuses are `draft`, `ready`, `running`, `waiting_approval`, `approved`, `rejected`, `completed`, `blocked`, and `cancelled`.

Allowed handoff statuses are `proposed`, `accepted`, `rejected`, `completed`, and `blocked`.

The handoff contracts describe an API-mediated dry-run role handoff. They do not claim autonomous A2A execution, background workers, OpenAI/Codex API invocation, or full product runtime.
