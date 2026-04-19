# AIOffice Operating Model / Governance Spec

**Document status:** Draft v1  
**Document type:** Operating model, governance, and technical control baseline  
**Parent documents:** `AIOffice Product Constitution / Vision`, `AIOffice V1 PRD / MVP Spec`  
**Purpose of this document:** Define how AIOffice must operate, how authority is enforced, how handovers work, what technical boundaries exist, and what artifacts/states are required for controlled execution.

---

## 1. Purpose

This document defines the working mechanics of AIOffice V1.

It translates the constitutional product truth and the V1 PRD into an enforceable operating model.

It covers:
- role boundaries
- pipeline separation
- request routing
- handover rules
- stage gates
- packet and bundle contracts
- state transitions
- validation loops
- cost stops
- rollback discipline
- technical control surfaces

It is intentionally more technical than the Constitution and more operational than the PRD.

---

## 2. Scope

This document governs **AIOffice building AIOffice** and **AIOffice building standard sub-project software work**.

It does **not** yet define:
- advanced multi-milestone autonomy
- multi-user collaboration
- image/audio lanes
- multi-provider AI routing
- generalized marketplace of specialist lanes

This document assumes V1 scope:
- one operator
- GPT / OpenAI API / Codex only
- software-first workflows
- one unified workspace
- milestone-level maximum autonomy
- per-task budget enforcement

---

## 3. Governing Principles

### 3.1 Fail closed
If authority, state, routing, budget, or validation status is ambiguous, the system must stop or remain blocked.

### 3.2 One process, two scopes
Admin and Standard pipelines use the same process shape, but different access scopes.

### 3.3 Orchestrator is not an implementer
The Orchestrator may clarify and route. It may not read project files directly, run implementation tools, or mutate canonical state.

### 3.4 PM owns structured work
The PM is the formal owner of request refinement, acceptance criteria, milestone/task shaping, and canonical-state updates.

### 3.5 QA is mandatory
No task may be promoted without a mandatory review/QA pass.

### 3.6 Promotion is explicit
Artifacts may be produced automatically. Promotion may not happen automatically for meaningful work.

### 3.7 Git is rollback truth
Approved milestone/version recovery must be grounded in Git, not chat memory.

### 3.8 Partial results may survive
Partial work may remain visible and resumable, but it must remain **unpromoted** until accepted.

### 3.9 Product state outranks transcript memory
Accepted state, bundles, snapshots, and baton artifacts outrank narrative thread continuity.

### 3.10 Authority outranks convenience
A faster route is invalid if it weakens pipeline scope or review gates.

---

## 4. System Overview

AIOffice V1 has five logical layers:

1. **Operator Surface**
2. **Routing and Planning Layer**
3. **Execution and Validation Layer**
4. **State and Artifact Layer**
5. **Versioning and Recovery Layer**

### 4.1 High-level operating view

```text
Operator
  -> Unified Workspace
      -> Chat / Intake
      -> Kanban Board
      -> Approvals Queue
      -> Cost Dashboard
      -> Settings / Admin Panel

Unified Workspace
  -> Orchestrator
      -> PM
          -> Architect/Dev
              -> QA
                  -> Operator decision

Supporting control services
  -> Routing and scope gate
  -> Budget gate
  -> State machine
  -> Snapshot service
  -> Git integration
  -> Artifact registry
  -> Evidence store
```

### 4.2 Technical control view

```text
[Operator UI]
    |
    v
[Intake + Board Actions]
    |
    v
[Orchestrator Service] -- classification only
    |
    v
[PM Service / Planning Logic]
    |
    +--> creates Request Brief / Milestone Draft / Task Packet / Change Proposal / Bug Package
    |
    v
[Execution Gate]
    |- validates pipeline scope
    |- validates task state
    |- validates budget threshold
    |- validates required sensors
    |- validates route type
    v
[Architect/Dev Executor via GPT/OpenAI API/Codex]
    |
    v
[QA / Review Executor]
    |
    v
[Approval Queue]
    |
    v
[PM Canonical State Update]
    |
    v
[Git + Snapshots + Current State + Evidence]
```

