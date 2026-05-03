# AIOffice KPI Domain Model

**Document status:** Proposed v1
**Document type:** KPI framework and maturity scoring model
**Scope:** Product vision/reporting framework only; not implementation proof.

---

## 1. Purpose

This document replaces the prior flat Product / Workflow / Architecture / Governance score table with a domain maturity model that connects high-level product vision to evidence, contracts, board state, role behavior, and operator usefulness.

The model is designed to make milestone reports readable:

1. first show TL;DR and executive score movement;
2. then show current milestone versus the previous three runs;
3. then allow drill-down by domain with evidence.

---

## 2. Domain Weights

The proposed 10-domain model is accepted with one adjustment: Board & Work Orchestration receives extra weight because R13 failed partly from lack of productized board/control-room behavior, while Governance/Evidence is already comparatively mature.

| # | Domain | Weight | Reason |
| ---: | --- | ---: | --- |
| 1 | Product Experience & Double-Diamond Workflow | 12% | Keeps user-facing product value visible. |
| 2 | Board & Work Orchestration | 12% | Elevated because board/process surface is now the primary missing product layer. |
| 3 | Agent Workforce & RACI | 14% | Highest priority because fake/blurred agent behavior is a core risk. |
| 4 | Knowledge, Memory & Context Compression | 12% | Elevated because context burn and compaction are operational blockers. |
| 5 | Execution Harness & QA | 14% | Highest priority because bounded execution and QA are the core production loop. |
| 6 | Governance, Evidence & Audit | 8% | Still required, but reduced because this domain is already comparatively strong. |
| 7 | Architecture & Integrations | 8% | Important for GitHub/Linear/Symphony/API direction. |
| 8 | Release & Environment Strategy | 6% | Needed but should not dominate before product workflow exists. |
| 9 | Security, Safety & Cost Controls | 8% | Must remain visible from early design. |
| 10 | Continuous Improvement & Auto-Research | 6% | Required feedback loop but secondary to board/agent/execution foundations. |
| **Total** |  | **100%** |  |

---

## 3. Maturity Scale

Use maturity instead of subjective 0-100 scoring.

| Maturity | Label | Meaning |
| ---: | --- | --- |
| 0 | Absent | No meaningful definition, design, implementation, or evidence. |
| 1 | Described | Concept is described in vision/reporting docs only. |
| 2 | Designed | Contracts, schemas, or operating rules exist. |
| 3 | Implemented | Tools/code/workflows exist, but limited execution evidence. |
| 4 | Exercised | Capability has been run and evidence exists. |
| 5 | Operationalized | Capability is repeatable, visible, role-owned, evidence-backed, and low-manual-burden. |

Domain score:

```text
domain_score = weighted maturity average / 5 * 100
```

---

## 4. Evidence Confidence

| Confidence | Definition |
| --- | --- |
| A | External/replay evidence + committed artifacts + independent validation. |
| B | Committed machine evidence + local validation. |
| C | Implemented code/contracts but limited execution. |
| D | Reports, generated Markdown, or operator artifact only. |
| E | Unsupported, unknown, or contradicted. |

Confidence is independent from maturity. A domain can have implemented tooling with low confidence if evidence is stale or narrative-only.

---

## 5. Score Cap Rules

Scores must be capped by evidence class:

| Evidence posture | Max score |
| --- | ---: |
| Narrative/docs only | 20 |
| Contract exists but not implemented | 40 |
| Implemented but not exercised | 60 |
| Exercised only locally | 70 |
| Exercised externally but manual-heavy | 80 |
| Repeatable, visible, role-owned, evidence-backed, low manual burden | 90+ |
| Production/user-ready with strong evidence | 95+ |

No score may exceed its evidence cap unless the report explicitly lists the evidence that justifies the exception.

---

## 6. Domain Definitions

### 6.1 Product Experience & Double-Diamond Workflow

| Field | Definition |
| --- | --- |
| Purpose | Measure whether AIOffice feels like a usable product that guides Discover, Define, Develop, Deliver, and Feedback/Improve. |
| Subcategories | Intake clarity; Double Diamond stage visibility; operator usefulness; approval flow; feedback capture. |
| Sample KPIs | % cards with stage; % decisions visible to user; number of manual copy/paste steps; operator demo usefulness score. |
| Evidence required | Board/card artifacts, operator demo, control-room state, user decisions, workflow screenshots or equivalent artifacts. |
| Weak evidence | Generated Markdown only; narrative claims of usefulness; stale status. |
| Maturity criteria | 0 absent; 1 described; 2 flow schema; 3 generated views; 4 exercised workflow; 5 repeatable user-visible product loop. |
| Confidence rules | A requires externally exercised or independently validated product workflow; D for reports only. |

