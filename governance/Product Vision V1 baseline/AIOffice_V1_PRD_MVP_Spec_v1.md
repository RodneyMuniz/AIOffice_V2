# AIOffice V1 PRD / MVP Spec

**Document status:** Draft v1  
**Document type:** V1 product requirements and delivery baseline  
**Parent document:** `AIOffice Product Constitution / Vision`  
**Companion documents:** future `Operating Model / Governance Spec`, future milestone tracker, future technical diagrams pack

---

## 1. Purpose

This document translates the AIOffice constitutional vision into a concrete V1 product target.

It defines:
- what V1 must deliver
- what is out of scope for V1
- the measurable milestone and task breakdown for building V1
- the KPI logic for percentage complete
- the current recommended next milestone

This document is for **building AIOffice itself**. It is not yet the PRD for general sub-project production at scale.

---

## 2. V1 Product Goal

### 2.1 V1 goal statement

AIOffice V1 must provide a **single-operator control room** that can:
- receive natural-language software requests in chat
- refine them through a governed orchestrator-to-PM loop
- convert them into structured projects, milestones, tasks, and bugs
- trigger bounded execution through GPT / OpenAI API / Codex
- validate outputs through mandatory QA and sensors
- present evidence and approvals back to the operator
- update durable current state without context collapse
- protect AIO core from normal sub-project changes
- rollback to a previously approved milestone/version when needed

### 2.2 V1 success definition

V1 is successful when the operator can do all of the following in one coherent product:
1. create a project from chat and receive structured milestones/tasks
2. run governed code changes with lint/tests/evidence
3. pause and resume without losing operational context
4. manage AIOffice itself and normal sub-projects through the same operating model
5. rollback to a previously approved and tested milestone/version and branch forward from there

### 2.3 V1 product slice

The minimum valid production loop is:

```text
operator enters a request
-> system refines it into a structured task/request brief
-> task appears in a visible surface
-> bounded execution can be triggered
-> artifact comes back
-> validation comes back
-> operator can approve/reject
-> current-state is updated
```

If this slice is not real, V1 is not real.

---

## 3. V1 Scope

### 3.1 In scope for V1

#### A. Core workspace
- unified workspace for one operator
- chat/intake view
- kanban board
- approvals queue
- cost dashboard
- settings/admin panel

#### B. Request handling
- orchestrator as router + clarifier
- light clarification
- missing-field collection
- readiness detection
- direct user follow-up when information is missing
- PM-owned refinement after orchestrator exit

#### C. Planning objects
- hierarchy: `AIOffice -> Project -> Milestone -> Task`
- special case: `AIOffice -> AIOffice -> Milestone -> Task`
- bug as task subtype
- one project per bug

#### D. Two protected pipelines
- Admin pipeline for AIO core changes
- Standard pipeline for sub-project changes
- same flow shape, different authority scope

#### E. Execution and validation
- low-risk packet auto-generation allowed
- sync and background execution routes
- mandatory review agent pass
- mandatory QA gate before promotion
- QA can block promotion
- architect/dev and QA retry loop up to 4 times
- per-task cost threshold stop
- human brute-force stop capability

#### F. Evidence and state
- return bundle with artifacts, evidence, sensors, blockers, assumptions, and next action
- PM as the only role allowed to update canonical current state
- run snapshots
- milestone branch/worktree creation after milestone approval
- rollback using git as primary source of truth
- task-level baton/resume discipline

#### G. Platform model
- GPT / OpenAI API / Codex only
- no secondary AI engine behind the scenes
- Surge execution posture only for V1

### 3.2 Explicitly out of scope for V1

The following are intentionally deferred:
- audio generation
- image generation
- knowledge graph implementation
- multi-milestone autonomy
- advanced execution tiers
- fancy design lane
- generalized marketplace of specialist lanes
- team/multi-user collaboration
- non-OpenAI multi-provider AI strategy
- economy and balanced execution modes

---

## 4. V1 Product Principles

1. **AIO core must be protected from standard work.**
2. **The operator must always see real state, not narration.**
3. **The PM owns structured refinement and canonical-state updates.**
4. **The orchestrator may clarify, but may not execute or mutate state.**
5. **QA is mandatory and may block promotion.**
6. **Cost must be bounded at task level.**
7. **Rollback must be real, not theoretical.**
8. **A partial result may survive, but it must remain unpromoted until accepted.**

