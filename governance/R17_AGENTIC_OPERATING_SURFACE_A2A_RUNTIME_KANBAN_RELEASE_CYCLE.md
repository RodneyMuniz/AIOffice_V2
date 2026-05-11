# R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle

**Milestone name:** R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle
**Branch:** `release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle`
**Starting head:** `5bae17229ea10dee4ce072b258f828220b9d1d8d`
**Starting tree:** `9de1a7b733f400da78f8e683ae4111977c70f1fb`
**Status after this pass:** Active through `R17-027` only.
**Current scope:** R17-001 through R17-003 establish authority, planning, KPI baseline, and repo-truth status; R17-004 defines governed card, board-state, and board-event contracts only; R17-005 implements bounded repo-backed board state store generation and deterministic event replay/check tooling only; R17-006 implements a read-only local/static Kanban MVP surface only using the R17-005 board state/replay artifacts; R17-007 implements a read-only card detail evidence drawer/panel only using the R17-005 board state/replay artifacts and R17-006 Kanban MVP snapshot/UI artifacts; R17-008 implements a read-only board event detail and evidence summary surface only using R17-005 board state/replay artifacts, R17-006 Kanban MVP snapshot/UI artifacts, and R17-007 card detail drawer artifacts; R17-009 defines the Orchestrator identity and authority contract only and creates generated Orchestrator identity/authority state, route recommendation seed, and authority check artifacts only; R17-010 defines and validates a bounded Orchestrator loop state machine, generated seed evaluation, and transition check artifacts only; R17-011 implements a bounded operator interaction/intake surface and deterministic intake packet/proposal generation only; R17-012 defines the R17 agent registry and role identity packet set only, creating generated agent registry, role identity packets, registry check report, and UI workforce snapshot only; R17-013 implements a bounded deterministic memory/artifact loader foundation only, creating generated memory/artifact loader report, loaded-ref log, future-use agent memory packets, and UI memory loader snapshot only; R17-014 defines the agent invocation log foundation only, creating seed/foundation invocation records only, a check report, and a read-only UI invocation log snapshot; R17-015 defines the common tool adapter contract foundation only, creating disabled seed adapter profiles, a check report, compact invalid fixtures, proof-review package, and a read-only UI tool adapter snapshot/panel only; R17-016 creates a disabled packet-only Developer/Codex executor adapter foundation only, creating generated adapter contract, request/result packets, check report, compact invalid fixtures, proof-review package, and read-only UI Codex executor adapter snapshot/panel only; R17-017 creates a disabled seed QA/Test Agent adapter foundation only, creating generated adapter contract, request/result/defect packets, check report, compact invalid fixtures, proof-review package, and read-only UI QA/Test Agent adapter snapshot/panel only; R17-018 creates a disabled seed Evidence Auditor API adapter foundation only, creating generated adapter contract, request/response/verdict packets, check report, compact invalid fixtures, proof-review package, and read-only UI Evidence Auditor API adapter snapshot/panel only; R17-019 creates a disabled/not-executed tool-call ledger foundation only, creating generated ledger contract, JSONL ledger seed records, check report, compact invalid fixtures, proof-review package, and read-only UI tool-call ledger snapshot only; R17-020 defines A2A message and handoff contracts only, creating generated A2A message and handoff contracts, disabled/not-dispatched seed packets, check report, compact invalid fixtures, proof-review package, and read-only UI A2A contracts snapshot only; R17-021 creates a bounded A2A dispatcher foundation only, consuming committed R17-020 seed A2A packets, validating deterministic route candidates, writing not-executed dispatch logs/check artifacts, compact invalid fixtures, a proof-review package, and a read-only UI dispatcher snapshot only; R17-022 creates a bounded stop, retry, pause, block, and re-entry controls foundation only, creating deterministic control/re-entry packet candidates, check report, compact invalid fixtures, proof-review package, and read-only UI controls snapshot only; R17-023 creates a repo-backed exercised Cycle 1 definition package only, creating deterministic packet-only PM/Architect definition packets, scoped memory/artifact refs, A2A packet candidates, dispatch/control refs, board event evidence, a read-only UI snapshot, proof-review package, and ready-for-dev packet only; R17-024 creates a repo-backed Cycle 2 Developer/Codex execution package only, capturing a Developer/Codex request/result packet, dev diff/status summary, packet-only A2A/dispatch/control/invocation/tool-call refs, deterministic board event evidence, a read-only UI snapshot, proof-review package, and card movement to Ready for QA as deterministic repo-backed board evidence only; R17-025 creates a compact-safe local execution harness foundation only through `contracts/runtime/r17_compact_safe_execution_harness.contract.json`, generated state artifacts under `state/runtime/r17_compact_safe_execution_harness_*`, prompt packet examples under `state/runtime/r17_compact_safe_execution_harness_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json`, tooling, tests, fixtures, and proof-review package; R17-026 creates a compact-safe harness pilot only through `contracts/runtime/r17_compact_safe_harness_pilot.contract.json`, generated Cycle 3 pilot state artifacts under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_*`, prompt packets under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json`, tooling, tests, fixtures, and proof-review package; and R17-027 creates an automated recovery-loop foundation only through `contracts/runtime/r17_automated_recovery_loop.contract.json`, generated recovery state artifacts under `state/runtime/r17_automated_recovery_loop_*`, prompt packets under `state/runtime/r17_automated_recovery_loop_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json`, tooling, tests, fixtures, and proof-review package.
**Planned-only boundary:** `R17-028` remains planned only after this pass.

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
| Phase E | Tool adapters and ledgers | `R17-015` through `R17-019` | `R17-015` done as common tool adapter contract foundation only with disabled seed adapter profiles; `R17-016` done as disabled packet-only Developer/Codex executor adapter foundation only; `R17-017` done as disabled seed QA/Test Agent adapter foundation only; `R17-018` done as disabled seed Evidence Auditor API adapter foundation only; `R17-019` done as disabled/not-executed tool-call ledger foundation only |
| Phase F | A2A protocol and dispatcher | `R17-020` through `R17-022` | `R17-020` done as A2A message and handoff contract foundation only with disabled/not-dispatched seed packets; `R17-021` done as a bounded seed-packet dispatcher foundation only with not-executed dispatch records; `R17-022` done as a bounded stop/retry/re-entry controls foundation only with packet-only controls |
| Phase G | Four required agentic A2A cycles and compact-safe execution harness pivot | `R17-023` through `R17-026` | `R17-023` done as a repo-backed packet-only Cycle 1 definition package; `R17-024` done as a repo-backed packet-only Cycle 2 Developer/Codex execution package; `R17-025` done as a compact-safe local execution harness foundation after compaction failures blocked safe continuation of the planned QA/fix-loop package; `R17-026` done as a compact-safe harness pilot that splits the future Cycle 3 QA/fix-loop into small work orders and prompt packets without executing the full QA/fix-loop |
| Phase H | Recovery-loop foundation and final package | `R17-027` through `R17-028` | `R17-027` done as an automated recovery-loop foundation only; `R17-028` planned only |

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
- Status: done
- Order: 17
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-016`
- Durable output: `contracts/tools/r17_qa_test_agent_adapter.contract.json`, `state/tools/r17_qa_test_agent_adapter_request_packet.json`, `state/tools/r17_qa_test_agent_adapter_result_packet.json`, `state/tools/r17_qa_test_agent_adapter_defect_packet.json`, `state/tools/r17_qa_test_agent_adapter_check_report.json`, `state/ui/r17_kanban_mvp/r17_qa_test_agent_adapter_snapshot.json`, updated local/static Kanban MVP QA/Test Agent adapter panel under `scripts/operator_wall/r17_kanban_mvp/`, tooling `tools/R17QaTestAgentAdapter.psm1`, `tools/new_r17_qa_test_agent_adapter.ps1`, and `tools/validate_r17_qa_test_agent_adapter.ps1`, focused test `tests/test_r17_qa_test_agent_adapter.ps1`, compact fixtures under `tests/fixtures/r17_qa_test_agent_adapter/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_017_qa_test_agent_adapter/`.
- Done when: the disabled seed QA/Test Agent adapter foundation, request packet, result packet, defect packet, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every packet preserves the R17-015 seed adapter profile link, R17-014 QA invocation seed ref, QA identity/memory refs, R17-016 Codex result packet ref, acceptance criteria refs, validation command refs, secret/cost/timeout/retry policies, false runtime flags, non-claims, and rejected claims; and no QA/Test Agent invocation, real QA execution, validation execution through a live adapter, defect opening runtime, fix request runtime, adapter runtime, tool-call runtime, live tool calls, external API calls, Codex executor invocation, Evidence Auditor API invocation, A2A runtime, A2A messages, live agent runtime, live Orchestrator runtime, board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, product runtime, production runtime, real Dev output, real QA result without committed validation evidence, or real audit verdict is implemented or claimed.
### `R17-018` Implement Evidence Auditor API adapter
- Status: done
- Order: 18
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-017`
- Durable output: `contracts/tools/r17_evidence_auditor_api_adapter.contract.json`, `state/tools/r17_evidence_auditor_api_adapter_request_packet.json`, `state/tools/r17_evidence_auditor_api_adapter_response_packet.json`, `state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json`, `state/tools/r17_evidence_auditor_api_adapter_check_report.json`, `state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json`, updated local/static Kanban MVP Evidence Auditor API adapter panel under `scripts/operator_wall/r17_kanban_mvp/`, tooling `tools/R17EvidenceAuditorApiAdapter.psm1`, `tools/new_r17_evidence_auditor_api_adapter.ps1`, and `tools/validate_r17_evidence_auditor_api_adapter.ps1`, focused test `tests/test_r17_evidence_auditor_api_adapter.ps1`, compact fixtures under `tests/fixtures/r17_evidence_auditor_api_adapter/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_018_evidence_auditor_api_adapter/`.
- Done when: the disabled seed Evidence Auditor API adapter foundation, audit request packet, response placeholder packet, verdict placeholder packet, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every packet preserves the R17-015 seed adapter profile link, R17-014 Evidence Auditor invocation seed ref, Evidence Auditor identity/memory refs, R17-016 Codex result packet ref, R17-017 QA result packet ref, acceptance criteria refs, validation command refs, secret/cost/timeout/retry policies, explicit false runtime flags, non-claims, and rejected claims; and no Evidence Auditor API invocation, external API call, real audit verdict, external audit acceptance, adapter runtime, tool-call runtime, live tool calls, A2A runtime, A2A messages, live agent runtime, live Orchestrator runtime, board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, product runtime, production runtime, main merge, or R17-020 or later completion claim is implemented or claimed.

