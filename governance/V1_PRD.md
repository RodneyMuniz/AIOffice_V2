# AIOffice V1 PRD

## Status
This PRD defines the narrow current V1 only.

## Product Goal
Prove that AIOffice can supervise model-assisted software production through `architect`, keep authority above execution, and support a bounded reviewed `apply/promotion` path backed by Git and persisted state.

## Primary User
- an admin operator building and running the system directly

V1 is not designed for broad end-user rollout or general team self-service.

## Problem Statement
Model output is useful but unsafe as authority. Teams need a harness that can structure work, contain execution, preserve artifacts, require review, and keep durable truth separate from narration.

## Product Stance
V1 is:
- admin-only
- self-build first
- narrow and supervised
- artifact-backed
- honest about what is proved today

## In Scope
V1 must support:
- explicit operator-directed workflow
- staged collaboration up to `architect`
- bounded artifact contracts instead of free-form executor authority
- review-before-mutation control
- a bounded `apply/promotion` path as part of the first real proof
- Git plus persisted state as truth substrates
- a docs-first or API-first operating surface

## Required Stage Coverage
The canonical stage vocabulary remains:
- `intake`
- `pm`
- `context_audit`
- `architect`

For current V1, live proof is only required through `architect`.

After `architect`, V1 must prove only a bounded reviewed `apply/promotion` path. It does not need to prove a broad downstream lane system.

## Required Artifacts
At minimum, V1 should be able to produce and govern:
- an intake artifact that captures bounded intent
- a planning artifact that structures the work packet
- a context audit artifact that records the evidence basis
- an architect artifact that defines the approved change intent
- an `apply/promotion` artifact that records review, approval, and mutation scope
- persisted state that can reconcile current status against Git-visible artifacts

## Acceptance Criteria
V1 is acceptable when it can demonstrate all of the following:
- the operator remains explicit authority throughout the flow
- the system can run a supervised path through `architect`
- artifacts are reviewable and bounded at each step
- no mutation occurs without explicit approval
- the `apply/promotion` path is bounded and evidenced
- state reporting distinguishes local drafts from accepted truth

## Out Of Scope For Current V1
Current V1 does not require:
- a broad UI or control-room
- a Standard pipeline or subproject orchestration system
- later-lane live workflow proof beyond `architect`
- unattended or autonomous operation
- migration of legacy tasks, milestones, or planning history
- claims of broad product completeness

## Non-Claims
This PRD does not claim that the broader AIOffice product vision is already implemented. It defines only the first narrow proof slice that the clean repo is expected to make real.