---

## 5. V1 User and Role Model

### 5.1 Human user
- one operator
- one approval authority
- one product owner in practice: the operator

### 5.2 System roles in V1

| Role | V1 responsibility | Cannot do |
|---|---|---|
| Orchestrator | intake, classification, light clarification, readiness detection, routing | no file execution, no canonical updates, no direct system mutation |
| PM | refinement, request brief, milestone/task shaping, acceptance criteria, canonical-state updates | cannot bypass governance gates |
| Architect/Dev | artifact-aware implementation and diagnosis | cannot self-promote |
| QA | review against PM criteria, sensor validation, promotion blocking | cannot silently change scope |
| Admin pipeline variant | same roles with access to AIO core scope | still cannot bypass stage gates |

### 5.3 Role boundary rule

The Admin pipeline changes the factory.  
The Standard pipeline changes what the factory produces.

That boundary is a V1 product requirement, not a future enhancement.

---

## 6. V1 Core User Flows

### 6.1 Standard project flow

```text
Operator request
-> Orchestrator clarifies and classifies
-> PM refines into brief / milestone / task / bug package
-> visible board item created
-> operator reviews if needed
-> execution packet generated
-> Architect/Dev executes
-> QA validates
-> approval queue updated
-> operator approves/rejects
-> PM updates canonical state
```

### 6.2 Admin change flow

```text
Operator admin request
-> Orchestrator classifies as admin path
-> PM refines against AIO core scope
-> protected board item created under AIOffice project
-> execution packet generated within admin authority boundary
-> Architect/Dev executes on protected scope
-> QA validates
-> operator explicitly approves/rejects
-> PM updates canonical state
```

### 6.3 Pause/resume flow

```text
task paused / threshold hit / manual stop / route interruption
-> task baton created
-> partial output preserved as unpromoted
-> current state records last completed step and cost spent
-> later resume loads baton and required artifacts only
```

### 6.4 Rollback flow

```text
approved milestone/version selected
-> git restore target chosen
-> rollback performed to approved baseline
-> restored state marked visible to operator
-> future work branches forward from restored version
```

---

## 7. V1 Functional Requirements

### FR-1 Unified control room
The system must provide one unified workspace containing chat/intake, kanban board, approvals queue, cost dashboard, and settings/admin.

### FR-2 Request refinement loop
The system must allow the orchestrator to clarify and classify requests, then hand them to PM for formal structuring.

### FR-3 PM-owned structuring
The PM must be able to produce, at minimum as applicable:
- Request Brief
- Milestone Draft
- Task Packet
- Change Proposal
- Bug Report Package

### FR-4 Protected pipeline routing
The system must distinguish Admin pipeline vs Standard pipeline before execution authority is granted.

### FR-5 Visible work objects
The system must represent projects, milestones, tasks, and bug tasks on visible surfaces.

### FR-6 Bounded execution packet
The system must generate execution packets with scope, route, constraints, acceptance criteria, and cost threshold.

### FR-7 Mandatory review and QA
The system must require mandatory review-agent pass and QA validation before promotion.

### FR-8 Retry limit
The Architect/Dev <-> QA remediation loop must stop after 4 retries and return current status to the operator.

### FR-9 Task-level cost stop
The system must stop or pause a task when its cost threshold is exceeded.

### FR-10 Human hard stop
The operator must be able to forcibly stop a running route.

### FR-11 Canonical-state control
Only PM may update canonical product/project current state.

### FR-12 Snapshot and resume
The system must preserve run snapshots and task batons to support resume without transcript dependency.

### FR-13 Git-backed rollback
The system must support rollback to a previously approved and tested milestone/version, with new forward work branching from there.

### FR-14 Triggerable board flow
The kanban surface must support execution triggering from work-item state change.

---

## 8. V1 Non-Functional Requirements

### NFR-1 Authority safety
No route may execute outside its allowed pipeline scope.

### NFR-2 Inspectability
The operator must be able to inspect why a task is where it is, what artifacts changed, what validation ran, and what remains blocked.

### NFR-3 Durability
Critical state must survive normal session loss.

### NFR-4 Cost visibility
Task-level cost must be visible and stop-capable.

### NFR-5 Recoverability
Partial outputs may persist, but they must remain visibly unpromoted until accepted.

