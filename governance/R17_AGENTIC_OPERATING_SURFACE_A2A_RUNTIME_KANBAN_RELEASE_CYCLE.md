# R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle

**Milestone name:** R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle
**Branch:** `release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle`
**Starting head:** `5bae17229ea10dee4ce072b258f828220b9d1d8d`
**Starting tree:** `9de1a7b733f400da78f8e683ae4111977c70f1fb`
**Status after this pass:** Active through `R17-016` only.
**Current scope:** R17-001 through R17-003 establish authority, planning, KPI baseline, and repo-truth status; R17-004 defines governed card, board-state, and board-event contracts only; R17-005 implements bounded repo-backed board state store generation and deterministic event replay/check tooling only; R17-006 implements a read-only local/static Kanban MVP surface only using the R17-005 board state/replay artifacts; R17-007 implements a read-only card detail evidence drawer/panel only using the R17-005 board state/replay artifacts and R17-006 Kanban MVP snapshot/UI artifacts; R17-008 implements a read-only board event detail and evidence summary surface only using R17-005 board state/replay artifacts, R17-006 Kanban MVP snapshot/UI artifacts, and R17-007 card detail drawer artifacts; R17-009 defines the Orchestrator identity and authority contract only and creates generated Orchestrator identity/authority state, route recommendation seed, and authority check artifacts only; R17-010 defines and validates a bounded Orchestrator loop state machine, generated seed evaluation, and transition check artifacts only; R17-011 implements a bounded operator interaction/intake surface and deterministic intake packet/proposal generation only; R17-012 defines the R17 agent registry and role identity packet set only, creating generated agent registry, role identity packets, registry check report, and UI workforce snapshot only; R17-013 implements a bounded deterministic memory/artifact loader foundation only, creating generated memory/artifact loader report, loaded-ref log, future-use agent memory packets, and UI memory loader snapshot only; R17-014 defines the agent invocation log foundation only, creating seed/foundation invocation records only, a check report, and a read-only UI invocation log snapshot; R17-015 defines the common tool adapter contract foundation only, creating disabled seed adapter profiles, a check report, compact invalid fixtures, proof-review package, and a read-only UI tool adapter snapshot/panel only; and R17-016 creates a disabled packet-only Developer/Codex executor adapter foundation only, creating generated adapter contract, request/result packets, check report, compact invalid fixtures, proof-review package, and read-only UI Codex executor adapter snapshot/panel only.
**Planned-only boundary:** `R17-017` through `R17-028` remain planned only after this pass.

This authority document records the active R17 boundary after the completed R16 boundary. It does not implement the full R17 milestone.

## R16 Final Posture Summary

R16 is complete for the bounded foundation scope through `R16-026` only. R16 produced a bounded final proof/review package candidate and final-head support packet only. The R16 guard remained `failed_closed_over_budget` with final upper bound `1364079` and threshold `150000`.

R16 did not claim external audit acceptance, main merge, runtime execution, product runtime, autonomous agents, true multi-agent execution, external integrations, executable handoffs, executable transitions, solved Codex compaction, or solved Codex reliability. R13 remains failed/partial through `R13-018` only. R14 and R15 caveats remain preserved.

## R17 Thesis

R17 must convert the R16 memory, artifact, context, and role foundation into an exercised operator workflow. The operator talks to the Orchestrator; the Orchestrator creates and updates board cards; work is routed through bounded agent and adapter surfaces; QA and evidence audit happen in-cycle; and the Kanban/control-room surface shows cards moving, agents called, outputs, blockers, evidence, and release posture.

R17 must be ambitious but evidence-safe. R17 is not another governance-only milestone, but this opening pass is only the repo-truth start boundary.

## R17 Success Definition

R17 can close only after future tasks prove all closeout gates with committed evidence:

- visible board/card lifecycle;
- Orchestrator-controlled card creation and routing;
- Developer/Codex executor adapter;
- QA/Test Agent adapter;
- Evidence Auditor API adapter with a high-reasoning audit path;
- tool-call ledger;
- agent invocation log;
- stop, retry, pause, block, and re-entry controls;
- at least four exercised A2A cycles with request/response artifacts, board events, tool ledger entries, and evidence refs;
- zero manual GPT-to-Codex prompt transfer for the happy path by R17 closeout;
- final report, KPI movement package, evidence index, and final proof/review package;
- explicit user approval for closeout.

