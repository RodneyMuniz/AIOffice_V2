# AIOffice Product Constitution / Vision

**Document status:** Draft v1  
**Document type:** Constitutional product baseline  
**Intended relationship:** This document defines the enduring product truth for AIOffice. It is the parent reference for the future **V1 PRD / MVP Spec** and **Operating Model / Governance Spec**.

---

## 1. Purpose

This document defines what AIOffice is, why it exists, what it must protect, and how the product should be understood before detailed implementation planning.

It is not the V1 milestone plan, not the technical operating manual, and not the detailed governance rulebook.

Its role is to protect the product identity while the system is still being built, especially because AIOffice has a special difficulty: the product is expected to eventually help build and improve itself.

---

## 2. Core Definition

**Working name:** AIOffice

**Constitutional definition:**  
AIOffice is a personal software production operating system and governed AI harness that allows one operator to turn natural-language intent into structured software work, bounded execution, traceable artifacts, reviewable evidence, and durable product evolution.

**North-star promise:**  
The operator can write in natural language while the system interprets, refines, structures, decomposes, governs, tracks, and progressively executes work through specialized roles without losing authority, traceability, cost visibility, rollback safety, or product coherence.

**Strategic reality:**  
AIOffice must first become capable of safely building and improving **itself**. Only after that maturity is real should the product expand toward building other products at scale.

---

## 3. Product Identity

AIOffice should be understood simultaneously as:

1. **A software production operating system**  
   A control layer for turning requests into governed work.

2. **A personal AI development studio**  
   A single-operator environment where ideas, plans, code changes, evidence, and approvals live together.

3. **A governed multi-role app builder**  
   A system that separates orchestration, planning, implementation, validation, and approval instead of letting one model narrate fake progress.

The language may vary, but the product intent does not.

---

## 4. Strategic Sequence

AIOffice is not trying to do everything at once.

### 4.1 Current strategic order

1. **Protect and define AIOffice itself**
2. **Make AIOffice capable of governed self-improvement**
3. **Make AIOffice capable of building and evolving sub-projects**
4. **Only later expand toward broader product-production ambition**

### 4.2 Platform constraint

For this stage, AIOffice is intentionally built around:
- **GPT / OpenAI API / Codex**
- no hidden multi-provider AI backplane
- no secondary AI engine behind the scenes

External integrations may exist later for databases, knowledge stores, or supporting systems, but the core AI execution model is OpenAI/Codex-centered.

---

## 5. Product Thesis

Raw LLM interaction is not enough.

Without an outer system, the model tends to:
- narrate instead of delegate
- appear coherent while hiding uncertainty
- lose context discipline over time
- blur planning, execution, and approval
- act beyond intended authority if not constrained

AIOffice exists to solve that.

**Constitutional thesis:**  
The model is useful only when layered inside a product that enforces delegation, role separation, state visibility, artifact traceability, validation, and human authority.

In simple terms:

```text
AIOffice = LLM capability + harness discipline + visible workflow + protected authority
```

---

## 6. Primary Problem Statement

The first version of AIOffice must solve three failures better than anything else:

### 6.1 No clear control room
The operator must be able to see what exists, what is proposed, what is running, what is blocked, and what is ready for approval.

### 6.2 Weak artifact traceability
The system must preserve enough structure and artifact mapping that future debugging, root-cause analysis, and enhancement planning can be grounded in reality, not theory.

### 6.3 Narration instead of real delegation
The product must force work through specialized bounded roles and stages instead of allowing a single assistant to produce impressive but unreliable stories of progress.

### 6.4 Primary risk to prevent
The most unacceptable failure is this:  
**agents or subagents acting outside authority boundaries.**

That risk outranks convenience.

---

## 7. Product Posture

### 7.1 User model
AIOffice is designed first for **one operator**: the owner-builder.

### 7.2 Ownership model
AIOffice is for personal use first. It may later be shown to trusted people, but it is not currently a team collaboration product or public SaaS target.

### 7.3 Domain priority
AIOffice is currently **software-first**.

The constitutional product focus is:
- software creation
- software enhancement
- bug-resolution mapping
- artifact-based diagnosis
- governed delivery and rollback

Other creative and multi-domain ambitions remain future extensions, not present commitments.

---

## 8. The Double Diamond Product Shape

AIOffice should support a full software-production cycle aligned to a practical double-diamond model.

### 8.1 Discover
Purpose:
- brainstorm and compare ideas
- refine prompts and requirements
- capture user intent
- explore PM, architecture, and design perspectives
- research product direction

### 8.2 Define
Purpose:
- identify root causes
- create milestones and tasks
- define dependencies and artifacts
- prioritize work
- clarify acceptance criteria and constraints