### NFR-6 Modularity
The structure should support later extension into broader lanes without requiring a V1 rewrite.

---

## 9. V1 Screen Scope

### 9.1 Mandatory V1 screens

| Screen | V1 status | Purpose |
|---|---|---|
| Chat / Intake | Required | request entry, clarification, route preparation |
| Kanban Board | Required | visible project/milestone/task state and execution trigger |
| Approvals Queue | Required | operator review and promotion/rejection decisions |
| Cost Dashboard | Required | per-task spend visibility and stop control |
| Settings / Admin Panel | Required | admin path access, protected scope controls, system settings |

### 9.2 Unified workspace rule
V1 uses **one unified workspace**, not separate lane-specific apps.

### 9.3 Harness visibility rule
For MVP, internal harness concepts should remain visible rather than hidden behind simplified UI.

---

## 10. Object Model For V1

### 10.1 Canonical planning hierarchy

```text
AIOffice
  -> Project
    -> Milestone
      -> Task
```

### 10.2 Special self-build project

```text
AIOffice
  -> AIOffice
    -> Milestone
      -> Task
```

### 10.3 Task subtypes
- standard task
- bug task
- admin task

### 10.4 Minimum metadata expected on each task
- task ID
- project ID
- milestone ID
- task subtype
- pipeline type
- owner role
- acceptance criteria
- cost threshold
- current status
- retry count
- artifact references
- dependency references
- evidence references

---

## 11. Workflow State Model

### 11.1 Minimum task states

| State | Meaning |
|---|---|
| Intake | request exists but is not yet structured |
| Refinement | orchestrator/PM clarification in progress |
| Ready | structured and eligible for execution |
| In Progress | execution running |
| QA | validation in progress |
| Approval | waiting for operator decision |
| Accepted | promoted and current-state eligible |
| Rejected | explicitly rejected by operator |
| Blocked | cannot proceed without intervention |
| Paused | intentionally stopped but resumable |
| Rolled Back | superseded by approved restore action |

### 11.2 Trigger rule
Dragging a card to **In Progress** should be the intended V1 operator trigger for execution, subject to route eligibility and protections.

---

## 12. Acceptance Package Requirements

Every execution return bundle must include:
- outputs/artifacts produced
- changed files or impacted artifacts
- tests and validations run
- results summary
- assumptions made
- blockers encountered
- risks still open
- receipts/evidence
- next recommended action

If these are missing, the bundle is incomplete.

---

## 13. Sensor Requirements For V1

### 13.1 Mandatory software sensors
- lint
- unit tests
- security checks when applicable
- dependency validation

### 13.2 Review flow rule
Failed validation should auto-loop back to Architect/Dev.

### 13.3 Retry ceiling
After 4 failed remediation attempts, the route must stop and return current status to the operator.

---

## 14. Memory, Baton, and Resume Requirements

### 14.1 Required memory scopes
- global AIOffice memory
- project memory
- run/session baton

### 14.2 Do not auto-load by default
- full old transcripts
- obsolete milestone plans

### 14.3 Minimum baton fields
- current state
- last completed step
- cost spent so far

### 14.4 Baton timing
A baton is required at **task level** so the system can stop cleanly when cost thresholds or manual stops occur.

---

## 15. Versioning and Rollback Requirements

### 15.1 Source of rollback truth
Git is the primary rollback truth.

### 15.2 Snapshot requirements
- run snapshot created per execution run
- git branch/worktree created at each milestone approval

### 15.3 Failure behavior
- keep partial output
- mark it unpromoted
- ask human for decision
- rollback only if sensors fail or operator chooses rollback

---

## 16. Execution Posture For V1

### 16.1 Allowed route families
- synchronous route
- background route

### 16.2 Default execution posture
V1 uses **Surge** posture by default.

### 16.3 Deferred posture work
Balanced and Economy modes are future enhancements and not launch blockers.

### 16.4 Budget control level
Budget control is required **per task**.

---

## 17. MVP Milestone Plan

This milestone plan is for building **AIOffice V1 itself**.

### 17.1 Milestone weighting model

| Milestone | Weight |
|---|---:|
| M1 Protected Foundations and Domain Model | 18% |
| M2 Unified Control Room Surface | 22% |
| M3 Orchestrator to PM Planning Loop | 20% |
| M4 Governed Execution, QA, and Approvals | 24% |
| M5 Recovery, Rollback, and Resume | 16% |
| **Total** | **100%** |