---

## 5. Operating Roles

## 5.1 Operator

The Operator is the only human authority in V1.

The Operator may:
- create requests
- answer clarification questions
- trigger execution from visible surfaces
- force-stop running work
- approve or reject outcomes
- approve rollback
- approve admin-scope changes

The Operator must not be bypassed for:
- promotion of meaningful changes
- AIO core changes
- governance changes
- rollback actions with material impact

---

## 5.2 Orchestrator

The Orchestrator is the user-facing intake role.

### Allowed actions
- classify request type
- ask light follow-up questions
- improve phrasing or request structure
- collect missing minimum fields
- determine whether request is ready for PM
- route to the correct downstream role

### Forbidden actions
- no direct file access
- no code execution
- no test execution
- no hidden tool use inside project scope
- no canonical-state mutation
- no direct artifact promotion

### Working rule
The Orchestrator is a **router + clarifier**, not a hidden worker.

---

## 5.3 PM

The PM is the formal refinement and work-structuring authority.

### Allowed actions
- accept routed requests from Orchestrator
- refine requests into formal work objects
- define acceptance criteria
- define task metadata and budget threshold
- define required sensors
- create milestone drafts and task packets
- reject malformed or insufficient requests
- return clarification requests to Operator
- update canonical state after operator decision

### Forbidden actions
- may not bypass QA
- may not silently broaden scope
- may not treat ambiguous inputs as approved facts

### PM special rule
Only the PM may update canonical current state.

---

## 5.4 Architect/Dev

Architect and Developer are combined into a single full-stack execution role for V1.

### Allowed actions
- inspect task packet and approved context
- implement bounded changes within assigned scope
- analyze artifacts for root cause
- generate outputs and execution evidence
- return implementation bundle to QA

### Forbidden actions
- may not self-promote
- may not expand scope beyond packet
- may not change protected AIO core when on Standard pipeline
- may not update canonical current state

---

## 5.5 QA

QA is the mandatory validation and promotion-blocking role.

### Allowed actions
- review outputs against PM criteria
- run required sensors
- fail, pass, or block a task
- send work back to Architect/Dev
- stop promotion when criteria are not met

### Forbidden actions
- may not silently redefine scope
- may not auto-accept work on behalf of Operator
- may not mutate canonical state

### Retry rule
QA may return work to Architect/Dev up to **4 remediation attempts**.
On the fifth unresolved cycle, the task must stop and return to Operator with current status.

---

## 5.6 Admin pipeline variant

Admin work uses the same roles, but with elevated scope to AIO core files, policies, and protected configuration.

This is not a special shortcut mode.
It is the same process with a larger allowed authority scope.

---

## 6. Two Pipelines

## 6.1 Standard pipeline

Used for sub-project work.

### Scope
- sub-project folders
- sub-project artifacts
- sub-project milestones/tasks/bugs
- sub-project code and documentation

### Prohibition
It may consume AIO conventions, but it may not mutate protected AIO core rules, root policies, or core machinery.

---

## 6.2 Admin pipeline

Used for AIO self-improvement.

### Scope
- AIO core product code
- AIO governance rules
- AIO templates and operating structures
- AIO protected root artifacts
- AIO system configuration under admin control

### Caution rule
All admin changes are high-risk by default.

---

## 6.3 Pipeline selection rule

Pipeline must be determined before any task packet is generated.

### Standard indicators
- request changes only a sub-project
- request produces a software artifact using existing factory rules
- request does not alter AIO protected structures

### Admin indicators
- request changes AIO core behavior
- request changes governance or policy
- request changes system-level conventions or root structure
- request changes core routing, role model, milestone logic, file protection, or other base product machinery

If uncertain, classify as **Admin candidate** and require explicit confirmation.

---

