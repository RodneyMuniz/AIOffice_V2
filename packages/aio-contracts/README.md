# AIOffice Contracts

Small shared contract examples for the R19 UI/API product slice.

These schemas document the first local API shapes only. They are not a large contract system, not milestone proof, and not a substitute for a runnable UI/API demo.

## Included examples

- `schemas/status-response.schema.json`
- `schemas/policy-settings.schema.json`
- `schemas/update-policy-settings-request.schema.json`
- `schemas/policy-override.schema.json`
- `schemas/handoff-override-request.schema.json`
- `schemas/card.schema.json`
- `schemas/create-card-request.schema.json`
- `schemas/update-card-status-request.schema.json`
- `schemas/work-order.schema.json`
- `schemas/create-work-order-request.schema.json`
- `schemas/update-work-order-status-request.schema.json`
- `schemas/developer-result.schema.json`
- `schemas/create-developer-result-request.schema.json`
- `schemas/qa-readiness-check.schema.json`
- `schemas/qa-readiness-response.schema.json`
- `schemas/handoff.schema.json`
- `schemas/create-handoff-request.schema.json`
- `schemas/handoff-decision-request.schema.json`
- `schemas/qa-result.schema.json`
- `schemas/create-qa-result-request.schema.json`
- `schemas/repair-request.schema.json`
- `schemas/create-repair-request.schema.json`
- `schemas/repair-request-decision.schema.json`
- `schemas/workflow-iteration.schema.json`
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

Allowed Developer/Codex result types are `implementation`, `repair`, `documentation`, `validation`, and `other`.

Allowed Developer/Codex result statuses are `draft`, `submitted`, and `superseded`.

Allowed QA handoff policy modes are `advisory` and `enforced`.

The Developer/Codex result contracts describe operator/API-mediated result capture for a work order before QA handoff. They record summary, changed paths, notes, agent id, and evidence refs in `runtime/state/developer_results.json`. They do not claim autonomous Codex execution, autonomous coding, live OpenAI/Codex API invocation, or no-manual-transfer success.

The policy settings contracts describe the small persisted `runtime/state/policy_settings.json` model used by `GET /policy-settings` and `PATCH /policy-settings`. The model includes `qa_handoff_policy_mode`, original and repair Developer/Codex result requirement flags, `allow_operator_override`, `updated_at`, and `updated_by`. When `allow_operator_override` is true, enforced readiness can expose a narrow override option only for policy-promoted missing Developer/Codex result blockers.

The policy override contract describes records persisted to `runtime/state/policy_overrides.json` and returned by `GET /policy-overrides`. Overrides are single-request, logged exceptions for `work_order_qa_handoff` or `repair_qa_handoff` targets. They require a non-empty reason, record `requested_by`, list overridden blockers, preserve any non-overridable blockers seen at request time, and link evidence refs. They do not mutate policy settings and do not become reusable permissions.

The QA readiness contracts describe read-only preflight responses for `GET /work-orders/{id}/qa-readiness` and `GET /repair-requests/{id}/qa-readiness`. Readiness levels are `ready`, `warning`, and `blocked`; check statuses are `passed`, `warning`, and `blocked`.

Readiness is not persisted. In advisory mode, missing Developer/Codex result capture remains a warning and does not block handoff creation. In enforced mode, that missing-result warning is promoted to a blocker for original QA when `require_developer_result_for_qa` is true, and for repair QA when `require_developer_result_for_repair_qa` is true. Readiness responses classify blockers as `overridable_blockers` and `non_overridable_blockers`, plus `override_available`. Only the policy-promoted missing Developer/Codex result blocker can be overridable, and only when enforced mode and `allow_operator_override` are both active. Missing core records, broken repair linkage, invalid repair work orders, and duplicate active proposed/accepted QA handoffs remain non-overridable in all modes. This is a narrow exception path, not a full policy engine or governance document flow.

The handoff contracts describe an API-mediated dry-run role handoff. They do not claim autonomous A2A execution, background workers, OpenAI/Codex API invocation, or full product runtime.

QA handoffs may include `developer_result_id` and `developer_result_summary` when a submitted Developer/Codex result exists for the work order. Handoffs are still allowed without a result in advisory mode and should carry a visible warning summary. In enforced mode, configured missing-result blockers return HTTP 400 before handoff creation unless the request includes a valid, immediate operator override and no non-overridable blockers exist. Override-approved handoffs include `policy_override_id` and `policy_override_reason`; they can still have no `developer_result_id`.

The QA result contracts describe structured operator/API-mediated result capture after an accepted handoff. They do not claim autonomous QA execution, live agent testing, autonomous A2A, or no-manual-transfer success.

The repair request contracts describe an operator/API-mediated repair loop for failed or blocked QA results. Creating a repair request creates a linked Developer/Codex repair work order, but it does not claim autonomous repair, live agent execution, or automatic QA reruns.

Repair QA handoff fields are optional additions to the handoff and QA result records. A repair QA handoff uses `handoff_purpose: repair_qa`, links `repair_request_id`, carries the failed or blocked source `qa_result_id`, and uses `iteration_number` to show that the repair work order is being sent back through QA. Initial QA handoffs use `handoff_purpose: initial_qa` and iteration `1`.

The workflow iteration schema documents the read-only `GET /workflow-iterations` view derived from work orders, handoffs, QA results, and repair requests. It is not a persisted workflow engine. It is a compact chain view for the manual loop: original work order, failed or blocked QA result, repair work order, repair QA handoff, and repair QA result.

This remains a UI/API-mediated loop. The contracts do not claim autonomous A2A execution, autonomous QA, autonomous repair, no-manual-transfer success, full policy-engine coverage, or live OpenAI/Codex API invocation.
