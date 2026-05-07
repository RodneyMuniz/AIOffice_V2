# AIOffice V2 Revised R17 Plan: Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle

**Source report:** `governance/reports/AIOffice_V2_R16_External_Audit_and_R17_Planning_Report_v1.md`
**Purpose:** Revised R17 plan responding to operator direction that R17 must create a complete agentic release cycle with visible Kanban movement, Orchestrator-led delegation, Developer/Codex execution, QA/Test Agent validation, Evidence Auditor API audit, and four exercised A2A cycles.
**Status:** Planning artifact only. Does not open R17. Does not merge to main. Does not claim production runtime, product runtime, true multi-agent execution, external audit acceptance, solved Codex compaction, or solved Codex reliability.
**Milestone:** `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
**Starting point:** R16 final accepted head `5bae17229ea10dee4ce072b258f828220b9d1d8d`, tree `9de1a7b733f400da78f8e683ae4111977c70f1fb`
**Template lineage:** Uses the planning structure of `AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md`
**KPI model used:** `governance/KPI_DOMAIN_MODEL.md`
**Reporting standard used:** `governance/MILESTONE_REPORTING_STANDARD.md`

---

## 18. R17 Readiness Assessment

R16 is sufficient to authorize a **planning/opening prompt** for R17, but R17 must not be a small governance-extension milestone. The operator’s expectation is explicit: R17 must make AIOffice feel like a product that is evolving into an agentic operating system.

R16 provided the governed substrate:

- deterministic memory layers;
- role memory packs;
- artifact and audit maps;
- context-load plans;
- context budget estimates;
- fail-closed context guard;
- role-run envelopes;
- RACI transition gates;
- handoff packet reports;
- restart/role-handoff/audit-readiness drills;
- friction metrics;
- final proof/review package candidate.

R17 must use that substrate to produce a visible operating loop:

```text
User
-> Orchestrator
-> Board/Kanban card
-> PM/Architect definition packet
-> Developer/Codex executor adapter
-> QA/Test Agent adapter
-> Developer fix loop if needed
-> Evidence Auditor API adapter
-> Release/Closeout Agent
-> User review and explicit closure decision
```

This still does **not** mean production runtime or broad autonomy. It means the milestone must implement enough product runtime substrate that the operator no longer performs the normal release cycle by copying prompts between GPT and Codex.

| Readiness question | Revised auditor answer |
| --- | --- |
| Can R16 be accepted? | Yes, with caveats. |
| Can R17 be proposed? | Yes. |
| Does this plan open R17? | No. It is a planning artifact pending operator authorization. |
| Should R17 be capped as a small release? | No. A meaningful R17 must be large enough to create a visible product shift. |
| What should R17 target? | Orchestrator-led Kanban workflow, agent registry, scoped memory loading, A2A dispatcher, Developer/Codex adapter, QA/Test Agent adapter, Evidence Auditor API adapter, tool-call ledger, stop/retry/re-entry controls, and final proof packaging. |
| What must R17 prove? | At least one complete release-cycle path where normal happy-path Developer/Codex delegation happens without manual GPT-to-Codex prompt transfer. |
| What must R17 make visible to the operator? | Current card, lane/status, active agent, tool call, output packet, evidence refs, defect status, audit verdict, blockers, next action, and user decisions. |
| What must R17 avoid? | Another governance-only loop; fake multi-agent narration; hidden tool calls; unsafe API usage; overbroad autonomy; external-audit/main-merge/product-runtime overclaims. |

### 18.1 Required maturity jump targets

The following targets are planning targets, not R16 claims. R17 should fail closeout if it cannot show the targeted movement with committed evidence.

| KPI domain | R16 audited posture | Minimum R17 closeout target | Stretch target if external evidence succeeds | Required evidence for target |
| --- | --- | --- | --- | --- |
| Product Experience & Double-Diamond Workflow | Score `35`; weak/partial; no live UI | Score at least `70`; exercised Orchestrator-to-board workflow | Score up to `85` if repeatable and low-manual-burden | Kanban UI/control surface, card lifecycle, screenshots or equivalent artifacts, user decision gate. |
| Board & Work Orchestration | Score `60`; role/workflow artifacts but no live board | Score at least `80`; live card state and board event ledger | Score up to `90` if repeatable with low manual burden | Board/card/event contracts, state store, event replay, transition validation, UI. |
| Agent Workforce & RACI | Score `70`; role envelopes and drills only | Score at least `85`; bounded A2A invocations with logs | Score up to `90` if four cycles pass audit | Agent registry, identity packets, A2A logs, tool-call ledger, role-bound outputs. |
| Knowledge, Memory & Context Compression | Score `70`; scoped artifacts and drills | Score at least `80`; live scoped memory loader used in packets | Score up to `90` if no broad scans are needed in happy path | Memory loader, loaded-ref logs, task packets, context-budget checks. |
| Execution Harness & QA | Score `65`; local validation; no Dev/QA adapters | Score at least `80`; Developer/Codex and QA/Test Agent loop exercised | Score up to `90` with external replay/defect loop evidence | Executor adapter, QA adapter, test results, defect/fix packets, validation logs. |
| Governance, Evidence & Audit | Score `70`; strong committed evidence | Score at least `85`; Evidence Auditor API adapter exercised | Score up to `90` with external/pro audit replay | Audit request/response, verdict schema, non-claim/rejected-claim audit, final proof package. |
| Architecture & Integrations | Score `40`; internal architecture only | Score at least `70`; adapters implemented and bounded | Score up to `80` with external replay | Codex executor, QA adapter, Evidence Auditor API, board surface, config/secrets/cost gates. |
| Release & Environment Strategy | Score `70`; final-head support only | Score at least `80`; exercised release-cycle runner and final package | Score up to `90` with external replay | End-to-end cycle package, final report, final-head support, validation manifest. |
| Security, Safety & Cost Controls | Score `60`; guard/non-claim controls | Score at least `80`; secret/cost/stop/retry controls exercised | Score up to `90` with logged safe-stop and replay evidence | Secret gate, cost budget, max tool calls/retries, timeout, stop command, re-entry packet. |
| Continuous Improvement & Auto-Research | Score `60`; friction metrics report | Score at least `75`; friction metrics become board-visible cards and KPIs | Score up to `85` if improvements are closed through the board | Manual-friction counters, improvement cards, event log, KPI movement report. |

### 18.2 Revised R17 thesis

R17 should be named and scoped as:

`R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`

The milestone exists to make AIOffice operate as a governed product loop instead of a manually coordinated prompt workflow. It should make the operator experience visibly different:

- the operator interacts with the Orchestrator;
- the Orchestrator creates and updates board cards;
- PM/Architect shape work packets;
- Developer/Codex receives bounded implementation packets through an adapter;
- QA/Test Agent receives criteria and returns pass/fail/defect packets;
- Developer fixes are routed back through the Orchestrator;
- Evidence Auditor is called through an API adapter with a high-reasoning audit profile;
- board movement is visible;
- all tool calls and A2A messages are logged;
- final proof packaging happens from repo-backed evidence;
- user approval remains required for closure.

R17 should not produce fake multi-agent transcripts. Separate role execution must be backed by bounded request/response artifacts, tool-call logs, board events, and evidence refs.

---

## 19. Proposed R17 Milestone Plan

### 19.1 Goal

Implement a large but bounded productization milestone that converts R16 foundations into exercised workflow infrastructure:

1. governed board/card/event state;
2. Kanban interface MVP;
3. Orchestrator identity, authority, and loop state machine;
4. agent registry and scoped memory loader;
5. Developer/Codex executor adapter;
6. QA/Test Agent adapter;
7. Evidence Auditor API adapter;
8. A2A message protocol and dispatcher;
9. tool-call ledger and agent invocation log;
10. stop/retry/re-entry controls;
11. API secret/cost/runaway-loop controls;
12. four complete A2A cycles;
13. R17 final report, KPI movement package, and final proof/review package.

The outcome should be perceived by the operator: a task can be submitted to the Orchestrator, watched on the board, delegated to the agent team, audited, and packaged without normal-path prompt shuttling.

### 19.2 Hard non-claims

R17 must not claim:

- production runtime;
- production QA;
- full product QA;
- productized UI beyond the exercised R17 interface;
- broad autonomous agents;
- unsupervised autonomy;
- true multi-agent execution unless evidenced by separate bounded invocations and logs;
- persistent memory engine beyond explicit scoped memory loading;
- retrieval/vector runtime unless implemented and audited;
- external board canonical truth;
- GitHub Projects integration unless implemented;
- Linear integration unless implemented;
- Symphony integration unless implemented;
- custom board production runtime unless implemented;
- solved Codex compaction;
- solved Codex reliability;
- no-manual-burden operation unless measured friction evidence supports it;
- main merge;
- R18 opening;
- R13 closure;
- R14 caveat removal;
- R15 caveat removal;
- external audit acceptance unless run IDs, request/response artifacts, observed head/tree, and verdict are recorded.

### 19.3 Meaningful-impact acceptance gates

R17 should not be accepted if it only produces more governance documents. At closeout, the following gates must be evaluated fail-closed.

| Gate | Minimum acceptance bar | Fail condition |
| --- | --- | --- |
| No-copy/paste operator gate | Happy-path Dev/Codex delegation occurs through Orchestrator and executor adapter without manual GPT-to-Codex prompt transfer. | Operator still hand-builds and pastes Codex prompts in the normal path. |
| Kanban surface gate | Operator can see card lane, active agent, output, blocker, evidence refs, and next action. | Board state exists only as Markdown or hidden JSON. |
| Board state gate | Cards, events, transitions, and replay validate from committed state. | Card movement cannot be replayed or audited. |
| Orchestrator gate | Orchestrator creates cards, routes work, invokes adapters, updates board events, and requests decisions. | Orchestrator is only a persona or narrative description. |
| Developer/Codex adapter gate | Adapter receives scoped task packet and captures output/diff/status. | Dev work occurs outside governed adapter. |
| QA/Test Agent gate | QA adapter receives criteria, runs approved validations, returns result or defect packet, and does not implement. | QA implementation or unsupported pass/fail. |
| Evidence Auditor API gate | Audit adapter creates request/response/verdict artifacts with safety/cost metadata. | Audit remains narrative or hidden API call. |
| Four A2A cycles gate | Four complete cycles run with A2A messages, board events, tool ledger, and evidence refs. | Simulated transcript is used as execution proof. |
| Stop/retry/re-entry gate | Failed/interrupted tool calls can stop, retry, block, or produce re-entry packet. | Runner can hang/run away or lose state. |
| Secret/cost gate | API keys are never committed; costs/retries/timeouts are bounded. | Secrets leak or cost/runaway risk is uncontrolled. |
| Final proof gate | R17 final report, KPI scorecard, evidence index, A2A summaries, final-head support packet, and validation manifest validate. | Closeout relies on chat memory or uncited claims. |

### 19.4 Proposed task sequence

R17 is intentionally larger than R16. It is split into phases so the milestone remains controllable while producing the required product shift.

#### Phase A — R16 audit closure and R17 opening

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-001 Produce R16 external audit and R17 planning report | Create the R16 audit/R17 planning artifact from the reporting standard and KPI model. | `governance/reports/AIOffice_V2_R16_External_Audit_and_R17_Planning_Report_v1.md`; validation manifest. | R16 accepted only with caveats; R17 recommended but not opened by report. |
| R17-002 Open R17 in repo truth after operator approval | Establish R17 branch, authority doc, status surfaces, decision log, and non-claims. | `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`; status updates; opening packet. | R17 active through R17-002 only; R13/R14/R15/R16 boundaries preserved. |
| R17-003 Add R17 KPI baseline and target scorecard | Convert R17 goals into machine-readable domain targets. | `contracts/governance/r17_kpi_baseline_target_scorecard.contract.json`; `state/governance/r17_kpi_baseline_target_scorecard.json`; validator/test. | Targets include no-copy/paste, live board, four A2A cycles, API audit, safety/cost controls. |

#### Phase B — Board and Kanban product surface

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-004 Define governed card contract | Define card fields, lanes, owner, current agent, packet refs, evidence refs, blockers, and user decision fields. | `contracts/board/r17_card.contract.json`; fixtures; validator/test. | Invalid/missing owner, stage, evidence refs, and transition data fail closed. |
| R17-005 Define board state and board event contracts | Define repo-backed state and event ledger shape. | `contracts/board/r17_board_state.contract.json`; `contracts/board/r17_board_event.contract.json`; fixtures; validator/test. | Board events can replay into board state deterministically. |
| R17-006 Implement board state store and event ledger | Create and update canonical board/card state. | `state/board/r17_board_state.json`; `state/board/r17_cards/*.json`; `state/board/r17_board_event_log.jsonl`; tools/tests. | Card creation, assignment, movement, blocker, and closure-request events validate. |
| R17-007 Build Kanban interface MVP | Make board state visible. | UI/control surface; UI smoke tests; screenshots or equivalent state artifacts. | Operator sees lanes: Intake, Define, Ready for Dev, In Dev, Ready for QA, In QA, Fix Required, Ready for Audit, In Audit, Ready for User Review, Resolved, Closed, Blocked. |
| R17-008 Add card detail evidence drawer | Make outputs inspectable without hunting files. | Card detail component; evidence drawer state; tests. | Card detail shows task packet, memory refs, Dev output, QA result, audit verdict, tool-call log, and evidence refs. |

#### Phase C — Orchestrator runtime

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-009 Define Orchestrator identity and authority contract | Make Orchestrator a real bounded role. | `contracts/agents/r17_orchestrator.contract.json`; `state/agents/r17_orchestrator_identity.json`; validator/test. | Orchestrator can create/route cards and invoke adapters; cannot close without user approval or bypass QA/audit. |
| R17-010 Implement Orchestrator loop state machine | Run the card through approved states. | `tools/R17OrchestratorLoop.*`; transition contract; state tests. | States validate: intake, define, ready_for_dev, dev_running, dev_done, qa_running, qa_failed, qa_passed, audit_running, audit_failed, audit_passed, ready_for_user_review, resolved, closed, blocked. |
| R17-011 Add operator interaction endpoint/surface | Let the operator submit work once. | CLI/UI/HTTP intake surface; intake packet; tests. | A single operator instruction creates a card and task packet. |

#### Phase D — Agent registry and scoped memory loader

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-012 Define agent registry and identity packets | Register all required agents and authority boundaries. | `contracts/agents/r17_agent_identity.contract.json`; `state/agents/r17_agent_registry.json`; validators/tests. | Orchestrator, PM, Architect, Developer/Codex, QA/Test, Evidence Auditor, Knowledge Curator, and Release/Closeout have identity/authority/tool/memory/output definitions. |
| R17-013 Implement R16 memory/artifact map loader for live agents | Use R16 scoped refs in packets. | Loader module; loaded-ref log; tests. | Agent packets load only approved memory/artifact refs; no broad repo scan in happy path. |
| R17-014 Define agent invocation log | Record every agent invocation. | `state/runtime/r17_agent_invocation_log.jsonl`; contract/validator/test. | Each invocation has timestamp, card ID, agent ID, input/output refs, status, and evidence ref. |

#### Phase E — Tool adapters and ledgers

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-015 Define common tool adapter contract | Standardize adapter input/output/status/cost metadata. | `contracts/tools/r17_tool_adapter.contract.json`; fixtures; validator/test. | Adapters fail closed on missing packet refs, unapproved tool, or missing output status. |
| R17-016 Implement Developer/Codex executor adapter | Replace manual prompt transfer. | `contracts/tools/r17_codex_executor_adapter.contract.json`; request/result packets; adapter module; mocked/live-safe tests. | Orchestrator sends bounded implementation packet and receives captured output/diff/status. |
| R17-017 Implement QA/Test Agent adapter | Put QA in-cycle. | `contracts/tools/r17_qa_test_agent_adapter.contract.json`; QA request/result/defect packets; adapter module; tests. | QA can pass/fail, open defects, request fixes, and cannot implement. |
| R17-018 Implement Evidence Auditor API adapter | Make release audit API-callable. | `contracts/tools/r17_evidence_auditor_api_adapter.contract.json`; audit request/response/verdict packets; cost/safety metadata; tests. | Auditor reviews evidence and non-claims; cannot merge, close, or rewrite evidence. |
| R17-019 Add tool-call ledger | Make adapter usage auditable. | `state/runtime/r17_tool_call_ledger.jsonl`; contract/validator/test. | Every adapter call records input packet, output packet, status, cost estimate if available, error/retry data, and evidence hash/ref. |

#### Phase F — A2A protocol and dispatcher

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-020 Define A2A message and handoff contracts | Make agent-to-agent communication explicit. | `contracts/a2a/r17_a2a_message.contract.json`; `contracts/a2a/r17_a2a_handoff.contract.json`; fixtures/tests. | Message types include task_assignment, clarification_request, implementation_result, qa_result, defect_report, fix_request, audit_request, audit_verdict, release_recommendation, user_decision_request. |
| R17-021 Implement A2A dispatcher | Route messages among agents/adapters. | Dispatcher module; message log; validators/tests. | Unauthorized handoffs fail closed; board events are written for dispatch/return. |
| R17-022 Add stop, retry, pause, block, and re-entry controls | Prevent runaway execution and support recovery. | Stop/retry module; re-entry packets; safety tests. | Failed/interrupted runs can stop, retry, block, or resume from packet; repeated failure requests user decision. |

#### Phase G — Four required agentic A2A cycles

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-023 Exercise Cycle 1: Orchestrator → PM/Architect → Board | Turn user intent into governed card and executable packet. | Card, PM packet, architecture packet, memory refs, board events. | User submits once; card appears; task packet ready for Dev without manual prompt construction. |
| R17-024 Exercise Cycle 2: Orchestrator → Developer/Codex → Board | Delegate implementation. | Executor request/result, diff/status artifact, tool ledger, board transitions. | Card moves Ready for Dev → In Dev → Ready for QA. |
| R17-025 Exercise Cycle 3: Orchestrator → QA/Test → Developer fix loop | Validate and route defects. | QA request/result, defect packet, fix request, updated Dev result, QA pass. | Card can move In QA → Fix Required → In Dev → Ready for QA → Ready for Audit. |
| R17-026 Exercise Cycle 4: Orchestrator → Evidence Auditor API → Release/Closeout | Audit the whole release. | Audit request/response, verdict, rejected claims, non-claims, release recommendation, user decision request. | Card moves Ready for Audit → In Audit → Ready for User Review; closure still requires user approval. |

#### Phase H — Observability, safety, external replay, and final package

| Task | Goal | Evidence deliverables | Acceptance criteria |
| --- | --- | --- | --- |
| R17-027 Add observability, friction metrics, secret/cost gates, and external replay path | Make the product safe and measurable. | Live agent activity panel; manual-friction metrics; secret/cost gates; external replay or blocked packet. | Operator sees active agent/tool/output; zero happy-path manual prompt transfers is measured; API keys are safe; external evidence path exists or is honestly blocked. |
| R17-028 Produce R17 final report, KPI movement package, and final proof/review package | Close the release. | Final report, KPI scorecard, evidence index, board event summary, A2A cycle summary, agent/tool-call indexes, final-head support packet, validation manifest. | Final validation passes; four cycles complete; non-claims preserved; no main merge/external-audit overclaim unless evidenced. |

### 19.5 Validation commands

Command names are proposed and should be made real as tasks are implemented.

```powershell
# Phase A: audit/opening/KPI
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_opening_authority.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_opening_authority.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kpi_baseline_target_scorecard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kpi_baseline_target_scorecard.ps1

# Phase B: board/Kanban
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_contracts.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_contracts.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_state.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_state.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kanban_interface.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_card_detail_evidence_drawer.ps1

# Phase C/D: Orchestrator, agents, memory loader
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_orchestrator_identity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_orchestrator_identity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_orchestrator_loop.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_orchestrator_loop.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_registry.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_registry.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_memory_loader.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_memory_loader.ps1

# Phase E: adapters/ledgers
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_codex_executor_adapter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_codex_executor_adapter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_qa_test_agent_adapter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_qa_test_agent_adapter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_call_ledger.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_call_ledger.ps1

# Phase F/G: A2A runtime and cycles
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_a2a_message_contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_message_contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_a2a_dispatcher.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_dispatcher.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_stop_retry_reentry_controls.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_cycle_1_definition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_cycle_2_dev_execution.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_cycle_3_qa_fix_loop.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_cycle_4_audit_closeout.ps1

# Phase H: safety, replay, final proof
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_secret_cost_safety_gate.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_secret_cost_safety_gate.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_friction_metrics.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_friction_metrics.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_external_replay_packet.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_external_replay_packet.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_final_proof_review_package.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_final_proof_review_package.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
```

### 19.6 Risk controls

| Risk | Control |
| --- | --- |
| Scope explosion into production runtime | Every task preserves non-claims; R17 accepts only exercised milestone surface. |
| Fake multi-agent narration | A2A proof requires separate request/response artifacts, invocation log, tool ledger, and board events. |
| Manual copy/paste remains hidden | Manual-friction metrics count prompt transfers; closeout fails if happy path requires GPT-to-Codex prompt transfer. |
| Orchestrator bypasses roles | Orchestrator contract forbids closure without user approval and forbids bypassing QA/audit gates. |
| Developer role drift | Developer/Codex adapter may modify implementation only inside packet; cannot approve evidence. |
| QA role drift | QA adapter cannot implement; it returns QA result or defect packet. |
| Auditor role drift | Evidence Auditor API cannot merge, close, or rewrite evidence. |
| Secret leakage | Secret gate rejects committed keys and requires environment/secret-store configuration. |
| Runaway API/tool loop | Max tool calls, retries, timeouts, and cost budgets fail closed. |
| Board state corruption | Event replay validates board state; invalid transitions fail closed. |
| External replay unavailable | Produce a blocked packet with reason rather than claiming external proof. |
| Context pressure | Card detail/evidence drawer must reference artifacts rather than dumping large JSON into chat. |

### 19.7 External audit requirements

R17 external/pro audit requires at least:

| Requirement | Required evidence |
| --- | --- |
| Final branch/head/tree | Commit SHA, tree SHA, branch SHA, clean status. |
| Board evidence | Board state, card artifacts, event ledger, replay result. |
| Orchestrator evidence | Intake packet, state transitions, routing decisions, user decision requests. |
| Agent evidence | Agent registry, identity packets, invocation log. |
| Tool evidence | Tool-call ledger, adapter request/response packets. |
| Dev/Codex evidence | Executor request, executor result, diff/status artifact. |
| QA evidence | QA request, result, defect/fix loop, final QA pass. |
| Auditor evidence | Evidence Auditor API request, response, verdict, cost/safety metadata. |
| A2A cycle evidence | Four cycle packages, message logs, board events, outputs. |
| Safety evidence | Secret gate, cost budget, stop/retry/re-entry tests. |
| KPI evidence | R17 KPI scorecard and manual-friction metrics. |
| Final proof | Evidence index, final proof/review package, validation manifest, final-head support packet. |

### 19.8 Claims R17 must reject unless separately evidenced

- complete product runtime;
- production readiness;
- production QA;
- full product QA;
- broad autonomous agents;
- solved Codex reliability;
- solved Codex compaction;
- external board canonical truth;
- main merge;
- external audit acceptance;
- hidden API audit as proof;
- R13 closure;
- R14/R15 caveat removal;
- R16 guard mitigation unless guard evidence changes;
- no-copy/paste success without measured prompt-transfer metric;
- A2A success without separate invocation artifacts.

---

## 20. Codex-Ready R17 Opening Prompt

```text
Open R17 for RodneyMuniz/AIOffice_V2 after explicit operator approval.

Milestone name:
R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle

Start from R16 final head:
5bae17229ea10dee4ce072b258f828220b9d1d8d

Do not restart R16.
Do not create R18.
Do not merge to main.
Do not open a PR unless explicitly instructed.
Do not reset hard.
Do not run git clean.
Do not discard local WIP.
Do not claim product runtime.
Do not claim production runtime.
Do not claim production QA.
Do not claim full product QA.
Do not claim external audit acceptance.
Do not claim solved Codex compaction.
Do not claim solved Codex reliability.
Do not close R13.
Do not remove R14 caveats.
Do not remove R15 caveats.
Do not treat generated reports as proof by themselves.
Do not accept fake multi-agent narration as execution proof.

R17 thesis:
R17 must convert R16's memory/artifact/context/role foundation into an exercised product loop. The operator interacts with the Orchestrator. The Orchestrator creates and moves board cards, delegates implementation to Developer/Codex through a bounded executor adapter, delegates validation to QA/Test Agent through a bounded QA adapter, calls Evidence Auditor through a bounded API audit adapter, records all A2A messages and tool calls, and exposes work movement through the Kanban surface.

R17 closeout must fail unless:
- the happy-path release cycle avoids manual GPT-to-Codex prompt transfer;
- the board visibly moves cards through the release cycle;
- Developer/Codex, QA/Test Agent, and Evidence Auditor API are invoked through bounded adapters;
- four complete A2A cycles are exercised and evidenced;
- every agent/tool call has request/response artifacts and logs;
- stop/retry/re-entry, secret, cost, and timeout controls exist;
- final report, KPI movement package, evidence index, and final proof/review package validate;
- user approval remains required for closure.

Initial R17 sequence:
1. Install R16 external audit and R17 planning report.
2. Open R17 authority/status surfaces.
3. Add R17 KPI baseline and target scorecard.
4. Define board/card/event contracts.
5. Implement board state store and event ledger.
6. Build Kanban interface MVP.
7. Define Orchestrator identity and state machine.
8. Define agent registry and scoped memory loader.
9. Implement Developer/Codex executor adapter.
10. Implement QA/Test Agent adapter.
11. Implement Evidence Auditor API adapter.
12. Define and exercise A2A protocol/dispatcher.
13. Run four A2A cycles.
14. Produce final report and proof package.
```