## 7. Request Types

A request entering AIOffice must be classified into one of the following working types:

1. project create/edit
2. milestone create/edit
3. task create/edit
4. bug create/edit
5. status question
6. admin change
7. recovery / resume request
8. rollback request
9. research / refinement request

### 7.1 Request type notes

- **Status question** is treated as normal work, but may not require execution.
- **Bug** is a task subtype under a project.
- **Research / refinement** is valid when the user says they do not know enough and wants help clarifying.
- **Admin change** always requires pipeline review.

---

## 8. Object Model

## 8.1 Planning hierarchy

```text
AIOffice
  -> Project
    -> Milestone
      -> Task
```

Special self-build path:

```text
AIOffice
  -> AIOffice
    -> Milestone
      -> Task
```

---

## 8.2 Core objects

### Project
Represents a single governed software effort.

Minimum fields:
- project_id
- project_name
- pipeline_type default
- project_status
- project_scope_summary
- protected_scope_flag
- root_artifact_refs
- current_state_ref
- active_milestone_ids

### Milestone
Represents a planning container for grouped task progress.

Minimum fields:
- milestone_id
- project_id
- title
- objective
- status
- planned_task_ids
- approved_branch_or_baseline_ref
- milestone_acceptance_summary

### Task
Represents the atomic governed work unit.

Minimum fields:
- task_id
- project_id
- milestone_id
- task_subtype
- pipeline_type
- title
- goal
- acceptance_criteria
- required_sensors
- budget_threshold
- current_status
- retry_count
- artifact_refs
- dependency_refs
- evidence_refs
- baton_ref if any

### Run
Represents one execution attempt for a task.

Minimum fields:
- run_id
- task_id
- route_type
- started_at
- ended_at
- snapshot_ref
- spend_to_date
- outcome_status

### Bundle
Represents the execution return package.

Minimum fields:
- bundle_id
- task_id
- run_id
- changed_artifacts
- outputs_summary
- validations_run
- validations_result
- assumptions
- blockers
- risks
- next_action

### Baton
Represents resumable short-term state.

Minimum fields:
- baton_id
- task_id
- current_state
- last_completed_step
- spend_to_date
- pending_blockers
- exact_resume_inputs

---

## 8.3 Task subtypes

- standard
- bug
- admin

Bug remains a task subtype, not a separate hierarchy root.

---

## 9. Canonical Document and State Classes

AIOffice must distinguish document purpose clearly.

## 9.1 Class A: Constitutional truth
Stable product truth.
Examples:
- Product Constitution / Vision
- V1 PRD / MVP Spec
- Operating Model / Governance Spec

## 9.2 Class B: Operational truth
Current live working state.
Examples:
- current active milestone state
- board state
- active project state
- current accepted work objects

## 9.3 Class C: Execution evidence
Run-specific proof.
Examples:
- task packets
- return bundles
- QA reports
- snapshots
- baton files
- validation results

## 9.4 Class D: Historical archive
Past accepted or rejected material retained for traceability.
Examples:
- retired milestone plans
- rejected bundles
- superseded current-state snapshots
- archived research packs

### Canonical rule
Chat text is not canonical by itself.
It becomes durable truth only when promoted into the correct artifact class.

---

## 10. Technical Boundary Model

AIOffice V1 should operate with a protected root and contained project spaces.

### 10.1 Root concept

```text
AIOffice Root
  |- Protected AIO core area
  |- Shared operating documents and services
  |- Sub-project area(s)
```

### 10.2 Protected AIO core area
Contains items that may be changed only through Admin pipeline.

Typical examples:
- core application code
- governance logic
- role model definitions
- root conventions
- protected templates
- routing logic
- state machine logic
- policy/config controlling scope enforcement

### 10.3 Sub-project area
Contains project-specific work products.

Typical examples:
- project code
- project requirements
- project-specific tasks/bugs
- project outputs
- project-local evidence

