# AIOffice Milestone Reporting Standard

**Document status:** Proposed v1
**Document type:** Milestone/release reporting standard
**Companion template:** `governance/templates/AIOffice_Milestone_Report_Template_v2.md`
**Scope:** Reporting framework only; does not prove implementation.

---

## 1. Purpose

AIOffice milestone reports must be readable by the operator without flattening product outcomes, architecture capabilities, governance controls, evidence practices, and implementation artifacts into one confusing table.

The report hierarchy is:

1. TL;DR bullet points of key findings.
2. Summary of what was implemented since the last report.
3. A progress table measured by KPI domain, showing the current milestone and the previous three runs.
4. Detailed domain drill-down with evidence for selective inspection.
5. Mandatory RACI/role enforcement review.
6. Evidence appendix with commits, files, commands, external runs, artifacts, non-claims, and rejected claims.

Reports are operator artifacts. They are not proof by themselves.

---

## 2. Evidence Hierarchy

| Evidence class | Treatment |
| --- | --- |
| External/replay evidence | Strongest practical evidence when run ID, artifact ID, digest, head, tree, and command results are concrete. |
| Committed machine evidence | Strong evidence when validated and bound to repo refs. |
| Implemented code/contracts/tests | Shows capability exists, but not that it worked. |
| Generated Markdown/reports | Operator-readable artifacts only unless backed by machine evidence. |
| Narrative/operator/bootstrap notes | Useful context, not proof. |
| Unsupported claims | Rejected or unknown. |

Every report must distinguish implemented code, committed machine evidence, generated artifacts, external replay evidence, operator/bootstrap narrative, and non-claims.

---

## 3. Required Executive Report Structure

### A. TL;DR

Must include:

- Overall outcome.
- Top delivered items.
- Top blockers.
- KPI movement.
- User decisions required.

### B. What Changed Since Last Report

Required table:

| Area | Implemented since last report | Evidence | Impact |
| --- | --- | --- | --- |
|  |  |  |  |

### C. Executive KPI Scorecard

Required table:

| KPI domain | Previous run -3 | Previous run -2 | Previous run -1 | Current milestone | Change | Confidence | Verdict |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
|  |  |  |  |  |  |  |  |

### D. Domain Drill-Down

For each KPI domain, report:

- Score.
- Confidence.
- What improved.
- What did not improve.
- Evidence.
- Risks.
- Next correction.

### E. RACI / Role Enforcement Section

Every report must include a role enforcement section. It must answer:

- Which roles acted?
- Which roles were simulated or missing?
- Did any role exceed authority?
- Did Developer change state?
- Did QA implement?
- Did PM implement or test?
- Did Auditor block or approve evidence?
- Did User approve closure?
- Were direct agent identities and memory scopes explicit?

### F. Evidence Appendix

Must include:

- commits;
- files;
- test commands;
- external runs;
- artifacts;
- non-claims;
- rejected claims.

---

## 4. KPI Domain Model

Milestone reports must use the 10-domain model defined in `governance/KPI_DOMAIN_MODEL.md`.

| Domain | Weight |
| --- | ---: |
| Product Experience & Double-Diamond Workflow | 12% |
| Board & Work Orchestration | 12% |
| Agent Workforce & RACI | 14% |
| Knowledge, Memory & Context Compression | 12% |
| Execution Harness & QA | 14% |
| Governance, Evidence & Audit | 8% |
| Architecture & Integrations | 8% |
| Release & Environment Strategy | 6% |
| Security, Safety & Cost Controls | 8% |
| Continuous Improvement & Auto-Research | 6% |

The report must not collapse these domains into a single vague progress percentage.

---

## 5. Maturity and Confidence Scoring

### 5.1 Maturity

| Score | Label | Meaning |
| ---: | --- | --- |
| 0 | Absent | No meaningful evidence. |
| 1 | Described | Mentioned in docs or vision. |
| 2 | Designed | Contracts/schemas/rules exist. |
| 3 | Implemented | Tools/code/workflows exist. |
| 4 | Exercised | Capability was run with evidence. |
| 5 | Operationalized | Repeatable, visible, role-owned, evidence-backed, and low manual burden. |

### 5.2 Confidence

| Confidence | Definition |
| --- | --- |
| A | External/replay evidence + committed artifacts + independent validation. |
| B | Committed machine evidence + local validation. |
| C | Implemented code/contracts but limited execution. |
| D | Reports/narrative/operator artifact only. |
| E | Unsupported or unknown. |

### 5.3 Score conversion

```text
domain_score = weighted maturity average / 5 * 100
```

### 5.4 Cap rules

| Evidence posture | Max score |
| --- | ---: |
| Only narrative/docs | 20 |
| Contract exists but not implemented | 40 |
| Implemented but not exercised | 60 |
| Exercised only locally | 70 |
| Exercised externally but manual-heavy | 80 |
| Repeatable, visible, role-owned, evidence-backed, low manual burden | 90+ |
| Production/user-ready | 95+ only with strong evidence |

---

## 6. Mandatory Non-Claim Rules

A report must explicitly preserve non-claims when relevant:

- no closed milestone unless closeout evidence exists;
- no successor opening unless explicit repo-truth opening evidence exists;
- no production runtime unless production runtime is proved;
- no production QA unless production QA is proved;
- no full product QA unless full product QA is proved;
- no productized UI unless a productized UI exists and is exercised;
- no broad autonomy unless role-bound, stop-capable, evidence-backed autonomy exists;
- no solved Codex reliability or compaction unless evidence proves it;
- no external board canonical truth unless governance changes.

---

## 7. Required RACI Reporting

Each milestone report must include this compact RACI health table:

| Check | Pass/Fail/Partial | Evidence | Notes |
| --- | --- | --- | --- |
| PM owned card state/routing |  |  |  |
| Developer stayed within packet |  |  |  |
| QA executed criteria without implementing |  |  |  |
| Auditor reviewed evidence sufficiency |  |  |  |
| User approval required for closure |  |  |  |
| Release/Closeout Agent did not override failed gates |  |  |  |
| No fake multi-agent narration accepted as proof |  |  |  |

---

## 8. Reporting Verdicts

| Verdict | Meaning |
| --- | --- |
| Passed | Evidence supports all required gates for the claimed scope. |
| Failed/Partial | Some implementation or evidence exists, but required gates remain partial or blocked. |
| Blocked | Required authority, evidence, tool access, or user decision is missing. |
| Not started | No meaningful evidence. |
| Not applicable | Domain does not apply to this milestone, with justification. |

A report may recommend future direction, but it must not open a successor milestone.
