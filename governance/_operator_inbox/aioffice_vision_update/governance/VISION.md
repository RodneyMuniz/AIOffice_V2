# AIOffice Vision

**Document status:** Proposed v2 replacement for `governance/VISION.md`
**Document type:** Constitutional product truth
**Prepared after:** R13 failed/partial posture at `d3123256e83505098ee13829648f0f6e531f96ef`
**Important:** This document is a vision/governance update only. It does not close R13, open a successor, prove implementation, or widen current repo claims.

---

## 1. Constitutional Thesis

AIOffice exists to make governed software production possible around untrusted models.

The product is not a model and not a chat wrapper. The product is a control harness that keeps user intent, board-visible work, role authority, bounded execution, review, audit, release safety, and durable repo truth separate.

The strengthened product thesis is:

> **AIOffice is a board-driven, role-separated, memory-managed AI software-production operating system where repo truth remains canonical, the board is the live process surface, and every agent acts only inside explicit identity, memory, authority, and output boundaries.**

The system may use GPT, OpenAI API, Codex, GitHub Actions, future Agent Builder surfaces, Symphony-inspired runners, or external boards. None of those tools becomes the constitutional authority. They are execution and visibility surfaces under AIOffice control.

---

## 2. Doctrine

AIOffice follows these non-negotiable principles:

1. **Repo truth outranks narration.** Committed artifacts, machine evidence, Git identity, and validated state outrank chat summaries or generated Markdown.
2. **The board is the live process surface.** Important work, questions, blockers, decisions, and follow-ups must become board-visible cards after operator intake.
3. **Explicit approval outranks implied permission.** Meaningful promotion, cleanup, release, architecture selection, and closure require explicit user authority.
4. **Evidence outranks confidence.** A report may explain; it does not prove unless it links to committed evidence.
5. **Role authority outranks convenience.** Faster execution is invalid if it lets one role bypass another role’s gate.
6. **No fake multi-agent narration.** A single assistant may not pretend to be multiple independent agents unless marked as simulation; simulation is never execution proof.
7. **Memory is scoped, not magical.** Agents load role-appropriate memory refs, card refs, and task packets. They do not broadly scan the repo unless the packet authorizes it.
8. **Resolved is not Closed.** Work may be technically resolved, but a card closes only after user approval.
9. **Current-proof honesty outranks product ambition.** Target-state capabilities remain non-claims until committed evidence proves them.
10. **Stop and recovery are first-class controls.** Daemons, runners, agents, and long tasks must support safe stop, baton/re-entry, and audit-visible recovery.

---

## 3. Current Proof Boundary and R13 Posture

AIOffice has accumulated strong governance, artifact, and evidence discipline. However, the current repo posture after R13 is deliberately limited:

- R13 reached `R13-018` as task execution.
- R13 is not closed.
- R13 ended failed/partial.
- R13-017 recorded fail-closed closeout ineligibility.
- R13-018 produced a final failed/partial report and conditional successor recommendation only.
- No successor milestone is open.
- No R13 final-head support packet or R13 closeout package exists.
- No merge to `main` is claimed.

R13 proved one bounded representative meaningful QA loop, not full product QA, production QA, production runtime, productized UI, broad autonomy, solved Codex reliability, or solved Codex compaction.

The constitutional interpretation is blunt:

> **AIOffice is good at proving bounded artifacts. It is not yet good enough at acting as a product operating surface.**

The next vision correction is therefore not more proof theater. It is a clearer product operating model: board-first, role-separated, memory-scoped, and measurable by domain maturity.

---

## 4. Product Identity

AIOffice should be understood as four connected things:

1. **A governed AI control harness**
   A system that contains untrusted model output inside authority, evidence, and review boundaries.

2. **A board-driven software production operating system**
   A workflow surface where user intent becomes cards, cards become packets, packets route to agents, and card state reflects real process state.

3. **A role-separated agent workforce**
   A set of bounded agents such as PM, Architect, Developer, QA, Auditor, Knowledge Curator, and Release/Closeout Agent. Each has explicit identity, memory scope, authority, tools, and output artifacts.

4. **A durable knowledge and evidence system**
   A repo-backed memory and artifact registry that reduces context burn, supports re-entry, and keeps decisions grounded in durable truth.

AIOffice is not a single assistant writing persuasive updates. It is a governed production system that forces work through visible, auditable roles.

---

## 5. Double Diamond Product Shape

AIOffice preserves a Double Diamond inspired software-production value stream:

```text
Discover -> Define -> Develop -> Deliver -> Feedback / Improve
```

This flow is the top-level product value stream. It sits above the operating architecture, agent model, governance layer, knowledge base, security model, release strategy, and continuous improvement loop.

### 5.1 Discover

Purpose:

- capture raw user intent;
- ask clarifying questions;
- identify product, architecture, repo, knowledge, or release questions;
- convert significant questions into board-visible cards;
- route unclear work to PM, Architect, Auditor, or Knowledge Curator instead of letting the Operator invent technical truth.

### 5.2 Define

Purpose:

- convert cards into structured work;
- establish ownership, acceptance criteria, QA criteria, evidence requirements, and non-claims;
- define task packets and re-entry packets;
- split oversized work into follow-up cards;
- prepare agents with scoped memory rather than broad repo scans.

### 5.3 Develop

Purpose:

- execute scoped work through the correct role;
- allow Developer to implement only within a packet;
- allow QA to test only against acceptance criteria;
- allow Auditor to judge evidence sufficiency;
- allow runners/daemons only below AIO authority and with stop/recovery controls.

### 5.4 Deliver

Purpose:

