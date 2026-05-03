# AIOffice Architecture and Integration Direction

**Document status:** Proposed v1
**Document type:** Architecture direction and external tool strategy
**Scope:** Direction only; no implementation or successor milestone proposed.

---

## 1. Executive Architecture Verdict

The recommended direction is accepted:

> **Define an AIO-owned board/card/memory model first. Use GitHub Issues/Projects as the first practical external mirror because it is closest to repo truth and GitHub Actions. Keep Linear/Symphony compatibility as an adapter/lab path. Build a custom AIO board/control room only after schema, authority model, agent memory, and re-entry mechanics are proven.**

Reason:

R13 did not fail because the wrong commercial board was chosen. R13 failed/partial because AIOffice still lacks a productized live process surface, enforceable role separation, true agent identity, memory routing, low-manual-burden runner dispatch, and productized control-room behavior.

A board tool can mirror work, but it cannot solve authority.

---

## 2. Option Evaluation

### 2.1 GitHub Issues/Projects

| Category | Assessment |
| --- | --- |
| Strengths | Closest to repo truth, commits, PRs, branches, GitHub Actions, external replay, and existing AIO evidence. Lower sync/auth complexity. Cost-effective. |
| Weaknesses | Not ideal as final product UI; limited native agent memory, stop controls, role-specific views, and re-entry visualization. |
| Best use | First practical external mirror and low-cost operational board. |
| Risk | Mistaking GitHub Projects for final AIO control room. |
| Verdict | Best first mirror, not canonical truth. |

### 2.2 Linear

| Category | Assessment |
| --- | --- |
| Strengths | Strong issue tracker UX; Symphony reference orientation; good for workflow queues and product/project visibility. |
| Weaknesses | Adds separate auth/sync layer; can drift from repo truth; risks overfitting AIO to Symphony before AIO domain model is stable. |
| Best use | Adapter/lab path for Symphony-compatible orchestration experiments. |
| Risk | Linear state starts feeling canonical before AIO card schema exists. |
| Verdict | Keep compatible; do not make first canonical board. |

### 2.3 Custom AIO Board / Control Room

| Category | Assessment |
| --- | --- |
| Strengths | Maximum control over roles, memory, stop, runner status, evidence, costs, and user approvals. Best long-term product surface. |
| Weaknesses | Expensive; risks UI build before authority/card model is stable. |
| Best use | Long-term product surface after schema and authority are proven. |
| Risk | Building UI around unstable workflow assumptions. |
| Verdict | Target-state product surface, not first build step. |

### 2.4 OpenAI Symphony

| Category | Assessment |
| --- | --- |
| Strengths | Strong inspiration for isolated workspaces, issue polling, repo-owned workflow policy, agent runner, retries, and observability. |
| Weaknesses | It is a runner/scheduler model, not AIO governance. It is Linear-oriented in current spec and high-trust by default depending on implementation. |
| Best use | Downstream runner subsystem below AIO task-packet authority. |
| Risk | Treating Symphony as parent control plane. |
| Verdict | Use philosophy and patterns; integrate only as subordinate runner path. |

### 2.5 Codex

| Category | Assessment |
| --- | --- |
| Strengths | Strong bounded executor for repo work. Aligns with OpenAI/Codex-centered AIO direction. |
| Weaknesses | Chat continuity and compaction are operational problems. Codex must not be control plane. |
| Best use | Scoped Developer/Architect executor inside task packets. |
| Risk | Reverting to operator copy/paste and single-agent narration. |
| Verdict | Keep Codex-first execution, but route through API/task packet/runner surface. |

### 2.6 OpenAI API / Agent Builder-Style Surfaces

| Category | Assessment |
| --- | --- |
| Strengths | Could expose direct agents, controlled tools, memory refs, and operator-facing workflows. |
| Weaknesses | Must not bypass AIO board/card state or role authority. |
| Best use | Operator surface and role-agent invocation layer when tool permissions are explicit. |
| Risk | Pretty agent UI without governance enforcement. |
| Verdict | Useful after identity, RACI, and board schema are defined. |

### 2.7 GitHub Actions

| Category | Assessment |
| --- | --- |
| Strengths | Proven external replay/evidence substrate; close to repo truth. |
| Weaknesses | Manual dispatch/import remains a blocker if not automated or explicitly bounded. |
| Best use | External replay, validation, evidence identity. |
| Risk | Treating one bounded external replay as production CI. |
| Verdict | Keep as primary external proof substrate. |

### 2.8 Knowledge-Base Tools

| Category | Assessment |
| --- | --- |
| Strengths | Can reduce context burn and improve navigation. |
| Weaknesses | A knowledge tool without artifact classification becomes another place for stale context. |
| Best use | AIO-owned artifact registry and knowledge maps first; external KB tools later. |
| Risk | External KB becomes stale or non-canonical. |
| Verdict | Define AIO registry first; tools are adapters. |

---

## 3. Recommended Baseline Architecture

```text
User / Operator
  -> AIO Board/Card Surface
    -> PM-owned card state and task packets
      -> Role-specific Agent Identity Packet
        -> scoped memory refs + tool profile
          -> Developer / QA / Auditor / Architect / Knowledge Curator / Release Agent
            -> runner/API/Codex/GitHub Actions/Symphony-subsystem as needed
              -> committed evidence artifacts
                -> board refresh
                  -> user decision
```

---

## 4. Board Tool Decision

Recommended path:

1. AIO-owned board/card/memory schema.
2. Repo-backed card artifacts.
3. GitHub Issues/Projects mirror first.
4. Linear/Symphony adapter later.
5. Custom AIO board/control room after schema/authority/memory is proven.

This is the best balance between quality and cost-effectiveness.

---

## 5. Symphony Compatibility Strategy

AIOffice should remain compatible with Symphony concepts:

- tracker adapter;
- isolated workspaces;
- repo-owned workflow policy;
- bounded concurrency;
- retries and reconciliation;
- structured runtime logs;
- Codex app-server runner.

But AIOffice must add:

- card/task-packet authority;
- role identity;
- PM state ownership;
- Auditor sufficiency;
- user closure approval;
- evidence taxonomy;
- stop button;
- cost controls;
- knowledge refs and re-entry packets.

Symphony can run work. AIOffice decides what work is authorized, what evidence is sufficient, and whether the card may close.

---

## 6. External Board Sync Rules

Any external board mirror must preserve:

- AIO card ID;
- repo evidence refs;
- current branch/head/tree when relevant;
- status and sub-status mapping;
- PM ownership;
- resolved vs closed distinction;
- user approval requirement;
- non-claims.

If external board state conflicts with repo truth, repo truth wins and the mirror is stale.

---

## 7. Non-Claims

This direction does not claim:

- GitHub Projects mirror is implemented;
- Linear adapter is implemented;
- Symphony is integrated;
- custom board exists;
- Agent Builder is integrated;
- board state enforcement exists;
- R13 is closed;
- a successor milestone is open.
