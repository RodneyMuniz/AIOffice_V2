# R4 Control-Kernel Hardening and CI Foundations

## Milestone name
`R4 Control-Kernel Hardening and CI Foundations`

## Why this milestone exists now
R3 completed one bounded internal planning slice and the post-R3 freeze package made that slice audit-ready without opening a next-phase implementation milestone.

The next defensible move is still not UI, not Standard or subproject pipeline runtime, and not rollback or automatic-resume productization. The next bounded move is to harden the internal control kernel, lifecycle integrity, scope discipline, QA-loop stop rules, and CI-backed proof discipline so later UX is built on something trustworthy.

## Objective
Strengthen internal state integrity, lifecycle enforcement, scope enforcement, QA-loop boundaries, and CI-backed proof discipline without adding UI, without Standard pipeline runtime, without rollback productization, and without automatic resume claims.

## Exit criteria
- repo truth explicitly closes the post-R3 freeze posture and opens R4 without widening prior claims
- chronology and integrity softness from the earlier packet-record caution is genuinely closed or transparently narrowed with an exact remaining caution
- lifecycle and transition hardening exists and is test-backed
- pipeline and scope metadata are explicit enough to fail closed on contradictory bounded declarations
- deterministic repo-local proof running exists as one authoritative entrypoint for the currently claimed bounded suite
- CI/CD exists in source control and runs the same deterministic proof entrypoint
- the bounded QA loop records retry ceilings, blocked states, and stop behavior more explicitly and durably
- one replayable R4 proof package exists with task-to-commit mapping and explicit non-claims
- if later audit finds a closure blocker in `R4-005` through `R4-007`, the corrective work is recorded as new bounded R4 tasks rather than being hidden inside prior task history

## In scope
- state, chronology, and lifecycle hardening for the currently claimed bounded substrates
- closure of the known chronology or integrity softness carried forward from `RST-010`
- explicit pipeline metadata and protected-scope declarations for relevant bounded work, planning, and artifact surfaces
- bounded QA remediation and retry-ceiling hardening on the already proved request-to-task to QA to baton chain
- one deterministic repo-local proof runner suitable for CI reuse
- one GitHub Actions workflow that runs the deterministic bounded proof runner
- one replayable R4 hardening proof plus closeout and audit index surfaces

## Explicitly out of scope
- any operator-visible or user-facing UI work
- unified workspace work
- chat or intake UI
- approvals queue UI
- cost dashboard UI
- settings or admin UI
- truthful visibility surface
- Standard or subproject pipeline runtime
- rollback flow productization
- automatic resume behavior
- broader orchestration beyond the currently bounded chain
- donor backlog import or donor milestone migration

## Dependencies and prerequisites
- `RST-009` through `RST-012` remain complete and externally accepted
- `R3-001` through `R3-008` remain complete in repo truth
- `governance/POST_R3_CLOSEOUT.md` and `governance/POST_R3_AUDIT_INDEX.md` remain the bounded R3 freeze baseline
- Git and persisted state remain the authoritative truth substrates
- R4 remains admin-only and does not open Standard or subproject runtime claims

## Key risks
- hardening state integrity in a way that silently widens product claims
- treating metadata improvements as proof of broader productization
- adding CI as proof theater rather than a real bounded proof entrypoint
- allowing QA remediation handling to drift into a broader orchestrator or automatic-resume story
- overstating what pipeline or scope metadata proves before Standard runtime is actually implemented

## Task list

### `R4-001` Open R4 in repo truth
- Status: done
- Done when: repo truth explicitly closes the post-R3 freeze posture, creates this milestone brief, updates `governance/ACTIVE_STATE.md`, updates `execution/KANBAN.md`, and opens R4 without broadening the currently proved boundary

### `R4-002` Close chronology / integrity softness and harden lifecycle enforcement
- Status: done
- Done when: the earlier chronology or integrity softness is actually closed or transparently narrowed, invalid chronology and invalid transition states fail closed, and repo truth says exactly what was hardened

