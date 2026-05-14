# AIOffice Contracts

Small shared contract examples for the R19 UI/API product slice.

These schemas document the first local API shapes only. They are not a large contract system, not milestone proof, and not a substitute for a runnable UI/API demo.

## Included examples

- `schemas/status-response.schema.json`
- `schemas/policy-settings.schema.json`
- `schemas/update-policy-settings-request.schema.json`
- `schemas/policy-override.schema.json`
- `schemas/audit-summary.schema.json`
- `schemas/audit-exception.schema.json`
- `schemas/audit-export.schema.json`
- `schemas/audit-acknowledgement.schema.json`
- `schemas/audit-acknowledgement-history-entry.schema.json`
- `schemas/create-audit-acknowledgement-request.schema.json`
- `schemas/update-audit-acknowledgement-request.schema.json`
- `schemas/state-health.schema.json`
- `schemas/state-export.schema.json`
- `schemas/state-compare-import-request.schema.json`
- `schemas/state-import-comparison.schema.json`
- `schemas/state-collection-comparison.schema.json`
- `schemas/state-import-request.schema.json`
- `schemas/state-import-summary.schema.json`
- `schemas/state-reset-request.schema.json`
- `schemas/state-reset-summary.schema.json`
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

Allowed audit acknowledgement statuses are `acknowledged`, `resolved`, and `dismissed`.

The Developer/Codex result contracts describe operator/API-mediated result capture for a work order before QA handoff. They record summary, changed paths, notes, agent id, and evidence refs in `runtime/state/developer_results.json`. They do not claim autonomous Codex execution, autonomous coding, live OpenAI/Codex API invocation, or no-manual-transfer success.

The policy settings contracts describe the small persisted `runtime/state/policy_settings.json` model used by `GET /policy-settings` and `PATCH /policy-settings`. The model includes `qa_handoff_policy_mode`, original and repair Developer/Codex result requirement flags, `allow_operator_override`, `updated_at`, and `updated_by`. When `allow_operator_override` is true, enforced readiness can expose a narrow override option only for policy-promoted missing Developer/Codex result blockers.

The policy override contract describes records persisted to `runtime/state/policy_overrides.json` and returned by `GET /policy-overrides`. Overrides are single-request, logged exceptions for `work_order_qa_handoff` or `repair_qa_handoff` targets. They require a non-empty reason, record `requested_by`, list overridden blockers, preserve any non-overridable blockers seen at request time, and link evidence refs. They do not mutate policy settings and do not become reusable permissions.

The audit review contracts describe derived responses for `GET /audit/summary`, `GET /audit/exceptions`, and `GET /audit/export`. The review model is built from existing JSON state: policy overrides, policy settings events, handoffs, QA results, repair requests, readiness blockers, events, evidence, cards, and work orders. Supported filters are `exception_type`, `severity`, `acknowledgement_status`, `card_id`, `work_order_id`, `handoff_id`, free-text `q`, plus bounded `limit` and `offset`. `acknowledgement_status=none` returns exceptions without a marker. Export supports `format=json` and `format=csv`; CSV includes acknowledgement status and reason fields. JSON export can include acknowledgement history when `include_history=true`.

The audit acknowledgement contract describes the small persisted `runtime/state/audit_acknowledgements.json` model used by `GET /audit/acknowledgements`, `POST /audit/acknowledgements`, and `PATCH /audit/acknowledgements/{id}`. A marker links to an exception through `exception_source_ref` where possible, also stores `exception_id`, and requires a non-empty reason. POST uses upsert semantics for the same `exception_source_ref`, so one active marker per durable source ref is enough for this slice. Acknowledgement writes `audit_exception_acknowledged`, `audit_exception_resolved`, or `audit_exception_dismissed` events plus `audit_acknowledgement` evidence.

The audit acknowledgement history contract describes the append-only `runtime/state/audit_acknowledgement_history.json` model used by `GET /audit/acknowledgement-history` and `GET /audit/acknowledgements/{id}/history`. Every create, upsert, and patch appends a history entry with `previous_status`, `new_status`, reason, changed by, changed at, exception refs, and evidence refs. The marker remains the current/latest review state; the history trail preserves prior triage changes. This is lightweight operator triage history, not a ticketing system, not an external audit ledger, not external audit acceptance, and not audit signoff.