### `R17-019` Add tool-call ledger
- Status: done
- Order: 19
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-018`
- Durable output: `contracts/runtime/r17_tool_call_ledger.contract.json`, `state/runtime/r17_tool_call_ledger.jsonl`, `state/runtime/r17_tool_call_ledger_check_report.json`, `state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json`, tooling `tools/R17ToolCallLedger.psm1`, `tools/new_r17_tool_call_ledger.ps1`, and `tools/validate_r17_tool_call_ledger.ps1`, focused test `tests/test_r17_tool_call_ledger.ps1`, compact fixtures under `tests/fixtures/r17_tool_call_ledger/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/`.
- Done when: the disabled/not-executed tool-call ledger foundation, contract, JSONL seed records, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every record preserves the R17-014 invocation log refs, R17-015 seed adapter profile links, R17-016 Developer/Codex packet refs, R17-017 QA/Test packet refs, R17-018 Evidence Auditor API packet refs, agent registry refs, memory packet refs, board/orchestration refs, secret/cost/timeout/retry policies, explicit false runtime flags, non-claims, and rejected claims; and no tool-call runtime, ledger runtime, actual tool call, adapter runtime invocation, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, external API call, A2A message, board mutation, runtime card creation, autonomous agents, product runtime, production runtime, real audit verdict, external audit acceptance, main merge, or R17-020 or later completion claim is implemented or claimed.

### `R17-020` Define A2A message and handoff contracts
- Status: done
- Order: 20
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-019`
- Durable output: `contracts/a2a/r17_a2a_message.contract.json`, `contracts/a2a/r17_a2a_handoff.contract.json`, `state/a2a/r17_a2a_message_seed_packets.json`, `state/a2a/r17_a2a_handoff_seed_packets.json`, `state/a2a/r17_a2a_contract_check_report.json`, `state/ui/r17_kanban_mvp/r17_a2a_contracts_snapshot.json`, tooling `tools/R17A2aContracts.psm1`, `tools/new_r17_a2a_contracts.ps1`, and `tools/validate_r17_a2a_contracts.ps1`, focused test `tests/test_r17_a2a_contracts.ps1`, compact fixtures under `tests/fixtures/r17_a2a_contracts/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_020_a2a_contracts/`.
- Done when: the generated A2A message and handoff contracts, disabled/not-dispatched seed packets, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every packet preserves registry-bound agent IDs, correlation/card IDs, evidence/authority refs, memory packet refs, invocation/tool-call/board refs, explicit false runtime flags, non-claims, and rejected claims; and no A2A runtime, dispatcher, message sending, message dispatch, agent invocation, adapter runtime, actual tool call, external API call, board mutation, runtime card creation, QA result, real audit verdict, external audit acceptance, main merge, or R17-021 or later completion claim is implemented or claimed.