### 10.4 Protection rule
Standard pipeline may read shared conventions as needed, but may not mutate protected AIO root assets.

### 10.5 Initial technical recommendation
Even if the exact folder structure is still being refined, the implementation should support:
- explicit scope labels
- protected/unprotected path tagging
- route-time scope validation before execution
- task packet allowed-scope declaration

---

## 11. Minimum Permission Matrix

| Role | Standard pipeline read | Standard pipeline write | Admin pipeline read | Admin pipeline write | Canonical-state update |
|---|---|---|---|---|---|
| Operator | visible surfaces only | decision actions only | visible surfaces only | decision actions only | no |
| Orchestrator | no direct file read | no | no direct file read | no | no |
| PM | project metadata and approved context | planning artifacts and canonical state | admin planning metadata and approved context | admin planning artifacts and canonical state | yes |
| Architect/Dev | task-scoped artifacts only | task-scoped implementation outputs | admin task-scoped protected artifacts when allowed | admin task-scoped outputs when allowed | no |
| QA | task-scoped artifacts and bundle | QA reports / validation outcomes | admin task-scoped artifacts and bundle | QA reports / validation outcomes | no |

### Permission rule
Permissions must be enforced both by role and by pipeline scope.

---

## 12. Stage Model and Task States

## 12.1 Task state list

| State | Meaning |
|---|---|
| Intake | request captured, not yet structured |
| Clarification | Orchestrator collecting or resolving minimum input |
| PM Review | PM shaping formal work objects |
| Ready | formal task exists and may be queued for execution |
| In Progress | active implementation run underway |
| QA | mandatory validation underway |
| Approval | waiting for operator decision |
| Accepted | promoted and eligible for canonical-state update |
| Rejected | explicitly rejected by operator |
| Blocked | cannot proceed because a gate is unmet |
| Paused | intentionally stopped but resumable |
| Rolled Back | superseded by approved restore action |
| Archived | closed and not active |

---

## 12.2 Allowed primary transitions

```text
Intake -> Clarification -> PM Review -> Ready -> In Progress -> QA -> Approval -> Accepted
                                              |             |       |         |
                                              |             |       |         -> Rejected
                                              |             |       -> Blocked
                                              |             -> Paused
                                              -> Rejected

Accepted -> Rolled Back (only by explicit recovery decision)
Any active state -> Paused (budget/manual stop)
Any unresolved gate -> Blocked
```

### Transition rule
No state jump is allowed if the required predecessor artifact is missing.

---

## 13. Handover Rules and Entry/Exit Criteria

## 13.1 Orchestrator exit criteria

The Orchestrator may hand work to PM only when it can produce a minimum intake frame.

### Minimum intake frame
- request type
- target project or candidate project
- pipeline candidate
- rough goal
- whether user is asking to create, change, diagnose, recover, or question
- any explicit constraints already known

### If missing
The Orchestrator must ask the user directly.

### If user does not know
The Orchestrator may route a **research/refinement** request to PM.

### Orchestrator fail rule
If the Orchestrator cannot classify the request even after clarification, it must block the request instead of inventing certainty.

---

## 13.2 PM entry criteria

PM accepts work when the intake frame is sufficient to do one of two things:

1. transform it into formal work artifacts, or
2. reject it with precise missing-information feedback

### PM minimum inputs
- request type
- target scope candidate
- request goal
- user constraint summary if any

---

## 13.3 PM exit criteria

PM may send work forward only when all required formal structure exists for that request type.

### Minimum PM outputs by request type

| Request type | Minimum PM output |
|---|---|
| project create/edit | Request Brief + project-level change framing |
| milestone create/edit | Milestone Draft |
| task create/edit | Task Packet |
| bug create/edit | Bug Report Package + Task Packet |
| admin change | Change Proposal + Task Packet |
| research/refinement | Request Brief with recommendations or follow-up options |
| status question | direct structured answer or routed investigation task |
| rollback request | Rollback Proposal |
| recovery/resume | Resume Brief |