- package evidence, release posture, branch safety, promotion readiness, and unresolved risks;
- mark work Resolved when evidence is sufficient for user review;
- close work only after explicit user approval;
- reject or return work to PM when the user does not accept it.

### 5.5 Feedback / Improve

Purpose:

- convert feedback into future board cards;
- classify knowledge and artifact changes;
- propose cleanup/deprecation through Knowledge Curator and Auditor checks;
- feed lessons into the artifact registry, role memory, KPI framework, and reporting standard.

---

## 6. Authority Model

Authority order is:

1. **User / Rodney** — final product, architecture, closure, release, cleanup, and promotion authority.
2. **Control Kernel / Governance Rules** — enforce role boundaries, state gates, evidence requirements, and non-claims.
3. **Board/Card State** — live process surface for routing, state, blockers, decisions, and handoffs.
4. **Role Agents** — PM, Architect, Developer, QA, Auditor, Knowledge Curator, Release/Closeout Agent.
5. **Runners / Tools / Models** — Codex, OpenAI API, GitHub Actions, Symphony-inspired services, external board adapters.

No runner, model, external board, or generated report may outrank the user, control kernel, card state, or committed repo evidence.

---

## 7. Board as Live Process Surface

Repo truth remains canonical. The board is the live process surface.

This means:

- the repo stores canonical artifacts, evidence, contracts, and state;
- the board exposes what is active, blocked, ready, resolved, or waiting for approval;
- cards are governed work packets, not sticky notes;
- important user questions become cards after Operator intake;
- PM owns card state and routing;
- Developer, QA, Architect, Auditor, and Knowledge Curator do not close cards;
- Closed requires user approval;
- external tools such as GitHub Projects or Linear may mirror cards, but they do not silently become canonical truth.

---

## 8. Role-Separated Agent Operating Model

AIOffice must support direct access to specific agents while preserving authority boundaries.

Core roles:

- User / Rodney
- Operator
- Orchestrator
- Project Manager
- Architect
- Developer
- QA/Test Agent
- Evidence Auditor
- Knowledge Curator
- Release/Closeout Agent

Each agent requires:

- explicit identity packet;
- role profile;
- card/task packet reference;
- loaded memory refs;
- allowed and forbidden actions;
- allowed and forbidden tools;
- board-state mutation rights or explicit lack of them;
- required output artifact;
- handoff target;
- audit log entry.

The same underlying model provider may power multiple agents, but separate agents must be separate bounded executions. A single response narrating multiple roles is analysis, not proof of multi-agent execution.

---

## 9. Knowledge and Memory Model

AIOffice must reduce context burn by replacing repeated full-repo scans with layered knowledge and scoped memory.

Target knowledge layers:

1. **L1: High-level process diagrams** — human-readable overview of the Double Diamond, board flow, role flow, and release flow.
2. **L2: Architecture environment map** — harness, contracts, validators, runners, board, integrations, security, and release surfaces.
3. **L3: Artifact/capability relationship map** — how contracts, tools, tests, state files, evidence packages, and reports connect.
4. **AI-friendly machine map** — artifact registry, capability map, decision index, role memory refs, and task packet links.

Artifact classes:

- Core
- Supporting
- Historical
- Deprecated
- Candidate
- Cleanup candidate
- Unknown

Cleanup is governed. Knowledge Curator may propose. Auditor verifies. PM logs a card. User approves final cleanup/deprecation.

---

## 10. Execution and Orchestration Direction

AIOffice is Codex-first and OpenAI-centered for this stage, but Codex chat continuity is not the control plane.

Target direction:

- Codex remains a valuable bounded executor.
- OpenAI API or Agent Builder-style surfaces may provide controlled agent invocation and operator-facing workflows.
- GitHub Actions remains a strong external replay/evidence substrate.
- Symphony is useful as philosophy and possible downstream runner subsystem: isolated workspaces, tracker polling, repo-owned workflow policy, bounded concurrency, retries, and observability.
- Symphony must not become parent authority. Its runner must sit below AIO card/task-packet authority.
- Linear may be a future adapter/lab surface, especially for Symphony compatibility, but it is not immediate canonical truth.
- GitHub Issues/Projects is the first practical external board mirror because it is closest to repo, branches, PRs, and Actions.

---

## 11. Strategic Sequence

AIOffice should not open further implementation planning until this target model is accepted or corrected at the product-vision level.

The strategic sequence is:

1. Stabilize the constitutional product model.
2. Define board/card/memory/role authority as target truth.
3. Define KPI and report standards so progress is legible by domain.
4. Define agent identity and RACI enforcement before claiming multi-agent behavior.
5. Define knowledge/context compression controls before more long Codex cycles.
6. Define release/environment safety before promotion productization.
7. Only then plan any future implementation milestone.

This sequence is product vision clarification only. It is not a successor milestone plan.

---

## 12. Current Non-Claims

This vision update does not claim:

- R13 is closed;
- a successor milestone is open;
- production runtime exists;
- production QA exists;
- full product QA coverage exists;
- a productized UI exists;
- the board-driven operating model is implemented;
- direct agent access is implemented;
- true multi-agent execution is implemented;
- Codex reliability is solved;
- Codex context compaction is solved;
- Symphony is integrated;
- Linear or GitHub Projects is canonical truth;
- cleanup/deprecation is authorized without user approval.

---

## 13. Closing Definition

AIOffice’s first duty is to remain governed, visible, evidence-backed, and honest. Its next product duty is to stop being a collection of proof artifacts and become a board-driven operating surface where agents, memory, work, evidence, and user authority are cleanly separated.

The harness is still the product. The board is the process surface. The repo is the truth substrate. The user remains final authority.