None of these planned capabilities are claimed as implemented by this opening pass.

## Phase Plan

| Phase | Scope | Task range | Status after this pass |
| --- | --- | --- | --- |
| Phase A | R16 audit/R17 planning installation, R17 opening, KPI baseline | `R17-001` through `R17-003` | Done |
| Phase B | Board and Kanban product surface | `R17-004` through `R17-008` | `R17-004` done as contracts only; `R17-005` done as bounded repo-backed state store/replay tooling only; `R17-006` done as a read-only local/static Kanban MVP surface only; `R17-007` done as a read-only card detail evidence drawer/panel only; `R17-008` done as a read-only board event detail and evidence summary surface only |
| Phase C | Orchestrator runtime | `R17-009` through `R17-011` | `R17-009` done as Orchestrator identity/authority contract and generated non-executable state-artifact proof only; `R17-010` done as bounded loop state-machine contract, generated non-executable seed evaluation, and transition check artifacts only; `R17-011` done as bounded operator intake preview and deterministic non-executable intake packet/proposal generation only |
| Phase D | Agent registry and scoped memory loader | `R17-012` through `R17-014` | `R17-012` done as agent registry and role identity packet model/generation only; `R17-013` done as bounded deterministic memory/artifact loader foundation only; `R17-014` done as agent invocation log foundation only with seed/foundation invocation records |
| Phase E | Tool adapters and ledgers | `R17-015` through `R17-019` | `R17-015` done as common tool adapter contract foundation only with disabled seed adapter profiles; `R17-016` done as disabled packet-only Developer/Codex executor adapter foundation only; `R17-017` through `R17-019` planned only |
| Phase F | A2A protocol and dispatcher | `R17-020` through `R17-022` | Planned only |
| Phase G | Four required agentic A2A cycles | `R17-023` through `R17-026` | Planned only |
| Phase H | Observability, safety, external replay path, final package | `R17-027` through `R17-028` | Planned only |

## Task List

### `R17-001` Install R16 external audit/R17 planning report and revised R17 release plan
- Status: done
- Order: 1
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `governance/reports/AIOffice_V2_R16_External_Audit_and_R17_Planning_Report_v1.md`, `governance/plans/AIOffice_V2_Revised_R17_Agentic_Operating_Surface_A2A_Runtime_Kanban_Release_Cycle_Plan_v1.md`, and `state/planning/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_001_planning_artifact_manifest.md`
- Done when: approved operator artifacts are installed without treating either report as implementation proof, external audit acceptance, main merge, product runtime, A2A runtime, or autonomous-agent proof.

### `R17-002` Open R17 in repo truth
- Status: done
- Order: 2
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: this authority document, status-surface updates, decision-log entry, and branch `release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle`
- Done when: R17 is active through `R17-003` only, `R17-004` through `R17-028` remain planned only, and R13/R14/R15/R16 boundaries are preserved.

### `R17-003` Add R17 KPI baseline and target scorecard
- Status: done
- Order: 3
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `state/governance/r17_kpi_baseline_target_scorecard.json`, `contracts/governance/r17_kpi_baseline_target_scorecard.contract.json`, `tools/validate_r17_kpi_baseline_target_scorecard.ps1`, and `tests/test_r17_kpi_baseline_target_scorecard.ps1`
- Done when: the scorecard uses the ten-domain KPI model, separates current R16-derived baseline posture from R17 targets, and does not count targets as achieved implementation evidence.