### PM must define
- acceptance criteria
- required sensors
- budget threshold per task
- whether execution may be queued automatically or must wait
- pipeline type
- dependencies if known

---

## 13.4 Architect/Dev entry criteria

Architect/Dev may start only when all of the following exist:
- task packet
- allowed scope
- required sensors declared
- route type selected
- budget threshold present
- retry count within limit
- task state = Ready or valid resumed state

If any are missing, execution must not start.

---

## 13.5 QA entry criteria

QA may start only when:
- execution bundle exists
- outputs/artifacts are attached or referenced
- validations required by packet are known
- task has not exceeded retry ceiling

---

## 13.6 Approval entry criteria

A task may move to Approval only when:
- QA pass exists
- bundle is complete
- current risks are visible
- task is still within intended authority scope

---

## 13.7 PM canonical-state update criteria

PM may update canonical state only after:
- operator accepted the output
- promotion decision is recorded
- accepted artifacts are identified
- affected current-state objects are known

---

## 14. Formal Artifact Contracts

## 14.1 Request Brief

Purpose: structured intent baseline.

Minimum fields:
- brief_id
- request_type
- pipeline_type candidate
- target project
- user goal
- current problem or desired change
- constraints
- unknowns
- recommended next step

---

## 14.2 Milestone Draft

Purpose: planning proposal for grouped work.

Minimum fields:
- milestone_id draft or placeholder
- project reference
- milestone objective
- included tasks
- dependency notes
- acceptance definition
- risk notes

---

## 14.3 Task Packet

Purpose: execution contract.

Minimum fields:
- task_id
- pipeline_type
- project and milestone refs
- task subtype
- task goal
- allowed scope
- disallowed scope
- acceptance criteria
- required sensors
- route type
- budget threshold
- retry count
- upstream artifact refs
- explicit assumptions

### Task Packet rule
No meaningful execution may occur without a Task Packet.

---

## 14.4 Change Proposal

Purpose: admin or high-impact change framing.

Minimum fields:
- proposal_id
- impacted protected scope
- reason for change
- intended effect
- risk summary
- rollback expectation
- approval requirement

---

## 14.5 Bug Report Package

Purpose: structured diagnosis entry.

Minimum fields:
- bug_id
- affected project
- symptom
- suspected area if known
- steps to reproduce if known
- expected behavior
- current behavior
- severity indication
- linked task or milestone if known

---

## 14.6 Rollback Proposal

Purpose: controlled restore request.

Minimum fields:
- target project
- approved baseline to restore
- reason for rollback
- impact summary
- forward path expectation after restore

---

## 14.7 Resume Brief

Purpose: restart paused work safely.

Minimum fields:
- task_id
- current state
- last completed step
- spend to date
- pending blocker if any
- exact artifacts to reload

---

## 14.8 Execution Return Bundle

Purpose: proof package returned by Architect/Dev.

Minimum fields:
- bundle_id
- task_id
- run_id
- outputs produced
- changed artifacts/files
- validations already run if any
- assumptions
- blockers
- risks
- next recommended action
- snapshot reference

---

## 14.9 QA Report

Purpose: validation decision package.

Minimum fields:
- qa_report_id
- task_id
- run_id
- criteria checked
- sensors run
- pass/fail result
- remediation notes if failed
- retry_count

---

## 14.10 Baton

Purpose: resumable compact context.

Minimum fields:
- baton_id
- task_id
- current state
- last completed step
- spend to date
- unresolved blockers
- exact resume inputs

---

## 15. Execution Gate

Before a task starts execution, AIOffice must pass a gate check.

### 15.1 Gate checks
- task exists
- task state is eligible
- pipeline type is set
- allowed scope is set
- route type is set
- required sensors are declared
- budget threshold exists
- retry count is within limit
- manual stop flag is not active

### 15.2 Missing gate behavior
If any check fails, task becomes **Blocked** and execution is not launched.