### 6.2 Board & Work Orchestration

| Field | Definition |
| --- | --- |
| Purpose | Measure whether work is board-visible, stateful, routable, and authority-bound. |
| Subcategories | Card schema; statuses/sub-statuses; PM state ownership; task packets; external board mirror; stop/retry/re-entry. |
| Sample KPIs | % significant questions converted to cards; % cards with owner/packet/evidence refs; stale-card count; direct runner state reflected on board. |
| Evidence required | Board/card schemas, card artifacts, status transitions, external mirror sync logs if used. |
| Weak evidence | Markdown KANBAN without governed card state; external board state without repo binding. |
| Maturity criteria | 0 absent; 1 described; 2 schema; 3 generated card store; 4 exercised card lifecycle; 5 live operational board with low manual burden. |
| Confidence rules | A requires repeatable lifecycle with evidence and validation; B for committed card state + local validation. |

### 6.3 Agent Workforce & RACI

| Field | Definition |
| --- | --- |
| Purpose | Measure whether agents are separate bounded roles with enforceable authority instead of fake multi-agent narration. |
| Subcategories | Agent identity packets; RACI; role-specific memory; direct agent access; handoff packets; forbidden actions. |
| Sample KPIs | % agent runs with identity packet; % handoffs with artifacts; number of role-boundary violations; direct agent invocation coverage. |
| Evidence required | Agent identity packets, role profiles, audit logs, handoff artifacts, RACI enforcement tests. |
| Weak evidence | One model narrating as multiple roles; role labels without separate bounded execution. |
| Maturity criteria | 0 absent; 1 role list; 2 RACI/identity design; 3 role tooling; 4 exercised handoffs; 5 repeatable multi-agent operation with audit. |
| Confidence rules | A requires multiple agent runs with artifacts and independent audit. |

### 6.4 Knowledge, Memory & Context Compression

| Field | Definition |
| --- | --- |
| Purpose | Measure whether AIOffice reduces context burn and survives compaction through scoped memory and artifact maps. |
| Subcategories | Artifact registry; capability map; role memory refs; task packets; re-entry packets; cleanup classification. |
| Sample KPIs | average loaded memory refs per task; full-repo scan count; stale artifact count; re-entry success rate. |
| Evidence required | Registry, knowledge maps, task packets with refs, re-entry packets, compaction/restart proofs. |
| Weak evidence | Long restart prompts only; broad repo scans; unclassified artifacts. |
| Maturity criteria | 0 absent; 1 described; 2 registry design; 3 generated registry; 4 exercised scoped re-entry; 5 operational memory routing. |
| Confidence rules | A requires exercised re-entry without prior chat context plus evidence validation. |

### 6.5 Execution Harness & QA

| Field | Definition |
| --- | --- |
| Purpose | Measure whether scoped execution, validation, fix loops, and QA evidence are real. |
| Subcategories | Task packet execution; custom runner; external replay; QA criteria; fix queue; before/after proof; final signoff. |
| Sample KPIs | test pass rate; issues detected/fixed; QA loop completion rate; external replay success; blocked gate count. |
| Evidence required | Runner packets, command logs, QA reports, fix results, external replay artifacts, signoff matrices. |
| Weak evidence | Executor self-certification; local-only evidence claimed as external proof; zero-issue reports with no seeded defect. |
| Maturity criteria | 0 absent; 1 described; 2 contracts; 3 runner/QA tooling; 4 exercised QA loop; 5 repeatable QA pipeline with low manual dispatch. |
| Confidence rules | A requires external replay + committed artifacts + independent validation. |

### 6.6 Governance, Evidence & Audit

| Field | Definition |
| --- | --- |
| Purpose | Measure fail-closed control, evidence sufficiency, auditability, and non-claim discipline. |
| Subcategories | Evidence taxonomy; audit packets; rejected claims; status gates; proof review; external audit. |
| Sample KPIs | rejected claim count; unsupported claim count; evidence coverage; audit blocker closure rate. |
| Evidence required | Audit packets, decision packets, scorecards, status validators, proof packages. |
| Weak evidence | Report-only proof; stale scorecards; narrative confidence. |
| Maturity criteria | 0 absent; 1 doctrine; 2 contracts; 3 validators; 4 exercised audits; 5 operational audit gate. |
| Confidence rules | A requires external or independent audit evidence. |