### `R17-021` Implement A2A dispatcher
- Status: done
- Order: 21
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-020`
- Durable output: `contracts/a2a/r17_a2a_dispatcher.contract.json`, `state/a2a/r17_a2a_dispatcher_routes.json`, `state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl`, `state/a2a/r17_a2a_dispatcher_check_report.json`, `state/ui/r17_kanban_mvp/r17_a2a_dispatcher_snapshot.json`, tooling `tools/R17A2aDispatcher.psm1`, `tools/new_r17_a2a_dispatcher.ps1`, and `tools/validate_r17_a2a_dispatcher.ps1`, focused test `tests/test_r17_a2a_dispatcher.ps1`, compact fixtures under `tests/fixtures/r17_a2a_dispatcher/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_021_a2a_dispatcher/`.
- Done when: the bounded dispatcher foundation validates committed R17-020 seed message/handoff packets, produces deterministic route candidates and not-executed dispatch log entries, rejects unauthorized handoffs and unsafe runtime/future-task claims with compact invalid fixtures, preserves exact repo-relative refs, and does not send A2A messages, invoke live agents, invoke Orchestrator runtime, invoke adapters, perform tool/API calls, mutate the board, create runtime cards, claim QA/audit results, claim external audit acceptance, claim main merge, or complete R17-022 or later.

### `R17-022` Add stop, retry, pause, block, and re-entry controls
- Status: done
- Order: 22
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/runtime/r17_stop_retry_reentry_controls.contract.json`, `state/runtime/r17_stop_retry_reentry_control_packets.json`, `state/runtime/r17_stop_retry_reentry_reentry_packets.json`, `state/runtime/r17_stop_retry_reentry_check_report.json`, `state/ui/r17_kanban_mvp/r17_stop_retry_reentry_controls_snapshot.json`, tooling `tools/R17StopRetryReentryControls.psm1`, `tools/new_r17_stop_retry_reentry_controls.ps1`, and `tools/validate_r17_stop_retry_reentry_controls.ps1`, focused test `tests/test_r17_stop_retry_reentry_controls.ps1`, compact fixtures under `tests/fixtures/r17_stop_retry_reentry_controls/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_022_stop_retry_reentry_controls/`.
- Done when: the bounded control foundation validates committed R17-021 dispatcher artifacts, produces deterministic stop/retry/pause/block/re-entry control packets and re-entry packets, rejects unsupported actions and unsafe runtime/future-task claims with compact invalid fixtures, preserves exact repo-relative refs, and does not perform live stop, retry, pause, block, re-entry, A2A dispatch, agent invocation, Orchestrator runtime, adapter runtime, tool/API calls, board mutation, QA result, audit verdict, external audit acceptance, main merge, or complete R17-023 or later.