### 15.3 UI trigger rule
Dragging a card to **In Progress** must call the execution gate.
The UI action is only a request to execute, not execution itself.

---

## 16. Route Types

V1 supports two route types:

1. **Synchronous route**
2. **Background route**

### 16.1 Synchronous route
Use when the work is short, interactive, or needs immediate operator visibility.

### 16.2 Background route
Use when the work is heavier, may take longer, or needs less direct UI blocking.

### 16.3 Route selection rule
PM or task policy defines the initial route.
Execution gate confirms eligibility.

---

## 17. Validation Model

## 17.1 Mandatory V1 software sensors
- lint
- unit tests
- security checks when applicable
- dependency validation

## 17.2 Optional sensor expansion
Additional sensors may exist later, but V1 requires the declared minimum.

## 17.3 Validation sequence

```text
Architect/Dev returns bundle
-> QA runs required checks
-> if failed: return to Architect/Dev
-> if passed: move to Approval
```

## 17.4 Retry ceiling
Maximum remediation loops between Architect/Dev and QA: **4**

## 17.5 Ceiling behavior
After retry ceiling is hit:
- stop loop
- preserve current status
- surface cost spent
- surface unresolved blockers
- request operator decision

---

## 18. Cost and Stop Controls

## 18.1 Per-task budget control
Budget must be set at task level.

## 18.2 Threshold hit behavior
When spend exceeds threshold:
- stop active route or pause cleanly
- create/update baton
- preserve partial output as unpromoted
- mark task for operator review

## 18.3 Manual hard stop
The Operator must be able to stop a route at any time.

## 18.4 Stop result rule
A stop does not destroy partial work automatically.
It preserves work and waits for decision unless rollback rules require otherwise.

---

## 19. Snapshot, Versioning, and Rollback

## 19.1 Run snapshot rule
Every execution run must produce a run snapshot reference.

## 19.2 Milestone baseline rule
At milestone approval, create a Git branch/worktree or equivalent approved baseline reference.

## 19.3 Rollback source of truth
Rollback must use an approved Git-backed milestone/version baseline.

## 19.4 Rollback behavior

```text
Operator requests rollback
-> PM produces Rollback Proposal
-> approval confirmed
-> restore approved baseline
-> mark project/task state as Rolled Back where relevant
-> future work branches forward from restored version
```

## 19.5 Sensor-triggered rollback note
If sensors fail, rollback may be recommended, but operator decision is still required unless an explicitly pre-authorized low-risk auto-revert exists.

---

## 20. Baton and Resume Model

## 20.1 Baton timing
A baton is required at task level whenever work is:
- paused
- threshold-stopped
- manually stopped
- interrupted by unresolved blocking condition

## 20.2 Minimum resume loading rule
Resume should load:
- task packet
- latest valid baton
- relevant bundle/snapshot refs
- only the exact artifacts needed

Resume should not load:
- full old transcripts by default
- obsolete milestone plans

## 20.3 Resume rule
Resume must restart from the last accepted step, not from speculative narrative reconstruction.

---

## 21. Approval and Promotion Model

## 21.1 Promotion stages
A task becomes promotable only after:
- execution completed within scope
- QA pass exists
- bundle is complete
- operator decision is collected

## 21.2 Accepted path

```text
Approval accepted
-> PM updates canonical state
-> accepted artifacts become current operational truth
-> project/milestone/task state updated
```

## 21.3 Rejected path

```text
Approval rejected
-> task marked Rejected or returned for rework
-> bundle retained as evidence
-> canonical current state unchanged
```

## 21.4 PM-only mutation rule
Only PM writes canonical accepted state.
Other roles contribute evidence, not canonical truth.

---

## 22. State Machine Failure Rules

If any of the following occur, the task must fail closed or block:
- no pipeline type
- no allowed scope
- no task packet
- missing required sensors
- retry count exceeds limit
- task is triggered from invalid state
- Standard pipeline requests protected root mutation
- budget threshold missing
- current state conflicts with requested transition