### 17.2 M1 Protected Foundations and Domain Model
**Objective:** lock the factory boundary before deeper product build.

| ID | Task | Weight | Done when |
|---|---|---:|---|
| M1-T1 | Define protected AIO core boundary vs standard sub-project boundary | 4 | AIO core scope list is accepted and enforced in model/rules |
| M1-T2 | Define canonical object schema for Project, Milestone, Task, Bug | 4 | object fields and relations are accepted |
| M1-T3 | Define pipeline type model: Admin vs Standard | 3 | routing model and authority flags are accepted |
| M1-T4 | Define minimum task metadata and lifecycle states | 3 | status model and required fields are accepted |
| M1-T5 | Define canonical-state ownership rule and PM-only update path | 2 | PM-only mutation rule is accepted |
| M1-T6 | Define protected folder/artifact boundary assumptions for V1 | 2 | V1 scope rules are accepted |

**Milestone acceptance gate:** no downstream milestone starts until AIO core protection logic is unambiguous.

### 17.3 M2 Unified Control Room Surface
**Objective:** deliver the visible operator workspace.

| ID | Task | Weight | Done when |
|---|---|---:|---|
| M2-T1 | Build workspace shell and navigation | 4 | operator can access all mandatory V1 screens |
| M2-T2 | Build chat/intake surface | 4 | operator can submit and track requests |
| M2-T3 | Build kanban board surface | 5 | work items are visible and stateful |
| M2-T4 | Build approvals queue | 4 | operator can approve/reject from a dedicated surface |
| M2-T5 | Build cost dashboard | 4 | task-level spend is visible |
| M2-T6 | Build settings/admin panel | 3 | admin path entry and protected settings are visible |
| M2-T7 | Enable drag-to-In-Progress trigger guardrails | 2 | board trigger is wired with eligibility checks |

**Milestone acceptance gate:** the operator can see and navigate the whole V1 control room.

### 17.4 M3 Orchestrator to PM Planning Loop
**Objective:** turn chat requests into governed planning objects.

| ID | Task | Weight | Done when |
|---|---|---:|---|
| M3-T1 | Implement orchestrator request classification | 4 | request types route correctly |
| M3-T2 | Implement light clarification and missing-field prompts | 3 | orchestrator can close obvious gaps |
| M3-T3 | Implement readiness detection and PM handoff criteria | 4 | exit criteria from orchestrator are explicit |
| M3-T4 | Implement PM request brief creation | 3 | structured brief is generated and reviewable |
| M3-T5 | Implement PM milestone/task/bug creation flow | 4 | work items can be created from refined requests |
| M3-T6 | Implement PM-only canonical-state update path | 2 | accepted outcomes can update state only through PM |

**Milestone acceptance gate:** a request can enter chat and become structured board work without direct execution leakage from the orchestrator.

### 17.5 M4 Governed Execution, QA, and Approvals
**Objective:** make the core production loop real.

| ID | Task | Weight | Done when |
|---|---|---:|---|
| M4-T1 | Define and implement execution packet structure | 4 | packets contain scope, criteria, route, and thresholds |
| M4-T2 | Support low-risk auto-generated packets queued for review | 3 | eligible packets appear without bypassing approval model |
| M4-T3 | Implement Architect/Dev execution route | 4 | tasks can run through bounded execution |
| M4-T4 | Implement mandatory review-agent pass | 3 | every bundle receives review pass before promotion |
| M4-T5 | Implement QA gate and sensor execution | 4 | required validations run and are recorded |
| M4-T6 | Implement Architect/Dev <-> QA retry loop with 4-attempt ceiling | 3 | failed work loops and then stops correctly |
| M4-T7 | Implement approvals queue decision flow | 3 | operator can accept/reject based on evidence |

**Milestone acceptance gate:** the full V1 production slice is live from request to approval.

### 17.6 M5 Recovery, Rollback, and Resume
**Objective:** make the system durable and reversible.

