# AIOffice Product Operating Model

**Document status:** Proposed v1
**Document type:** Product operating model and process architecture
**Scope:** Vision/operating-model update only; no implementation or successor milestone is proposed.

---

## 1. Purpose

This document defines how AIOffice should operate as a product before further milestone planning. It translates the updated vision into a board-driven, role-separated, memory-managed operating model.

It defines:

- the Double Diamond product flow;
- how ideas become cards;
- how cards become task packets;
- how task packets move through roles;
- how evidence, QA, audit, user approval, release, and closeout work;
- how feedback becomes future backlog or knowledge updates;
- how Resolved differs from Closed.

This document is target operating design. It does not claim current implementation.

---

## 2. Top-Level Product Value Stream

```text
Discover -> Define -> Develop -> Deliver -> Feedback / Improve
```

The Double Diamond is the product-level value stream. It is not merely a design metaphor. It is the high-level structure that organizes board cards, agent responsibilities, evidence, and reporting.

| Stage | Product purpose | Primary roles | Typical outputs |
| --- | --- | --- | --- |
| Discover | Capture intent, questions, pain, and opportunities. | User, Operator, Orchestrator, PM, Architect, Knowledge Curator | Intake record, idea card, clarification card, architecture question, research card |
| Define | Convert intent into governed work. | PM, Architect, QA, Auditor, User | Board card, acceptance criteria, QA criteria, task packet, architecture decision, evidence requirements |
| Develop | Execute scoped work. | Developer, Runner, QA, Auditor, PM | Implementation evidence, test output, QA report, audit feedback, follow-up card |
| Deliver | Prepare user-facing outcome, release posture, and closure path. | Release/Closeout Agent, Auditor, PM, User | Release packet, closeout packet, Resolved state, user approval/rejection |
| Feedback / Improve | Capture lessons and improve knowledge, backlog, product model, and artifacts. | User, PM, Knowledge Curator, Auditor | Knowledge update proposal, cleanup card, future backlog card, revised artifact classification |

---

## 3. How Ideas Become Cards

All significant work begins with user intent. The Operator performs intake and clarification but does not decide repo truth or architecture truth.

```text
User intent
  -> Operator intake
    -> Orchestrator process classification
      -> board-visible card
        -> PM triage
```

An idea becomes a card when any of the following are true:

- it changes product direction;
- it asks a repo or architecture question;
- it requests implementation;
- it requests cleanup/deprecation;
- it requires QA, audit, or release evidence;
- it affects cost, security, or scope;
- it creates a decision the user must later approve.

The Operator may ask follow-up questions. The Operator must not narrate technical truth when a proper role is required.

---

## 4. How Cards Become Task Packets

The PM owns card state and routing. The PM transforms a card into a task packet only after the minimum definition is present.

Minimum card-to-packet requirements:

- card ID and card type;
- problem statement or objective;
- owner role;
- acceptance criteria;
- QA criteria;
- evidence required;
- role memory refs;
- scope boundary;
- target artifacts/files/capability;
- forbidden actions;
- max exploration boundary;
- stop/escalation rules;
- handoff target;
- non-claims.

The PM may request Architect, QA, Auditor, or Knowledge Curator input before a packet becomes Ready.

---

## 5. Role Path Through a Task Packet

### 5.1 Standard governed path

```text
PM defines packet
  -> Architect advises if architecture is implicated
    -> User decides architecture when needed
      -> Developer implements within packet
        -> QA tests against criteria
          -> Auditor verifies evidence sufficiency
            -> PM marks Resolved when evidence is sufficient
              -> User approves or rejects
                -> Closed or returned to PM
```

### 5.2 Role rules

- PM owns state/routing, but cannot implement or test.
- Architect advises; User decides architecture.
- Developer implements only scoped build work.
- QA tests and reports; QA does not implement fixes.
- Auditor is the evidence brain and can block or request more work.
- Knowledge Curator proposes documentation/classification/cleanup; Auditor verifies.
- Release/Closeout Agent handles release evidence, branch safety, promotion readiness, and closeout packaging.
- User approval is required for closure.

---

## 6. Resolved vs Closed

`Resolved` and `Closed` are different.

| State | Meaning | Who can cause it | Required evidence |
| --- | --- | --- | --- |
| Resolved | The responsible system roles believe the card has sufficient evidence for user review. | PM, after QA/Auditor conditions are satisfied | QA report, audit sufficiency, evidence refs, known risks, non-claims |
| Closed | The User accepts the resolved outcome. | User only | User approval event, final card state, release/closeout refs if applicable |

A card is not Closed because a Developer says it is done, QA passes, or Auditor accepts evidence. Those are prerequisites for user review, not closure.

---

## 7. User Rejection Path

If the User rejects a Resolved card:

```text
User rejection
  -> PM records rejection reason
    -> PM returns card to Refinement or Ready/Rework as appropriate
      -> PM may request Architect/QA/Auditor input
        -> follow-up or re-entry packet is created
```

User rejection does not erase evidence. The prior result remains historical evidence and the new work proceeds through a re-entry packet or follow-up card.

---

## 8. QA and Auditor Follow-Up Work

QA and Auditor findings must not be hidden in comments or narrative. When insufficient evidence or out-of-scope work is found:

- QA records failure or inconclusive result;
- Auditor records evidence insufficiency or rejected claim;
- PM creates a follow-up card or re-entry packet;
- the original card may remain Blocked, In Progress, Audit, or Resolved depending on severity;
- late-discovered scope becomes a follow-up card rather than silently rewriting the original card.

---

## 9. Feedback Into Knowledge Base and Future Backlog

Feedback / Improve is a required product loop.

Feedback sources:

- User rejection or approval notes;
- QA failures;
- Auditor insufficiency findings;
- Developer blockers;
- Knowledge Curator classification proposals;
- external replay failures;
- release/closeout risks;
- cost or context-burn events.

Feedback actions:

```text
feedback item
  -> PM logs card
    -> Knowledge Curator proposes classification/update when applicable
      -> Auditor verifies
        -> User approves cleanup/deprecation when needed
          -> artifact registry / backlog / knowledge map updated
```

---

## 10. Board/Repo Relationship

Repo truth remains canonical. The board is the live process surface.

This model allows external mirrors such as GitHub Issues/Projects or Linear, but external boards must be adapters. The AIO-owned card schema and repo evidence model must remain the source of truth unless a future governance decision explicitly changes that.

---

## 11. Stop and Recovery

Any daemon, runner, or long-running agent execution must support:

- stop button or stop event;
- run ledger;
- partial evidence preservation;
- baton/re-entry packet;
- user-visible blocked/paused state;
- no silent continuation after authority changes.

Stop does not destroy partial work by default. It preserves the current state for PM/Auditor/User decision.

---

## 12. Non-Claims

This operating model does not claim:

- a productized board exists;
- a custom control-room UI exists;
- true multi-agent execution is already implemented;
- external boards are canonical;
- Codex compaction is solved;
- daemon behavior is safe until stop/recovery is implemented;
- any successor milestone is proposed.