### `R17-023` Exercise Cycle 1: Orchestrator to PM/Architect to Board
- Status: done
- Order: 23
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/cycles/r17_cycle_1_definition.contract.json`, generated cycle state under `state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/`, cycle-specific board card/event/snapshot artifacts, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_cycle_1_definition_snapshot.json`, tooling `tools/R17Cycle1Definition.psm1`, `tools/new_r17_cycle_1_definition.ps1`, and `tools/validate_r17_cycle_1_definition.ps1`, focused test `tests/test_r17_cycle_1_definition.ps1`, compact fixtures under `tests/fixtures/r17_cycle_1_definition/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/`.
- Done when: the repo-backed exercised Cycle 1 definition package validates one bounded operator intent converted into a governed card snapshot, deterministic packet-only PM/Architect definitions, scoped memory/artifact refs, A2A packet candidates, dispatch/control refs, board event evidence, read-only UI snapshot, and ready-for-dev packet only without live cycle runtime, live Orchestrator runtime, live PM/Architect invocation, live A2A runtime, live A2A messages, adapter runtime, actual tool calls, external API calls, live board mutation, Codex executor invocation, Dev output, QA result, real audit verdict, external audit acceptance, autonomous agents, product runtime, main merge, or R17-024 or later completion claim.

### `R17-024` Exercise Cycle 2: Orchestrator to Developer/Codex to Board
- Status: done
- Order: 24
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/cycles/r17_cycle_2_dev_execution.contract.json`, generated cycle state under `state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution/`, cycle-specific board card/event/snapshot artifacts, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_cycle_2_dev_execution_snapshot.json`, tooling `tools/R17Cycle2DevExecution.psm1`, `tools/new_r17_cycle_2_dev_execution.ps1`, and `tools/validate_r17_cycle_2_dev_execution.ps1`, focused test `tests/test_r17_cycle_2_dev_execution.ps1`, compact fixtures under `tests/fixtures/r17_cycle_2_dev_execution/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution/`.
- Done when: the repo-backed Cycle 2 Developer/Codex execution package validates the R17-023 ready-for-dev packet transformed into a Developer/Codex request/result packet, dev diff/status summary, packet-only A2A/handoff/dispatch/control/invocation/tool-call refs, deterministic board event evidence, read-only UI snapshot, and card movement to Ready for QA as deterministic repo-backed board evidence only without live cycle runtime, live Orchestrator runtime, live Developer/Codex adapter invocation, autonomous Codex invocation by product runtime, live A2A runtime, live A2A messages, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, QA result, real audit verdict, external audit acceptance, autonomous agents, product runtime, main merge, no-manual-prompt-transfer success claim, or R17-025 or later completion claim.