### `R17-004` Define governed card, board-state, and board-event contracts
- Status: done
- Order: 4
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/board/r17_card.contract.json`, `contracts/board/r17_board_state.contract.json`, `contracts/board/r17_board_event.contract.json`, `tools/R17BoardContracts.psm1`, `tools/validate_r17_board_contracts.ps1`, `tests/test_r17_board_contracts.ps1`, fixtures under `tests/fixtures/r17_board_contracts/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/`.
- Done when: governed card, board-state, and board-event contract shape and fixture behavior validate; invalid card ID, lane, owner role, acceptance criteria, evidence refs, closure approval, and unsupported claims fail closed; and no board state store, Kanban UI, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, or product runtime is implemented or claimed.

### `R17-005` Implement bounded board state store and deterministic event replay checks
- Status: done
- Order: 5
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `tools/R17BoardStateStore.psm1`, `tools/new_r17_board_state_store.ps1`, `tools/validate_r17_board_state_store.ps1`, `tests/test_r17_board_state_store.ps1`, fixtures under `tests/fixtures/r17_board_state_store/`, generated board state artifacts under `state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/`.
- Done when: the R17-005 seed card and seed events validate against the R17-004 contract shapes and R17-005 boundary rules, deterministic replay generates a board state artifact and replay report with verdict `generated_r17_board_state_store_candidate`, invalid event fixtures fail closed, closure still requires user approval, and no Kanban UI, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, or product runtime is implemented or claimed.

### `R17-006` Build Kanban interface MVP
- Status: done
- Order: 6
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `scripts/operator_wall/r17_kanban_mvp/`, `state/ui/r17_kanban_mvp/r17_kanban_snapshot.json`, `tools/R17KanbanMvp.psm1`, `tools/new_r17_kanban_mvp.ps1`, `tools/validate_r17_kanban_mvp.ps1`, `tests/test_r17_kanban_mvp.ps1`, fixtures under `tests/fixtures/r17_kanban_mvp/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_006_kanban_mvp/`.
- Done when: the operator can open the local/static read-only Kanban MVP and see the required R17 lanes, the R17-005 seed card in its replayed current lane, evidence refs, replay summary, user-decision state, and non-claims without treating R17-005 repo-backed state artifacts or the R17-006 UI as Kanban product runtime.

### `R17-007` Add card detail evidence drawer
- Status: done
- Order: 7
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json`, updated local/static Kanban MVP files under `scripts/operator_wall/r17_kanban_mvp/`, `tools/R17CardDetailDrawer.psm1`, `tools/new_r17_card_detail_drawer.ps1`, `tools/validate_r17_card_detail_drawer.ps1`, `tests/test_r17_card_detail_drawer.ps1`, fixtures under `tests/fixtures/r17_card_detail_drawer/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_007_card_detail_evidence_drawer/`.
- Done when: the operator can open the local/static Kanban MVP, select or inspect the R17-005 seed card, and see card identity, acceptance/QA criteria, memory refs, task packet ref, event history, evidence refs, user-decision state, non-claims, rejected claims, and explicit `not_implemented_in_r17_007` placeholders for Dev output, QA result, and audit verdict without claiming live board mutation, runtime agent execution, product runtime, or A2A runtime.

### `R17-008` Add board event detail and evidence summary surface
- Status: done
- Order: 8
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json`, updated local/static Kanban MVP files under `scripts/operator_wall/r17_kanban_mvp/`, `tools/R17EventEvidenceSummary.psm1`, `tools/new_r17_event_evidence_summary.ps1`, `tools/validate_r17_event_evidence_summary.ps1`, `tests/test_r17_event_evidence_summary.ps1`, fixtures under `tests/fixtures/r17_event_evidence_summary/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_008_event_evidence_summary/`.
- Done when: the operator can open the local/static Kanban MVP and inspect replay summary, event timeline, event-level evidence refs, validation refs, transition decisions, grouped evidence refs, missing/stale evidence summary, user-decision state, non-claims, rejected claims, and explicit `not_implemented_in_r17_008` placeholders for Dev output, QA result, and audit verdict without claiming live board mutation, runtime agent execution, product runtime, or A2A runtime.

### `R17-009` Define Orchestrator identity and authority contract
- Status: done
- Order: 9
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/agents/r17_orchestrator_identity_authority.contract.json`, `state/agents/r17_orchestrator_identity_authority.json`, `state/agents/r17_orchestrator_route_recommendation_seed.json`, `state/agents/r17_orchestrator_authority_check_report.json`, `tools/R17OrchestratorIdentityAuthority.psm1`, `tools/new_r17_orchestrator_identity_authority.ps1`, `tools/validate_r17_orchestrator_identity_authority.ps1`, `tests/test_r17_orchestrator_identity_authority.ps1`, fixtures under `tests/fixtures/r17_orchestrator_identity_authority/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_009_orchestrator_identity_authority/`.
- Done when: the Orchestrator identity and authority contract, generated identity/authority state, non-executable route recommendation seed, and authority check report validate; Orchestrator remains coordination/routing only; closure requires user approval; QA/audit bypass remains forbidden; and no Orchestrator runtime, live board mutation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed.