| ID | Task | Weight | Done when |
|---|---|---:|---|
| M5-T1 | Implement run snapshot capture | 3 | each run leaves a resumable snapshot |
| M5-T2 | Implement task baton generation at pause/stop/threshold events | 3 | baton is created automatically and is reloadable |
| M5-T3 | Implement per-task cost threshold stop | 2 | routes stop/pause when threshold is exceeded |
| M5-T4 | Implement operator brute-force stop | 2 | operator can stop a running route |
| M5-T5 | Implement milestone approval branch/worktree creation | 3 | approved milestones create rollback anchors |
| M5-T6 | Implement approved-version rollback flow | 3 | operator can restore and branch forward |

**Milestone acceptance gate:** the operator can safely stop, resume, or restore without depending on memory alone.

---

## 18. KPI Model For Percentage Complete

### 18.1 Why two KPIs are needed
A single percentage can become misleading. V1 therefore uses two complementary KPIs:

1. **Delivery Progress %**  
   Shows weighted progress through the implementation pipeline.

2. **True Completion %**  
   Shows only work that is actually accepted.

### 18.2 Task stage factors for Delivery Progress %

| Task state | Factor |
|---|---:|
| Not started | 0.00 |
| Refinement accepted / Ready | 0.20 |
| In Progress | 0.50 |
| QA | 0.75 |
| Approval | 0.90 |
| Accepted | 1.00 |
| Rejected / Blocked / Paused | keep last earned factor, unless reset by PM |
| Rolled Back | 0.00 for the rolled-back task version |

### 18.3 Formula for Delivery Progress %

```text
Delivery Progress % =
(sum of (task weight x stage factor) across all tasks)
/ (sum of all task weights)
* 100
```

### 18.4 Formula for True Completion %

```text
True Completion % =
(sum of weights for Accepted tasks only)
/ (sum of all task weights)
* 100
```

### 18.5 Milestone completion rule
A milestone is considered **complete** only when:
- all its required tasks are Accepted
- its acceptance gate is satisfied
- its milestone branch/worktree anchor exists where required

### 18.6 Recommended reporting pattern
Show all three on the board/dashboard:
- Delivery Progress %
- True Completion %
- milestone count completed / total

This avoids false confidence.

---

## 19. Current Recommended Next Milestone

### 19.1 Recommended next milestone
The recommended next milestone is:

## **M1 Protected Foundations and Domain Model**

### 19.2 Why this must come first
Your own direction makes this the right first move:
- the Admin path must be closed first
- AIO core vs sub-project boundary is the highest-risk area
- the PM-only canonical update rule depends on this separation
- execution and UI become dangerous if protection rules are vague

### 19.3 Practical consequence
Do **not** treat control-room polish or execution richness as the first build priority if the factory boundary is still ambiguous.

---

## 20. Launch Exit Criteria For V1

AIOffice V1 is launchable for personal use only when all of the following are true:
- the unified workspace exists and works end to end
- Admin and Standard pipelines are visibly separated and enforced
- a request can become structured board work through orchestrator + PM
- a task can execute through Architect/Dev with bounded packet discipline
- QA and review agent are mandatory and can block promotion
- the operator can approve/reject from a dedicated queue
- PM alone can update canonical state
- task-level cost stop works
- run snapshot and baton/resume work
- rollback to approved milestone/version works through git-backed truth

If any of these are missing, V1 is still incomplete.

---

## 21. Risks To Watch During V1 Delivery

### 21.1 Highest risk
Accidental leakage of Standard pipeline authority into protected AIO core scope.

### 21.2 Additional V1 risks
- over-building UI before protection model is real
- letting orchestrator become a hidden executor
- weak PM handoff criteria causing noisy refinement loops
- incomplete artifact traceability undermining bug diagnosis
- cost controls that exist in theory but not in operator workflow
- rollback logic that is documented but not easily usable

---

## 22. Deferred Follow-On Documents

After this PRD, the most useful next document is:

### **Operating Model / Governance Spec**
That document should cover:
- exact handover rules and exit/entry criteria by role
- stage gates and allowed transitions
- authority matrix
- admin vs standard pipeline technical boundaries
- packet/bundle structure in more technical detail
- current-state mutation rules
- rollback and snapshot operating flow
- diagrams for easier user ingestion

---

## 23. Closing Definition

This PRD defines a V1 that is intentionally narrow but serious.

It is not a general AI software factory yet.
It is a protected first operating version of AIOffice that must prove five things:
- structured intake
- visible control room
- governed execution
- durable continuity
- real rollback safety

That is the bar for V1.