### 6.7 Architecture & Integrations

| Field | Definition |
| --- | --- |
| Purpose | Measure integration readiness and architecture clarity for GitHub, Linear, Symphony, Codex, OpenAI API, boards, and knowledge tools. |
| Subcategories | Integration adapters; API boundaries; external board mirror; Symphony runner path; GitHub Actions; architecture decisions. |
| Sample KPIs | adapter coverage; auth readiness; failed integration count; external dependency risk score. |
| Evidence required | Architecture docs, adapter contracts, integration tests, external run evidence. |
| Weak evidence | Tool enthusiasm without authority model; vendor-specific board becoming truth accidentally. |
| Maturity criteria | 0 absent; 1 direction; 2 adapter design; 3 implemented adapter; 4 exercised integration; 5 stable integration under AIO authority. |
| Confidence rules | A requires exercised integration with repo-bound evidence and rollback plan. |

### 6.8 Release & Environment Strategy

| Field | Definition |
| --- | --- |
| Purpose | Measure branch, environment, promotion, backup, rollback, and closeout safety. |
| Subcategories | Branch model; Dev/UAT/PRD direction; release packaging; final-head support; rollback points; closeout eligibility. |
| Sample KPIs | release packets completed; final-head support existence; rollback drill success; branch hygiene violations. |
| Evidence required | Release packets, branch refs, final-head support, rollback packets, promotion decisions. |
| Weak evidence | Generated report with no final-head support; release decision without gate evidence. |
| Maturity criteria | 0 absent; 1 described; 2 release model; 3 tooling; 4 exercised release/rollback; 5 repeatable promotion workflow. |
| Confidence rules | A requires externally verified release/rollback evidence where applicable. |

### 6.9 Security, Safety & Cost Controls

| Field | Definition |
| --- | --- |
| Purpose | Measure privacy, least privilege, tool boundaries, prompt injection protection, costs, and stop controls. |
| Subcategories | Secrets; API key handling; permission profiles; data exposure; cost budgets; stop button; runaway loop control. |
| Sample KPIs | secrets in repo; write tools with scoped permissions; prompt injection tests; task cost variance; uncontrolled loops. |
| Evidence required | Secret scan results, permission profiles, cost logs, stop events, safety tests. |
| Weak evidence | Policy docs only; broad tool access; untracked token/API spend. |
| Maturity criteria | 0 absent; 1 described; 2 control design; 3 implemented scans/permissions; 4 exercised safety controls; 5 operational safety dashboard. |
| Confidence rules | A requires repeatable scans/tests and logged safe-stop behavior. |

### 6.10 Continuous Improvement & Auto-Research

| Field | Definition |
| --- | --- |
| Purpose | Measure whether lessons, research, audits, and external developments improve the product without bypassing governance. |
| Subcategories | Research cards; feedback loop; knowledge updates; model/tool watch; milestone retrospectives; auto-research proposals. |
| Sample KPIs | research cards converted to decisions; knowledge updates accepted; cleanup proposals verified; external tool evaluations completed. |
| Evidence required | Research cards, decision logs, knowledge updates, audit notes, accepted/rejected proposals. |
| Weak evidence | Research narrative with no board card or decision. |
| Maturity criteria | 0 absent; 1 described; 2 research workflow; 3 tooling/templates; 4 exercised improvement loop; 5 continuous governed improvement. |
| Confidence rules | A requires accepted decisions backed by evidence and board traceability. |

---

## 7. Domain Verdict Labels

| Verdict | Meaning |
| --- | --- |
| Strong | Operationalized or near-operationalized with high confidence and low manual burden. |
| Improving | Meaningful evidence-backed movement, but not operational. |
| Partial | Some tooling/evidence exists, but key gates remain incomplete. |
| Weak | Mostly design/reporting; little useful execution. |
| Blocked | Known missing authority, evidence, integration, or user decision prevents progress. |
| Unknown | Insufficient evidence to score. |

---

## 8. Reporting Rule

Every milestone report must show:

- each domain score for the current milestone and previous three runs;
- change from the prior run;
- confidence level;
- verdict;
- evidence refs;
- risks and next correction.

No KPI should be considered trusted if it cannot drill down to evidence.