### 22.1 Conflict rule
When state and evidence disagree, the system must block until reconciled.

---

## 23. Unified Workspace Mapping

V1 has one unified workspace with five visible surfaces.

## 23.1 Chat / Intake
Used for:
- natural-language request entry
- orchestrator clarification
- intake classification feedback

## 23.2 Kanban Board
Used for:
- visible project/milestone/task state
- drag-to-trigger execution
- blocked/paused/approval visibility

## 23.3 Approvals Queue
Used for:
- accept/reject decisions
- viewing QA result and bundle summary
- promoting accepted work

## 23.4 Cost Dashboard
Used for:
- per-task spend visibility
- threshold status
- stop action visibility

## 23.5 Settings / Admin Panel
Used for:
- admin access pathway
- protected system settings
- visibility into system-level controls

---

## 24. Suggested Technical Service Decomposition

This section is a technical implementation suggestion for easier ingestion. It is not a claim that all services must be physically separate in V1.

## 24.1 Logical services

| Service | Responsibility |
|---|---|
| Intake Service | receive user request, store intake state |
| Orchestrator Service | classify and clarify only |
| Planning Service | PM logic, work-object creation, canonical-state updates |
| Execution Gate Service | validate route eligibility before run |
| Execution Service | launch Architect/Dev work via GPT/OpenAI API/Codex |
| QA Service | validation and retry loop |
| Approval Service | manage operator decisions |
| Snapshot Service | create run snapshots and milestone baselines |
| Recovery Service | baton, resume, rollback handling |
| Scope Guard Service | enforce Admin vs Standard path boundaries |
| Artifact Registry | map artifacts, evidence, and references |
| Cost Service | record per-task spend and stop conditions |

### 24.2 Physical simplification note
V1 may implement several of these inside one application/backend, but the responsibilities should still remain conceptually separate.

---

## 25. Recommended Initial Sequence of Enforcement

To avoid building UI ahead of trust, the operating model should be enforced in this order:

1. pipeline classification and scope protection
2. object model and task packet contract
3. state machine and gate checks
4. QA/retry/approval loop
5. snapshot and rollback discipline
6. cost stops and baton discipline
7. UI trigger wiring and visibility

This sequence aligns with the requirement to protect AIO core first.

---

## 26. Non-Negotiable V1 Invariants

The following must remain true in V1:

1. Standard pipeline cannot mutate protected AIO core.
2. Orchestrator cannot directly execute or mutate state.
3. PM is the only canonical-state writer.
4. QA is mandatory before promotion.
5. Retry loop cannot exceed 4 remediation cycles.
6. Every execution run has a snapshot reference.
7. Every paused/stopped task has a baton.
8. Every task has a budget threshold.
9. Every meaningful execution requires a Task Packet.
10. Dragging a card to In Progress is gated, not direct execution.
11. Git-backed approved baseline is required for rollback.
12. Ambiguity in scope or state blocks the task.

---

## 27. Open Technical Decisions Still Intentionally Deferred

This document does **not** yet freeze the following implementation details:
- exact folder tree names
- exact database schema
- exact framework choice for UI/backend
- exact storage location for artifacts/batons/snapshots
- exact Git strategy details beyond milestone baseline requirement
- exact method of mapping shared versus project-local artifacts

Those should be decided later without violating the operating model defined here.

---

## 28. Closing Definition

AIOffice V1 is not just a chat assistant wrapped in a board.

Under this operating model, it is a governed software-production system where:
- the Operator speaks in natural language
- the Orchestrator clarifies and routes
- the PM structures and owns canonical truth
- the Architect/Dev executes within bounded scope
- QA validates and may block
- promotion is explicit
- cost is bounded per task
- Git anchors rollback
- Admin and Standard work share one process but not one authority scope

That is the minimum operating model required for AIOffice to safely build itself and later earn the right to build other products.