The local state management contracts describe `GET /state/health`, `GET /state/export`, `POST /state/compare-import`, `POST /state/import`, and `POST /state/reset-demo`. They cover known JSON collections under `runtime/state`, seed fallback health, direct JSON export, read-only import preview, lightweight import into persistent `*.json` files, and guarded demo reset with the exact confirmation string `RESET_R19_DEMO_STATE`. Compare-import returns collection-level added, removed, changed, and unchanged counts plus warnings, blockers, and up to five sample ids for each added/removed/changed category. Changed detection is intentionally shallow: the same record id with different normalized JSON is counted as changed, and no deep field diff is produced. Object collections such as `policy_settings` and `status` compare as one object using the collection name as the id. Records without `id` are compared by list index and carry a limitation warning. Compare-import is read-only and does not write events or evidence; import and reset write `state_management` event/evidence entries. This is local demo/developer state preview only; it is not production backup/restore, not migration tooling, not a database migration framework, not autonomous agent execution, and not external audit acceptance.

The QA readiness contracts describe read-only preflight responses for `GET /work-orders/{id}/qa-readiness` and `GET /repair-requests/{id}/qa-readiness`. Readiness levels are `ready`, `warning`, and `blocked`; check statuses are `passed`, `warning`, and `blocked`.

Readiness is not persisted. In advisory mode, missing Developer/Codex result capture remains a warning and does not block handoff creation. In enforced mode, that missing-result warning is promoted to a blocker for original QA when `require_developer_result_for_qa` is true, and for repair QA when `require_developer_result_for_repair_qa` is true. Readiness responses classify blockers as `overridable_blockers` and `non_overridable_blockers`, plus `override_available`. Only the policy-promoted missing Developer/Codex result blocker can be overridable, and only when enforced mode and `allow_operator_override` are both active. Missing core records, broken repair linkage, invalid repair work orders, and duplicate active proposed/accepted QA handoffs remain non-overridable in all modes. This is a narrow exception path, not a full policy engine or governance document flow.

The handoff contracts describe an API-mediated dry-run role handoff. They do not claim autonomous A2A execution, background workers, OpenAI/Codex API invocation, or full product runtime.

QA handoffs may include `developer_result_id` and `developer_result_summary` when a submitted Developer/Codex result exists for the work order. Handoffs are still allowed without a result in advisory mode and should carry a visible warning summary. In enforced mode, configured missing-result blockers return HTTP 400 before handoff creation unless the request includes a valid, immediate operator override and no non-overridable blockers exist. Override-approved handoffs include `policy_override_id` and `policy_override_reason`; they can still have no `developer_result_id`.

The QA result contracts describe structured operator/API-mediated result capture after an accepted handoff. They do not claim autonomous QA execution, live agent testing, autonomous A2A, or no-manual-transfer success.

The repair request contracts describe an operator/API-mediated repair loop for failed or blocked QA results. Creating a repair request creates a linked Developer/Codex repair work order, but it does not claim autonomous repair, live agent execution, or automatic QA reruns.

Repair QA handoff fields are optional additions to the handoff and QA result records. A repair QA handoff uses `handoff_purpose: repair_qa`, links `repair_request_id`, carries the failed or blocked source `qa_result_id`, and uses `iteration_number` to show that the repair work order is being sent back through QA. Initial QA handoffs use `handoff_purpose: initial_qa` and iteration `1`.

The workflow iteration schema documents the read-only `GET /workflow-iterations` view derived from work orders, handoffs, QA results, and repair requests. It is not a persisted workflow engine. It is a compact chain view for the manual loop: original work order, failed or blocked QA result, repair work order, repair QA handoff, and repair QA result.

This remains a UI/API-mediated loop. The contracts do not claim autonomous A2A execution, autonomous QA, autonomous repair, no-manual-transfer success, full policy-engine coverage, or live OpenAI/Codex API invocation.
