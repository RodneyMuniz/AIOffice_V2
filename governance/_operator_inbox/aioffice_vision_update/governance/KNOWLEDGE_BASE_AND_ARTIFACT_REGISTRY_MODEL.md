# AIOffice Knowledge Base and Artifact Registry Model

**Document status:** Proposed v1
**Document type:** Knowledge architecture and artifact classification model
**Scope:** Target model only; not implementation proof.

---

## 1. Purpose

AIOffice has accumulated many reports, contracts, tools, validators, evidence files, and historical artifacts. Without classification, agents waste context and the operator loses visibility.

This document defines a layered knowledge system and artifact registry to reduce context burn and make repo truth navigable.

---

## 2. Human Knowledge Layers

### L1: High-Level Process Diagrams

Audience: User, Operator, reviewer, architecture PRO.

Purpose:

- show Discover -> Define -> Develop -> Deliver -> Feedback/Improve;
- show User and role interaction;
- show board/card lifecycle;
- show release/closeout path;
- show how evidence flows to user approval.

### L2: Architecture Environment Map

Audience: human + agents.

Purpose:

- show harness components;
- show board/card schema;
- show contracts/validators;
- show runner/external replay flow;
- show knowledge base;
- show integrations;
- show release/security/cost controls.

### L3: Artifact/Capability Relationship Map

Audience: agents, auditors, maintainers.

Purpose:

- map files to capabilities;
- identify which artifacts are current/core;
- separate historical and deprecated artifacts;
- show which contracts support which tools/tests;
- reduce full-repo scanning.

---

## 3. AI-Friendly Layer

Machine-readable knowledge should include:

- system map;
- artifact registry;
- capability map;
- decision index;
- role memory refs;
- task packet links;
- stale/deprecated artifact index;
- cleanup candidate list.

Agents should load these refs instead of scanning the repo broadly.

---

## 4. Artifact Classification

| Classification | Meaning | Use rule |
| --- | --- | --- |
| Core | Current product/control capability. | Load when relevant to task. |
| Supporting | Used by a current capability but not primary. | Load only when referenced. |
| Historical | Useful for audit/history, not active execution. | Do not use as current authority. |
| Deprecated | Should not be used for new decisions. | Refuse unless audit/history task. |
| Candidate | Proposed/experimental, not authority yet. | Treat as proposal only. |
| Cleanup candidate | Possibly stale, duplicate, or unused. | Requires verification and approval. |
| Unknown | Needs classification. | Route to Knowledge Curator. |

---

## 5. Artifact Registry Fields

Minimum fields:

```json
{
  "artifact_id": "...",
  "path": "...",
  "classification": "Core|Supporting|Historical|Deprecated|Candidate|Cleanup candidate|Unknown",
  "capability_area": "...",
  "owning_role": "...",
  "current_authority": true,
  "supersedes": [],
  "superseded_by": null,
  "last_verified_head": "...",
  "related_contracts": [],
  "related_tools": [],
  "related_tests": [],
  "related_evidence": [],
  "load_rules": "...",
  "avoid_rules": "...",
  "notes": "..."
}
```

---

## 6. Knowledge Update and Cleanup Flow

```text
Knowledge Curator proposes classification/update/cleanup
  -> Auditor verifies evidence and risk
    -> PM logs Knowledge Update or Cleanup Candidate card
      -> User approves cleanup/deprecation when material
        -> artifact registry is updated
          -> docs/maps are regenerated
```

No agent may delete, deprecate, or hide artifacts unilaterally.

---

## 7. Context-Burn Reduction Rules

- Task packets must include relevant knowledge refs.
- Agents should load only scoped refs by default.
- Full-repo scans require explicit reason and max exploration boundary.
- Unknown artifacts become classification tasks, not repeated exploratory scans.
- Stale artifacts become cleanup candidates.
- Every milestone should include a knowledge update step before external audit/future planning.

---

## 8. Milestone Knowledge Requirement

Every milestone report should include:

- new core artifacts;
- new supporting artifacts;
- historical artifacts created;
- cleanup candidates discovered;
- deprecated artifacts approved;
- knowledge map changes;
- unresolved classification risks.

---

## 9. Non-Claims

This model does not claim:

- a knowledge graph exists;
- artifact registry is implemented;
- historical files are already classified;
- cleanup is authorized;
- context burn is solved.
