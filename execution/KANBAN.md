# AIOffice Kanban

This board tracks the current reset implementation milestone only.

## Active Milestone
No post-R4 implementation milestone is open yet.

Objective:
Hold the completed bounded R4 baseline for audit review only, without opening later implementation scope by implication.

Exit Criteria:
- bounded R4 remains complete in repo truth
- no post-R4 implementation milestone is opened implicitly
- the replayable R4 proof and closeout package remain the current committed freeze surface

## Tasks

### `R4-001` Open R4 in repo truth
- Status: done
- Order: 1
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `governance/POST_R3_CLOSEOUT.md`, `governance/POST_R3_AUDIT_INDEX.md`
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: updated repo-truth surfaces plus explicit R4 milestone-brief document
- Done when: `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, and `governance/R4_CONTROL_KERNEL_HARDENING_AND_CI_FOUNDATIONS.md` open R4 without broadening the proved boundary

### `R4-002` Close chronology / integrity softness and harden lifecycle enforcement
- Status: done
- Order: 2
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `R4-001`
- Authority: `governance/DECISION_LOG.md`, `governance/OPERATING_MODEL.md`
- Durable output: hardened chronology and lifecycle validation plus focused tests that reject invalid chronology and transition states
- Done when: the earlier chronology or integrity softness is actually closed or transparently narrowed and invalid chronology or invalid lifecycle transitions fail closed under test

### `R4-003` Add explicit pipeline and scope foundation hardening
- Status: done
- Order: 3
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `R4-002`
- Authority: `governance/VISION.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: updated contracts or validators with explicit pipeline metadata, protected-scope declarations, and focused invalid-scope tests
- Done when: bounded work, planning, and artifact surfaces represent protected scope more explicitly, contradictory scope fails closed, and nothing implies Standard runtime productization

### `R4-004` Harden the bounded workflow loop already proved
- Status: done
- Order: 4
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `R4-002`, `R4-003`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: updated QA and remediation logic, hardened invalid handoff validation, and focused retry-ceiling tests
- Done when: retry exhaustion is explicit and durable, invalid handoff states are rejected, and the bounded loop stops instead of permitting indefinite softness

### `R4-005` Add a deterministic repo-local proof runner
- Status: done
- Order: 5
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `R4-002`, `R4-003`, `R4-004`
- Authority: `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`
- Durable output: one authoritative repo-local proof runner entrypoint plus invocation documentation
- Done when: one command produces a trustworthy fail-closed pass or fail result for the currently claimed bounded suite and is suitable for CI reuse

### `R4-006` Add CI/CD foundation wired to the proof runner
- Status: done
- Order: 6
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `R4-005`
- Authority: `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`
- Durable output: source-controlled GitHub Actions workflow that runs the deterministic proof runner
- Done when: CI exists in source control, runs the same proof entrypoint used locally, and stays bounded to the repo's actual proof claims

### `R4-007` Produce one replayable R4 hardening proof and closeout package
- Status: done
- Order: 7
- Milestone: `R4 Control-Kernel Hardening and CI Foundations`
- Depends on: `R4-004`, `R4-005`, `R4-006`
- Authority: `governance/ACTIVE_STATE.md`, `governance/R4_CONTROL_KERNEL_HARDENING_AND_CI_FOUNDATIONS.md`
- Durable output: replayable R4 proof package, R4 closeout, and post-R4 audit index with task-to-commit mapping and explicit non-claims
- Done when: the proof package is replayable from repo truth and the closeout says exactly what R4 proves and exactly what it still does not prove

## Explicitly Out Of Scope For This Milestone
- operator-visible or user-facing UI work
- Standard or subproject pipeline runtime
- rollback or broader recovery productization
- automatic resume behavior
- broader orchestration beyond the currently bounded chain
- donor backlog import or historical backfill