### `R17-010` Implement Orchestrator loop state machine
- Status: done
- Order: 10
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json`, `state/orchestration/r17_orchestrator_loop_state_machine.json`, `state/orchestration/r17_orchestrator_loop_seed_evaluation.json`, `state/orchestration/r17_orchestrator_loop_transition_check_report.json`, `tools/R17OrchestratorLoopStateMachine.psm1`, `tools/new_r17_orchestrator_loop_state_machine.ps1`, `tools/validate_r17_orchestrator_loop_state_machine.ps1`, `tests/test_r17_orchestrator_loop_state_machine.ps1`, fixtures under `tests/fixtures/r17_orchestrator_loop_state_machine/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_010_orchestrator_loop_state_machine/`.
- Done when: the bounded Orchestrator loop state machine contract, generated state-machine artifact, seed evaluation, and transition check report validate; required invalid transition/claim fixtures fail closed; current seed evaluation remains non-executable at `ready_for_user_review`; closure requires user approval; and no Orchestrator runtime, live board mutation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed.

### `R17-011` Add operator interaction endpoint/surface
- Status: done
- Order: 11
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/intake/r17_operator_intake.contract.json`, generated intake artifacts `state/intake/r17_operator_intake_seed_packet.json`, `state/intake/r17_orchestrator_intake_proposal.json`, `state/intake/r17_operator_intake_check_report.json`, UI snapshot `state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json`, updated local/static Kanban MVP files under `scripts/operator_wall/r17_kanban_mvp/`, `tools/R17OperatorIntakeSurface.psm1`, `tools/new_r17_operator_intake_surface.ps1`, `tools/validate_r17_operator_intake_surface.ps1`, `tests/test_r17_operator_intake_surface.ps1`, fixtures under `tests/fixtures/r17_operator_intake_surface/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_011_operator_interaction_surface/`.
- Done when: a seed operator request produces a governed operator-intake packet, non-executable Orchestrator intake proposal, check report, UI snapshot, and local/static intake preview panel while preserving no live Orchestrator runtime, no live board mutation, no runtime card creation, no A2A runtime, no adapters, no autonomous agents, no executable handoffs, no executable transitions, no external integrations, no production runtime, no product runtime, no real Dev output, no real QA result, and no real audit verdict.

### `R17-012` Define agent registry and identity packets
- Status: done
- Order: 12
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/agents/r17_agent_registry.contract.json`, `contracts/agents/r17_agent_identity_packet.contract.json`, `state/agents/r17_agent_registry.json`, identity packets under `state/agents/r17_agent_identities/`, `state/agents/r17_agent_registry_check_report.json`, `state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json`, updated local/static Kanban MVP files under `scripts/operator_wall/r17_kanban_mvp/`, `tools/R17AgentRegistry.psm1`, `tools/new_r17_agent_registry.ps1`, `tools/validate_r17_agent_registry.ps1`, `tests/test_r17_agent_registry.ps1`, fixtures under `tests/fixtures/r17_agent_registry/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_012_agent_registry_identity_packets/`.
- Done when: required agents have generated identity, authority, tool, memory, evidence, handoff, approval, and runtime false-flag boundaries; the registry check report validates the required agent set; the read-only workforce snapshot/UI panel shows the planned agents and authority boundaries; and no live agent runtime, A2A runtime, live Orchestrator runtime, live board mutation, runtime card creation, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed.

### `R17-013` Implement R16 memory/artifact map loader for live agents
- Status: done
- Order: 13
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/context/r17_memory_artifact_loader.contract.json`, `state/context/r17_memory_artifact_loader_report.json`, `state/context/r17_memory_loaded_refs_log.json`, future-use packets under `state/agents/r17_agent_memory_packets/`, UI snapshot `state/ui/r17_kanban_mvp/r17_memory_loader_snapshot.json`, updated local/static Kanban MVP memory loader panel under `scripts/operator_wall/r17_kanban_mvp/`, tooling `tools/R17MemoryArtifactLoader.psm1`, `tools/new_r17_memory_artifact_loader.ps1`, and `tools/validate_r17_memory_artifact_loader.ps1`, focused test `tests/test_r17_memory_artifact_loader.ps1`, compact fixtures under `tests/fixtures/r17_memory_artifact_loader/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_013_memory_artifact_loader/`.
- Done when: the deterministic loader validates exact repo-backed R17-012 and R16 refs, writes compact loaded-ref summaries and future-use agent memory packets without embedding full source file contents, rejects runtime memory/vector/live-agent claims, avoids broad repo scans in the happy path, and does not claim live agent runtime, A2A runtime, adapters, API calls, product runtime, production runtime, real Dev output, real QA result, or real audit verdict.