### `R17-025` Compact-Safe Local Execution Harness Foundation
- Status: done
- Order: 25
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/runtime/r17_compact_safe_execution_harness.contract.json`, `tools/R17CompactSafeExecutionHarness.psm1`, `tools/new_r17_compact_safe_execution_harness.ps1`, `tools/validate_r17_compact_safe_execution_harness.ps1`, generated harness state under `state/runtime/r17_compact_safe_execution_harness_*`, prompt packet examples under `state/runtime/r17_compact_safe_execution_harness_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json`, focused test `tests/test_r17_compact_safe_execution_harness.ps1`, compact fixtures under `tests/fixtures/r17_compact_safe_execution_harness/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_025_compact_safe_execution_harness/`.
- Done when: the compact-safe local execution harness foundation validates a resumable work-order model, five small prompt packet examples, resume-after-compact model, stage/commit/push step model, compact invalid fixtures, and preserved non-claims without live execution harness runtime, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, no-manual-prompt-transfer success claim, solved Codex compaction/reliability claim, or R17-026 or later completion claim.

### `R17-026` Compact-Safe Harness Pilot for Cycle 3 QA/fix-loop
- Status: done
- Order: 26
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/runtime/r17_compact_safe_harness_pilot.contract.json`, `tools/R17CompactSafeHarnessPilot.psm1`, `tools/new_r17_compact_safe_harness_pilot.ps1`, `tools/validate_r17_compact_safe_harness_pilot.ps1`, generated Cycle 3 pilot state under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_*`, prompt packets under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json`, focused test `tests/test_r17_compact_safe_harness_pilot.ps1`, compact fixtures under `tests/fixtures/r17_compact_safe_harness_pilot/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_026_compact_safe_harness_pilot/`.
- Done when: the compact-safe harness pilot validates that the future Cycle 3 QA/fix-loop can be represented as smaller resumable work orders and short prompt packets, including inventory, contract/skeleton, cycle packet generation, board/UI/proof package generation, validate/repair, status gate, stage/commit/push, and resume-after-compact steps, while preserving no live execution harness runtime, no harness pilot runtime execution, no OpenAI API invocation, no Codex API invocation, no autonomous Codex invocation, no live QA/Test Agent invocation, no live Developer/Codex invocation, no live A2A runtime, no adapter runtime, no actual tool call, no live board mutation, no QA result, no audit verdict, no product runtime, no main merge, no no-manual-prompt-transfer success claim, no solved Codex compaction/reliability claim, and no R17-028 or later completion claim.
- Residual finding: repeated Codex compact failures remain unresolved. R17-026 only pilots smaller work orders; it does not solve the failure mode.

