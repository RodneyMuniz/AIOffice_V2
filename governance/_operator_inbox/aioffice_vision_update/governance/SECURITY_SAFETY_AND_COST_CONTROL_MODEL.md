# AIOffice Security, Safety, and Cost Control Model

**Document status:** Proposed v1
**Document type:** Security, tool-boundary, stop, and budget-control model
**Scope:** Target model only; not implementation proof.

---

## 1. Purpose

This document defines early security, safety, and cost controls required for a board-driven, agentic AIOffice system.

Security and cost controls must not be deferred until after daemon/runner behavior exists. They must shape the board, agent identity, tool permissions, and release strategy from the start.

---

## 2. Control Categories

### 2.1 Repo Privacy

- repo visibility review;
- sensitive artifact classification;
- external-board mirror privacy;
- data minimization for prompts and agents.

### 2.2 Secret Management

- no secrets in repo;
- API keys/tokens stored outside committed files;
- per-tool credential scopes;
- audit of environment-variable use;
- secret scan in milestone reports.

### 2.3 Least-Privilege Tool Permissions

- tool permission profiles by role;
- write tools scoped to task packet;
- external API tools disabled unless explicitly allowed;
- no broad destructive tools by default.

### 2.4 Prompt Injection and Data Exposure

- prompt-injection test cases for external content;
- no automatic trust of issue text, Linear/GitHub comments, or external Markdown;
- knowledge refs treated as data, not authority unless classified;
- external tool outputs validated before state mutation.

### 2.5 Cost Visibility

- per-card cost budget;
- per-agent-run token/API estimate;
- cost recorded in run ledger;
- cost threshold stop;
- operator-visible cost summary.

### 2.6 Stop Button and Runaway Control

- operator stop event;
- daemon shutdown path;
- retry ceiling;
- stall detection;
- stop/recovery packet;
- no invisible continuation after stop.

---

## 3. Security and Safety KPIs

| KPI | Target |
| --- | --- |
| Number of secrets in repo | 0 |
| Write tools without scoped permissions | 0 |
| Prompt injection tests for external content | Increasing coverage |
| Cost per task/milestone | Recorded and visible |
| Uncontrolled loops | 0 |
| Safe stop events | Recorded and recoverable |
| External tool trust-boundary violations | 0 |
| Cards missing cost budget | 0 when cost controls are operational |

---

## 4. Evidence Required

- secret scan results;
- permission profile artifacts;
- agent identity packets with allowed/forbidden tools;
- cost logs;
- stop/recovery packets;
- prompt injection test results;
- external tool validation logs;
- rejected unsafe action claims.

---

## 5. Weak Evidence

Weak evidence includes:

- policy docs only;
- broad tool access with no audit;
- untracked API/token spend;
- external comments treated as trusted instructions;
- stop button described but not exercised;
- secret scanning not run.

---

## 6. Required Board Integration

Every execution-capable card should eventually carry:

- cost budget;
- tool permission profile;
- external data exposure level;
- stop/escalation rules;
- secret/access requirements;
- prompt-injection risk when external text is loaded.

---

## 7. Non-Claims

This model does not claim:

- secret scanning is implemented;
- cost dashboard exists;
- stop button exists;
- prompt-injection controls are operational;
- least-privilege tooling is enforced by runtime.