### 8.3 Develop
Purpose:
- delegate prioritized tasks to bounded specialist roles
- implement changes
- run QA and required sensors
- maintain backup and rollback discipline

### 8.4 Deliver
Purpose:
- present outcomes to the operator
- gather feedback
- capture bugs and enhancement requests
- run milestone retrospectives
- continue controlled evolution

This full cycle matters because AIOffice is not just a coding assistant. It is meant to support end-to-end software production.

---

## 9. Factory Model And Protected Separation

AIOffice should be understood as a **factory**.

- The factory itself is **AIOffice core**.
- The things the factory builds are **sub-projects**.

Changing the factory is fundamentally different from changing one of its products.

### 9.1 Admin change
An admin change modifies the factory itself. Examples:
- AIOffice core code
- policies and governance rules
- root folder and structural conventions
- harness processes
- role definitions
- model usage patterns
- base artifacts and protected machinery

These are high-risk changes.

### 9.2 Standard product change
A standard change modifies a product produced by the factory. Examples:
- a website
- an app
- a wiki
- an Excel-based output
- a custom sub-project unrelated to AIO core

These changes should stay contained to sub-project scope.

### 9.3 Constitutional rule
Sub-projects may consume AIOffice rules and structures, but they may **not** modify AIOffice core conventions.

Only the admin path may change the factory itself.

---

## 10. Structural Hierarchy

The base planning hierarchy is:

```text
AIOffice → Project → Milestone → Task
```

Special case:

```text
AIOffice → AIOffice → Milestone → Task
```

That special case represents self-improvement work on the AIOffice product itself.

### 10.1 Bug model
A bug is a **task subtype**, not a separate top-level planning object.

A bug belongs to one project, even if its investigation references specific tasks, milestones, or product models.

---

## 11. Two Pipelines, One Operating Discipline

AIOffice uses two pipelines:

1. **Admin pipeline**
2. **Standard pipeline**

They share the same basic process model, but not the same access scope.

### 11.1 Admin pipeline
The admin pipeline is used for AIOffice self-change.

It uses the same major roles and stage discipline as normal work, but it is allowed to read and modify protected AIO core artifacts, policies, and foundational machinery.

### 11.2 Standard pipeline
The standard pipeline is used for sub-project work.

It can consume the AIOffice process and structures, but it cannot mutate protected AIO core rules or root-level machinery.

### 11.3 Core rule
The process stays consistent across both pipelines.  
The **authority scope** changes.

---

## 12. Role Model

### 12.1 Operator
The operator is the human authority.

The operator:
- initiates requests
- reviews proposals and outcomes
- approves or rejects promotion
- can force-stop work
- remains the ultimate authority for meaningful decisions

### 12.2 Orchestrator
The orchestrator is the user-facing intake and routing layer.

The orchestrator may:
- clarify lightly
- improve prompts
- collect missing fields
- perform readiness detection
- route to the correct downstream role

The orchestrator may **not**:
- execute system changes
- run tools inside the product
- read or manipulate project files directly
- act as a hidden implementer

### 12.3 PM
The PM is the main refinement and planning authority.

The PM is responsible for:
- turning requests into structured work
- acting as PO-level requirement owner
- producing briefs, milestone drafts, task packets, change proposals, and bug packages
- defining acceptance criteria
- deciding whether the request is ready for implementation
- updating canonical state

The PM is the only role allowed to change canonical states.

### 12.4 Architect/Dev
For the current stage, architect and developer are one combined full-stack role.

This role is responsible for:
- understanding the process and relevant artifacts
- implementing the requested work
- maintaining artifact-aware reasoning
- supporting root-cause analysis
- returning bounded outputs and evidence

### 12.5 QA
QA is a mandatory validation role.

QA:
- validates outputs against criteria defined by the PM
- reviews architect outputs before promotion
- can block promotion directly
- returns failure back to Architect/Dev in a bounded loop

### 12.6 Retry rule
QA may loop implementation back to Architect/Dev up to **4 retries**.  
After that, the system must return current status to the operator for decision.

---

## 13. Core User Slice

The essential production loop is:

```text
operator enters a request
→ system converts it into a structured task
→ task appears in a visible surface
→ bounded execution can be triggered
→ artifact comes back
→ validation comes back
→ operator can approve/reject
→ current-state is updated
```

That is the minimum meaningful slice of AIOffice.

Requests may include:
- creating or editing a project
- creating or editing milestones or tasks
- adding bugs to an existing project
- changing AIOffice itself through admin scope
- asking questions about current system or project state

---

## 14. Handover Principle

AIOffice must not allow arbitrary invisible transitions between roles.

### 14.1 Orchestrator exit rule
The orchestrator should hand work forward only after it has done enough clarification to form a meaningful request frame.

### 14.2 PM entry rule
The PM should accept work only when there is enough structure to either:
- transform it into formal work artifacts, or
- reject it with explicit missing information