### `R17-014` Define agent invocation log
- Status: done
- Order: 14
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/runtime/r17_agent_invocation_log.contract.json`, `state/runtime/r17_agent_invocation_log.jsonl`, `state/runtime/r17_agent_invocation_log_check_report.json`, `state/ui/r17_kanban_mvp/r17_agent_invocation_log_snapshot.json`, updated local/static Kanban MVP invocation log panel under `scripts/operator_wall/r17_kanban_mvp/`, tooling `tools/R17AgentInvocationLog.psm1`, `tools/new_r17_agent_invocation_log.ps1`, and `tools/validate_r17_agent_invocation_log.ps1`, focused test `tests/test_r17_agent_invocation_log.ps1`, compact fixtures under `tests/fixtures/r17_agent_invocation_log/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_014_agent_invocation_log/`.
- Done when: the repo-backed invocation log contract, seed/foundation invocation records, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every seed record records card ID, known agent ID, input/output placeholders, memory packet ref, status, evidence refs, false runtime flags, non-claims, and rejected claims; and no live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, A2A messages, adapters, external API calls, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, product runtime, production runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed.

### `R17-015` Define common tool adapter contract
- Status: done
- Order: 15
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/tools/r17_tool_adapter.contract.json`, `state/tools/r17_tool_adapter_seed_profiles.json`, `state/tools/r17_tool_adapter_contract_check_report.json`, `state/ui/r17_kanban_mvp/r17_tool_adapter_contract_snapshot.json`, updated local/static Kanban MVP tool adapter contract panel under `scripts/operator_wall/r17_kanban_mvp/`, tooling `tools/R17ToolAdapterContract.psm1`, `tools/new_r17_tool_adapter_contract.ps1`, and `tools/validate_r17_tool_adapter_contract.ps1`, focused test `tests/test_r17_tool_adapter_contract.ps1`, compact fixtures under `tests/fixtures/r17_tool_adapter_contract/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_015_tool_adapter_contract/`.
- Done when: the common tool adapter contract foundation, disabled seed adapter profiles, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every seed profile records adapter ID/type, card ID, requested/target agent IDs, invocation/input/output/tool-call/board-event refs, evidence refs, authority refs, secret/cost/timeout/retry policies, status, error ref, false runtime flags, non-claims, and rejected claims; and no adapter runtime, tool-call runtime, live tool calls, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, external API calls, A2A runtime, A2A messages, live agent runtime, live Orchestrator runtime, board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, product runtime, production runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed.