### `R4-003` Add explicit pipeline and scope foundation hardening
- Status: done
- Done when: the repo can represent and validate protected scope more explicitly than it does today, invalid scope declarations fail closed with focused tests, and nothing in repo truth implies Standard pipeline productization

### `R4-004` Harden the bounded workflow loop already proved
- Status: done
- Done when: the bounded chain is more rule-driven and less permissive, retry exhaustion is explicit and durable, invalid planning-to-QA-to-baton handoffs are rejected, and tests prove the intended stop behavior

### `R4-005` Add a deterministic repo-local proof runner
- Status: done
- Done when: one repo-local command produces a trustworthy fail-closed pass or fail result for the currently claimed bounded suite and is suitable for CI reuse

### `R4-006` Add CI/CD foundation wired to the proof runner
- Status: done
- Done when: the repo has source-controlled CI automation that runs the same deterministic proof entrypoint used locally and the truth surfaces record CI as a foundation rather than proof of broader productization

### `R4-007` Produce one replayable R4 hardening proof and closeout package
- Status: done
- Done when: each R4 task is commit-mapped, the proof package is replayable from repo truth, and the closeout states exactly what R4 proves and exactly what it still does not prove

### `R4-008` Repair bounded proof runner clean-checkout behavior
- Status: done
- Revisits: `R4-005`
- Done when: the bounded proof runner handles an empty clean-workspace Git status correctly, fail-closed mutation checking is preserved, local bounded proof execution succeeds from a clean workspace, and regression coverage exists for the empty-status case

### `R4-009` Re-stabilize CI foundation on the real proof path
- Status: done
- Revisits: `R4-006`
- Done when: `.github/workflows/bounded-proof-suite.yml` runs successfully on the repaired proof runner, GitHub Actions is green on the relevant current head, and repo truth can honestly say the CI foundation is working for the bounded path it claims

### `R4-010` Regenerate proof package and evidence inventory cleanly
- Status: done
- Revisits: `R4-007`
- Done when: the proof package is regenerated from a clean workspace, the package is stamped to the actual replay source head used for the clean rerun, replay artifacts and metadata are internally consistent, and the evidence inventory no longer overstates what the committed replay package contains

### `R4-011` Reconcile post-R4 repo truth for honest closure readiness
- Status: done
- Revisits: `R4-005`, `R4-006`, `R4-007`
- Done when: `README.md`, `governance/ACTIVE_STATE.md`, `governance/POST_R4_CLOSEOUT.md`, `governance/POST_R4_AUDIT_INDEX.md`, and this milestone brief align with the corrected evidence state, repo truth says exactly what R4 proves and exactly what it does not prove, and no R5 milestone is opened

## Milestone notes
- R4 remains admin-only and foundation-focused.
- R4 does not open UI work, Standard runtime, rollback productization, automatic resume, or broader orchestration claims.
- The deterministic bounded proof entrypoint is `powershell -ExecutionPolicy Bypass -File tools\run_bounded_proof_suite.ps1`.
- The bounded CI foundation is `.github/workflows/bounded-proof-suite.yml`, which replays the same proof entrypoint on `push` and `pull_request` for `main`.
- The replayable bounded R4 proof package is `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/`.
- The committed replay package was regenerated from a clean workspace at replay source head `47b7cf99f1720c2f191f044e95b354de1a814047`, which is the corrective repo-truth open state created before the clean rerun.
- The post-R4 closeout surfaces are `governance/POST_R4_CLOSEOUT.md` and `governance/POST_R4_AUDIT_INDEX.md`.
- The `governance/Product Vision V1 baseline/` folder remains reference-only direction material and is not milestone evidence.
- The initial `R4-005` through `R4-007` delivery required the corrective completion layer `R4-008` through `R4-011` before honest closure could be claimed again.