### 14.3 Dynamic but ruled
These criteria may be somewhat dynamic by request type, but they must still be rule-based.

The exact entrance and exit criteria belong in the future **Operating Model / Governance Spec**.

---

## 15. Authority Model

AIOffice is built on two main enforcement levers:

1. **Role permissions**
2. **Stage gates**

These are the primary constitutional controls.

### 15.1 Human approval required
The following always require explicit human approval:
- applying code changes
- merging or publishing
- changing AIOffice core
- changing governance rules
- increasing autonomy scope in meaningful ways
- spending beyond intended thresholds

### 15.2 Autonomous activity allowed
The following may be automated within bounds:
- drafting specs
- generating tasks
- running lint, tests, security checks, and dependency checks
- writing low-risk code
- updating docs
- opening review bundles

### 15.3 Control rule
Higher speed or autonomy must never silently weaken hard authority boundaries.

---

## 16. Execution And Recovery Principles

### 16.1 Maximum autonomy for current stage
The largest intended autonomous scope for this stage is **one milestone**.

### 16.2 Mixed execution model
Execution may happen:
- synchronously, when appropriate
- asynchronously, when appropriate

### 16.3 Sensor dependency
Execution should be blocked if required validation sensors are not declared.

### 16.4 Stop authority
The operator must always be able to brute-force a stop if a dead loop, expensive routine, or bad execution path is detected.

### 16.5 Recovery posture
If a run fails mid-way:
- partial output may remain
- it must be marked **unpromoted**
- the human must be informed
- rollback should occur when sensors fail or when the operator decides it is necessary

### 16.6 Rollback truth
Git is the primary source of rollback truth.

- a **milestone-approved** state should create its own branch/worktree boundary
- each task execution should create a **run snapshot**

---

## 17. Memory And Continuity Principles

AIOffice should not depend on raw transcript memory.

### 17.1 Memory scopes
AIOffice should maintain:
- global AIOffice memory
- project memory
- run/session baton memory

### 17.2 What should not be auto-loaded
The system should not auto-load:
- full old transcripts
- obsolete milestone plans

### 17.3 Task-level baton rule
A baton should be created at task level and must support cost-aware stopping.

The most critical baton contents are:
1. current state
2. last completed step
3. cost spent so far

---

## 18. Visible Workspace Principle

For the MVP stage, the UI should expose the harness concepts directly rather than hiding them.

The minimum operator-facing workspace should make these visible:
- chat / intake
- kanban board
- approvals queue
- cost dashboard
- settings / admin panel

The workspace should be unified rather than split into separate apps for each lane.

A high-value interaction target is this:  
**dragging a card to In Progress should be able to trigger governed execution.**

---

## 19. Success Definition For The Product Vision

AIOffice is succeeding against its current vision when the operator can:

1. create a project from chat and obtain structured milestones and tasks
2. run governed code changes with lint, tests, security/dependency checks where applicable, and evidence
3. pause and resume without context collapse
4. manage AIOffice itself and sub-projects through the same basic operating model
5. roll back to a previous approved and tested milestone/version and branch from there

---

## 20. Explicit Non-Goals For This Stage

The following are intentionally out of scope for the current stage:
- audio generation
- image generation
- knowledge graph implementation
- multi-milestone autonomy
- advanced execution tiers
- fancy design lane maturity
- generalized marketplace of specialist lanes
- hidden multi-provider AI orchestration

These may become future extensions, but they are not constitutional commitments for the current build sequence.

---

## 21. Document Relationships

This constitution should be followed by three downstream document types:

### 21.1 V1 PRD / MVP Spec
This will define:
- MVP scope
- measurable milestones and tasks
- completion criteria
- KPI model including percent complete

### 21.2 Operating Model / Governance Spec
This will define:
- stage logic
- handover rules
- role permissions
- technical control mechanics
- diagrams
- how the system actually works in practice

### 21.3 Supporting technical architecture materials
If needed, lower-level technical diagrams and mechanism references can be attached under the operating model family rather than bloating this constitution.

---

## 22. Open Items Explicitly Deferred

The following are important but deliberately deferred to later documents:
- exact canonical folder structure for sub-projects
- final list of mandatory project documents
- balanced and economy execution modes
- future provider and token strategy refinements
- detailed technical diagrams
- exact PM/orchestrator entrance and exit criteria
- exact board states and workflow transitions

---

## 23. Closing Definition

AIOffice is a protected software factory for one operator.

It exists so that natural-language intent can become structured work, bounded execution, validated artifacts, controlled promotion, and durable software evolution.

Its first duty is not to look intelligent.  
Its first duty is to remain governed, visible, rollback-safe, and real.

Only once that is true for AIOffice itself should it expand confidently into building other products.