### `R17-016` Create disabled Developer/Codex executor adapter foundation
- Status: done
- Order: 16
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/tools/r17_codex_executor_adapter.contract.json`, `state/tools/r17_codex_executor_adapter_request_packet.json`, `state/tools/r17_codex_executor_adapter_result_packet.json`, `state/tools/r17_codex_executor_adapter_check_report.json`, `state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json`, updated local/static Kanban MVP Codex executor adapter panel under `scripts/operator_wall/r17_kanban_mvp/`, tooling `tools/R17CodexExecutorAdapter.psm1`, `tools/new_r17_codex_executor_adapter.ps1`, and `tools/validate_r17_codex_executor_adapter.ps1`, focused test `tests/test_r17_codex_executor_adapter.ps1`, compact fixtures under `tests/fixtures/r17_codex_executor_adapter/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_016_codex_executor_adapter/`.
- Done when: the disabled packet-only Developer/Codex executor adapter foundation, request packet, result packet, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every packet preserves the R17-015 seed adapter profile link, R17-014 developer invocation seed ref, developer identity/memory refs, secret/cost/timeout/retry policies, false runtime flags, non-claims, and rejected claims; and no Codex invocation, adapter runtime, tool-call runtime, live tool calls, external API calls, A2A runtime, A2A messages, live agent runtime, live Orchestrator runtime, board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, product runtime, production runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed.

### `R17-017` Implement QA/Test Agent adapter
- Status: planned
- Order: 17
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future QA adapter contract, QA request/result/defect packets, adapter module, and tests.
- Done when: future evidence proves QA can pass, fail, open defects, request fixes, and cannot implement.

### `R17-018` Implement Evidence Auditor API adapter
- Status: planned
- Order: 18
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future audit adapter contract, request/response/verdict packets, cost/safety metadata, and tests.
- Done when: future evidence proves Auditor reviews evidence and non-claims while unable to merge, close, or rewrite evidence.

### `R17-019` Add tool-call ledger
- Status: planned
- Order: 19
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future ledger contract, validator, test, and ledger artifact.
- Done when: future evidence proves every adapter call records input packet, output packet, status, cost estimate if available, error/retry data, and evidence hash/ref.

### `R17-020` Define A2A message and handoff contracts
- Status: planned
- Order: 20
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future A2A message and handoff contracts, fixtures, and tests.
- Done when: future evidence proves required message types validate.

### `R17-021` Implement A2A dispatcher
- Status: planned
- Order: 21
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future dispatcher module, message log, validators, and tests.
- Done when: future evidence proves unauthorized handoffs fail closed and board events are written for dispatch and return.

### `R17-022` Add stop, retry, pause, block, and re-entry controls
- Status: planned
- Order: 22
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future stop/retry module, re-entry packets, and safety tests.
- Done when: future evidence proves failed or interrupted runs can stop, retry, block, or resume from packet, with repeated failure requiring user decision.

### `R17-023` Exercise Cycle 1: Orchestrator to PM/Architect to Board
- Status: planned
- Order: 23
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future card, PM packet, architecture packet, memory refs, and board events.
- Done when: future evidence proves the user submits once, a card appears, and a task packet becomes ready for Dev without manual prompt construction.

### `R17-024` Exercise Cycle 2: Orchestrator to Developer/Codex to Board
- Status: planned
- Order: 24
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future executor request/result, diff/status artifact, tool ledger, and board transitions.
- Done when: future evidence proves card movement from Ready for Dev to In Dev to Ready for QA.

### `R17-025` Exercise Cycle 3: Orchestrator to QA/Test to Developer fix loop
- Status: planned
- Order: 25
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future QA request/result, defect packet, fix request, updated Dev result, and QA pass.
- Done when: future evidence proves card movement through In QA, Fix Required, In Dev, Ready for QA, and Ready for Audit.

### `R17-026` Exercise Cycle 4: Orchestrator to Evidence Auditor API to Release/Closeout
- Status: planned
- Order: 26
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future audit request/response, verdict, rejected claims, non-claims, release recommendation, and user decision request.
- Done when: future evidence proves card movement through Ready for Audit, In Audit, and Ready for User Review; closure still requires user approval.

### `R17-027` Add observability, friction metrics, secret/cost gates, and external replay path
- Status: planned
- Order: 27
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future live agent activity panel, manual-friction metrics, secret/cost gates, and external replay or blocked packet.
- Done when: future evidence proves the operator sees active agent/tool/output, zero happy-path manual prompt transfers are measured, API keys are safe, and an external evidence path exists or is honestly blocked.

### `R17-028` Produce R17 final report, KPI movement package, and final proof/review package
- Status: planned
- Order: 28
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: planned only; expected future final report, KPI scorecard, evidence index, board event summary, A2A cycle summary, agent/tool-call indexes, final-head support packet, and validation manifest.
- Done when: future final validation passes, four cycles complete, non-claims are preserved, and no main-merge or external-audit overclaim is made unless evidenced.

## Acceptance Gates

R17 closeout must fail closed unless future committed evidence satisfies:

- no-copy/paste operator gate;
- Kanban surface gate;
- board state replay gate;
- Orchestrator gate;
- Developer/Codex adapter gate;
- QA/Test Agent gate;
- Evidence Auditor API gate;
- four A2A cycles gate;
- stop/retry/re-entry gate;
- secret/cost gate;
- final proof gate.

## Four Required A2A Cycles

The four required future A2A cycles are:

1. `R17-023`: Orchestrator to PM/Architect to Board.
2. `R17-024`: Orchestrator to Developer/Codex to Board.
3. `R17-025`: Orchestrator to QA/Test to Developer fix loop.
4. `R17-026`: Orchestrator to Evidence Auditor API to Release/Closeout.

These cycles are not working yet and are not claimed by `R17-001` through `R17-016`.

## KPI Target Domains

R17 uses the ten weighted KPI domains in `governance/KPI_DOMAIN_MODEL.md`, with particular target pressure on:

- Product Experience & Double-Diamond Workflow;
- Board & Work Orchestration;
- Agent Workforce & RACI;
- Knowledge, Memory & Context Compression;
- Execution Harness & QA;
- Architecture & Integrations;
- Security, Safety & Cost Controls.

The machine-readable baseline/target scorecard is `state/governance/r17_kpi_baseline_target_scorecard.json`. Its target scores are future closeout requirements, not current achieved scores.

## Non-Claims

This R17 active boundary through `R17-016` claims none of the following:

- no external audit acceptance;
- no live board mutation;
- no runtime card creation;
- no live agent runtime;
- no main merge;
- no R13 closure;
- no R14 caveat removal;
- no R15 caveat removal;
- no R16 overclaim;
- no solved Codex compaction;
- no solved Codex reliability;
- no product runtime yet;
- no production runtime;
- no autonomous agents yet;
- no true multi-agent execution yet;
- no A2A runtime yet;
- no executable handoffs yet;
- no executable transitions yet;
- no runtime memory engine;
- no vector retrieval runtime;
- no Codex invocation;
- no Evidence Auditor API runtime yet;
- no Dev/Codex executor adapter runtime yet;
- no QA/Test Agent adapter runtime yet;
- no Kanban product runtime yet;
- no real Dev output;
- no real QA result;
- no real audit verdict;
- no R17-017 or later implementation yet;
- no Kanban runtime yet;
- no Orchestrator runtime yet;
- no R18 opening.

## Rejected Claims

The following claims are rejected unless future committed evidence and user approval change repo truth:

- the R16 report alone opens or proves R17;
- the revised R17 plan alone implements R17 capability;
- R17-017 through R17-028 are implemented by this pass;
- R17-016 implements adapter runtime, tool-call runtime, live tool calls, live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, A2A messages, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, external API calls, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-015 implements adapter runtime, tool-call runtime, live tool calls, live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, A2A messages, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, external API calls, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-014 implements live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, A2A messages, adapters, external API calls, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-012 implements live agent runtime, A2A runtime, live Orchestrator runtime, live board mutation, runtime card creation, Dev/Codex executor adapter, QA/Test Agent adapter, Evidence Auditor API adapter, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-011 implements live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-010 implements Orchestrator runtime, live board mutation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-009 implements Orchestrator runtime, live board mutation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-008 implements live board mutation, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-007 implements live board mutation, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict;
- R17-006 implements live board mutation, Kanban product runtime, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, or product runtime;
- R17-004 implements board state store, Kanban UI, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, or product runtime;
- R17-005 implements Kanban UI, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, or product runtime;
- R17 A2A cycles are working;
- Dev/Codex adapter is working;
- QA/Test Agent adapter is working;
- Evidence Auditor API adapter is working;
- Kanban product runtime is working;
- external audit acceptance occurred;
- main was merged;
- R13 is closed;
- R14 or R15 caveats are removed;
- Codex compaction or reliability is solved;
- product runtime, production runtime, autonomous agents, or true multi-agent execution exists.

## Required Reporting Standard References

All future R17 milestone reports must follow:

- `governance/MILESTONE_REPORTING_STANDARD.md`;
- `governance/KPI_DOMAIN_MODEL.md`;
- `governance/templates/AIOffice_Milestone_Report_Template_v2.md`;
- `governance/VISION.md`;
- this R17 authority document;
- the approved planning artifacts installed by `R17-001`.

Reports must include TL;DR, what changed since last report, the ten-domain KPI scorecard, domain drill-down, RACI/role enforcement review, and evidence appendix with commits, files, commands, external runs, artifacts, non-claims, and rejected claims.

## User Approval Requirement For Closeout

R17 cannot close without explicit user approval after future evidence proves the required gates. The Release/Closeout Agent, Orchestrator, Developer/Codex adapter, QA/Test Agent adapter, and Evidence Auditor API adapter cannot close R17 on their own.