### `R17-027` Automated Recovery Loop and New-Context Continuation Foundation
- Status: done
- Order: 27
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Durable output: `contracts/runtime/r17_automated_recovery_loop.contract.json`, `tools/R17AutomatedRecoveryLoop.psm1`, `tools/new_r17_automated_recovery_loop.ps1`, `tools/validate_r17_automated_recovery_loop.ps1`, generated recovery-loop state under `state/runtime/r17_automated_recovery_loop_*`, prompt packets under `state/runtime/r17_automated_recovery_loop_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json`, focused test `tests/test_r17_automated_recovery_loop.ps1`, compact fixtures under `tests/fixtures/r17_automated_recovery_loop/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_027_automated_recovery_loop/`.
- Done when: the automated recovery-loop foundation validates failure-event modelling, WIP classification, preserve/abandon actions, continuation packet types, a new-context resume packet, retry limit, escalation policy, prompt packet limits, compact invalid fixtures, and preserved non-claims without live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live execution harness runtime, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, R17 closeout, no-manual-prompt-transfer success claim, solved Codex compaction/reliability claim, or R17-028 completion claim.
- Residual finding: live automation is still not implemented; automatic new-thread creation remains future work; API-level orchestration remains future work; R17-027 only creates the recovery-loop foundation.

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
3. `R17-025`: Compact-safe local execution harness foundation pivot before further cycle execution.
4. `R17-026`: Compact-safe harness pilot for the future Cycle 3 QA/fix-loop.

R17-023 records the first Cycle 1 definition package as repo-backed and packet-only. R17-024 records the Cycle 2 Developer/Codex execution package as repo-backed and packet-only. R17-025 records the compact-safe local execution harness foundation because repeated compaction failures proved the need for smaller, resumable work orders before further cycle execution. R17-026 pilots that model by splitting the future Cycle 3 QA/fix-loop into small work orders and prompt packets without executing the full QA/fix-loop. R17-027 adds a deterministic recovery-loop foundation and new-context continuation packet model for future work. Repeated Codex compact failures remain unresolved, live cycles are not working yet, and `R17-028` remains planned only.

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

This R17 active boundary through `R17-027` claims none of the following:

- no external audit acceptance;
- no live recovery-loop runtime;
- no automatic new-thread creation;
- no live execution harness runtime;
- no harness pilot runtime execution;
- no OpenAI API invocation;
- no Codex API invocation;
- no autonomous Codex invocation;
- no live cycle runtime;
- no live Orchestrator runtime;
- no live PM/Architect agent invocation;
- no live Developer/Codex invocation;
- no live Developer/Codex adapter invocation;
- no live QA/Test Agent invocation;
- no autonomous Codex invocation by product runtime;
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
- no live A2A runtime;
- no live A2A dispatcher runtime;
- no A2A messages sent;
- no live control runtime;
- no live stop/retry/pause/block/re-entry execution;
- no live agent invocation;
- no adapter runtime;
- no actual tool call;
- no external API call;
- no board mutation;
- no QA result;
- no external audit acceptance;
- no executable handoffs yet;
- no executable transitions yet;
- no runtime memory engine;
- no vector retrieval runtime;
- no Codex invocation by product runtime;
- no Evidence Auditor API runtime yet;
- no Dev/Codex executor adapter runtime yet;
- no QA/Test Agent adapter runtime yet;
- no Kanban product runtime yet;
- no real Dev output;
- no real QA result;
- no real audit verdict;
- no R17-028 completion;
- no no-manual-prompt-transfer success claim;
- no Kanban runtime yet;
- no Orchestrator runtime yet;
- no R18 opening.

## Rejected Claims

The following claims are rejected unless future committed evidence and user approval change repo truth:

- the R16 report alone opens or proves R17;
- the revised R17 plan alone implements R17 capability;
- R17-028 is implemented by this pass;
- R17-027 implements live recovery-loop runtime, automatic new-thread creation, automatic Codex thread creation, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live execution harness runtime, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, R17 closeout, no-manual-prompt-transfer success, solved Codex compaction, solved Codex reliability, or future R17-028 completion;
- R17-026 implements live execution harness runtime, harness pilot runtime execution, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live QA/Test Agent invocation, live Developer/Codex invocation, live A2A runtime, adapter runtime, actual tool calls, live board mutation, QA result, audit verdict, product runtime, main merge, no-manual-prompt-transfer success, solved Codex compaction, solved Codex reliability, or future R17-028 or later completion;
- R17-025 implements live execution harness runtime, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, no-manual-prompt-transfer success, solved Codex compaction, solved Codex reliability, or future R17-026 or later completion;
- R17-024 implements live cycle runtime, live Orchestrator runtime, live Developer/Codex adapter invocation, autonomous Codex invocation by product runtime, live A2A runtime, live A2A message sending, live A2A dispatch, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, autonomous agents, production runtime, product runtime, real QA result, real audit verdict, external audit acceptance, main merge, no-manual-prompt-transfer success, or future R17-025 or later completion;
- R17-023 implements live cycle runtime, live Orchestrator runtime, live PM/Architect invocation, live A2A runtime, live A2A message sending, live A2A dispatch, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, Codex executor invocation, autonomous agents, production runtime, product runtime, real Dev output, real QA result, real audit verdict, external audit acceptance, main merge, or future R17-024 or later completion;
- R17-022 implements live control runtime, live stop/retry/pause/block/re-entry execution, live A2A runtime, live A2A dispatch, live A2A message sending, live agent invocation, live Orchestrator runtime, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, autonomous agents, production runtime, product runtime, real Dev output, real QA result, real audit verdict, external audit acceptance, main merge, or future R17-023 or later completion;
- R17-021 implements live A2A runtime, live A2A message sending, live dispatch to agents or adapters, live Orchestrator runtime, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, autonomous agents, production runtime, product runtime, real Dev output, real QA result, real audit verdict, external audit acceptance, main merge, or future R17-022 or later completion;
- R17-020 implements A2A runtime, A2A dispatcher, message sending, message dispatch, live agent invocation, live Orchestrator runtime, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, real audit verdict, or future R17-021 or later completion;
- R17-019 implements tool-call runtime, ledger runtime, actual tool calls, adapter runtime invocation, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, external API calls, A2A runtime, A2A messages, live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, real audit verdict, or future R17-020 or later completion;
- R17-018 implements Evidence Auditor API invocation, external API calls, real audit verdict, external audit acceptance, adapter runtime, tool-call runtime, live tool calls, live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, A2A messages, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, main merge, production runtime, product runtime, real Dev output, real QA result, or future R17-020 or later completion;
- R17-017 implements QA/Test Agent invocation, real QA execution, validation execution through a live adapter, defect opening runtime, fix request runtime, adapter runtime, tool-call runtime, live tool calls, live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, A2A messages, Codex executor invocation, Evidence Auditor API invocation, external API calls, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result without committed validation evidence, or real audit verdict;
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
