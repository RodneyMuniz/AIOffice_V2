# AIOffice Operating Model

## Scope
This file defines the narrow execution and control model for the reset-era V1.

## Control Law
- Fail closed when required evidence, approval, or state reconciliation is missing.
- Use packets and bounded artifacts instead of free-form executor authority.
- Separate intent capture, structured collaboration, bounded execution, evidence return, review, and durable state update.
- Stop safely when proof is insufficient.

## Roles And Authority
### Operator
- sets intent
- selects or approves execution profile
- approves or rejects mutation and promotion
- remains final authority

### Control Kernel
- enforces stage order and contract rules
- records durable state
- validates required approvals
- blocks unsafe or under-evidenced mutation

### Reasoning Or Orchestration Assistance
- helps structure work
- proposes packets and artifacts
- may summarize or transform evidence
- cannot silently authorize mutation

### Bounded Executor
- performs narrowly scoped work
- returns artifacts and evidence
- cannot redefine scope or self-promote output

## Stage Sequence
The working stage sequence for the first proof slice is:
1. `intake`
2. `pm`
3. `context_audit`
4. `architect`

This is the end of the required live collaboration proof.

After `architect`, the required downstream behavior is not a broad lane system. It is a bounded reviewed `apply/promotion` path that can safely move approved intent into mutation or accepted state.

## Artifact Contracts
Each stage should emit a bounded artifact with:
- stage identity
- scope and assumptions
- inputs used
- output produced
- unresolved risks or blockers
- explicit approval status where applicable

The control model should prefer named packets and records over chat-only flow.

## Apply/Promotion Path
The first real proof must include a bounded control path after `architect` with the following properties:
- explicit operator approval
- clearly defined mutation or promotion scope
- evidence linking the mutation to the approved artifact set
- Git-visible or otherwise durable trace of what changed
- persisted state reconciliation after the action

If any of these conditions are missing, the system should stop and report blocked status.

## Truth Model
The operating model keeps these surfaces distinct:
- local working output
- persisted operational state
- Git-visible accepted artifacts
- remote publication or verification state when applicable

Reporting must not collapse these into a single narrated status.

## Blocked-State Rules
Block the workflow when:
- required artifact inputs are missing
- cost or ambiguity exceeds the approved profile
- approval is absent or ambiguous
- mutation scope is broader than the approved packet
- persisted state and Git-visible state cannot be reconciled

Blocked status is a valid outcome. Silent drift is not.

## Current Exclusions
The current operating model does not require:
- design lane activation
- implementation, QA, or release lane proof
- broad UI surfaces
- Standard or subproject orchestration
- migration of donor planning state
