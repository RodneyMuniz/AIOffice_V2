# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R18 Automated Recovery Runtime and API Orchestration`

Current posture:
R17 accepted and closed with caveats through R17-028 only. R17 accepted only as a bounded foundation/pivot milestone. R17 did not deliver live product runtime, did not deliver four exercised A2A cycles, did not deliver live A2A runtime, did not deliver live automated recovery, did not solve Codex compaction or reliability, and did not prove no-manual-prompt-transfer success. R18 active through R18-014 only. R18-015 through R18-028 planned only. R18-002 created agent card schema and seed cards only. Agent cards are not live agents. R18-003 created skill contract schema and seed skill contracts only. Skill contracts are not live skill execution. R18-004 created A2A handoff packet schema and seed handoff packets only. A2A handoff packets are not live A2A runtime. R18-005 created role-to-skill permission matrix only. Permission matrix is not runtime enforcement. R18-006 created Orchestrator chat/control intake contract and seed intake packets only. Intake packets are not a live chat UI. Intake packets are not Orchestrator runtime. R18-007 created local runner/CLI shell foundation only. CLI shell is dry-run only. CLI shell is not full work-order execution runtime. R18-008 created work-order execution state machine foundation only. Work-order state machine is not runtime execution. R18-009 created runner state store and resumable execution log foundation only. Runner state store is not live runner runtime. Execution log is deterministic foundation evidence, not live execution evidence. Resume checkpoint is not a continuation packet. R18-010 created compact failure detector foundation only. Failure detection is deterministic over seed signal artifacts only. Failure events are not recovery completion. R18-011 created WIP classifier foundation only. WIP classification is deterministic over seed git inventory artifacts only. R18-012 created remote branch verifier foundation only. Remote branch verifier foundation is bounded branch/head/tree/remote-head verification evidence only. Current branch identity was verified only by bounded git identity checks. No branch mutation was performed. No pull, rebase, reset, merge, checkout, switch, clean, restore, staging, commit, or push was performed by the verifier. No WIP cleanup was performed. No WIP abandonment was performed. No WIP cleanup or abandonment was performed. No files were restored or deleted. No staging, commit, or push was performed by the classifier. R18-013 created continuation packet generator foundation only. Continuation packets were generated as deterministic packet artifacts only. Continuation packets were not executed. Continuation packets are not new-context prompts. R18-014 created new-context prompt generator foundation only. New-context prompt packets were generated as deterministic text artifacts only. Prompt packets were not executed. Automatic new-thread creation was not performed. Codex thread creation was not performed. Codex API invocation did not occur. OpenAI API invocation did not occur. Automatic new-thread creation is not implemented. No retry execution was performed. No staging, commit, or push was performed by the generator. No pull, rebase, reset, merge, checkout, switch, clean, or restore was performed. R18 runtime implementation is not yet delivered. No work orders were executed. No board/card runtime mutation occurred. No A2A messages were sent. No live agents were invoked. No live skills were executed. No A2A runtime was implemented. No live A2A runtime was implemented. No local runner runtime was executed. No recovery runtime was implemented. No recovery action was performed. No API invocation occurred. No automatic new-thread creation occurred. No stage/commit/push was performed by the runner or state store. No stage/commit/push was performed by the detector. No product runtime is claimed. No no-manual-prompt-transfer success is claimed. Codex compaction is detected as a failure type, not solved. Codex reliability is not solved. Main is not merged.

R17 did not deliver live product runtime. R17 did not deliver four exercised A2A cycles. R17 did not deliver live A2A runtime. R17 did not deliver live automated recovery. R17 did not solve Codex compaction or reliability. R17 did not prove no-manual-prompt-transfer success.

`R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation` is complete for bounded foundation scope through `R16-026` only. R16 produced a bounded final proof/review package candidate and final-head support packet only. R16 did not claim external audit acceptance, main merge, runtime execution, product runtime, autonomous agents, true multi-agent execution, external integrations, executable handoffs, executable transitions, solved Codex compaction, or solved Codex reliability.

`R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle` is active on branch `release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle` through `R17-028` final package only after this pass. `R17-001` installed approved planning artifacts. `R17-002` opened R17 in repo truth. `R17-003` added the R17 KPI baseline/target scorecard. `R17-004` defines governed card, board-state, and board-event contracts only. `R17-005` implements bounded repo-backed board state store generation and deterministic event replay/check tooling only. `R17-006` implements a read-only local/static Kanban MVP surface only using the R17-005 board state/replay artifacts. `R17-007` implements a read-only card detail evidence drawer/panel only using the R17-005 board state/replay artifacts and R17-006 Kanban MVP snapshot/UI artifacts. `R17-008` implements a read-only board event detail and evidence summary surface only using the R17-005 board state/replay artifacts, R17-006 Kanban MVP snapshot/UI artifacts, and R17-007 card detail drawer artifacts. `R17-009` defines the Orchestrator identity and authority contract only and creates generated Orchestrator identity/authority state, route recommendation seed, and authority check artifacts only. `R17-010` defines and validates a bounded Orchestrator loop state machine, generated seed evaluation, and transition check artifacts only. `R17-011` implements a bounded operator interaction/intake surface and deterministic intake packet/proposal generation only. `R17-012` defines the R17 agent registry and role identity packet set only, creating generated agent registry, role identity packets, registry check report, and UI workforce snapshot only. `R17-013` implements a bounded deterministic memory/artifact loader foundation only, creating generated memory/artifact loader report, loaded-ref log, future-use agent memory packets, and UI memory loader snapshot only. `R17-014` defines the agent invocation log foundation only, creating seed/foundation invocation records only, a check report, and a read-only UI invocation log snapshot. `R17-015` defines the common tool adapter contract foundation only, creating disabled seed adapter profiles, a check report, compact invalid fixtures, proof-review package, and a read-only UI tool adapter snapshot/panel only. `R17-016` creates a disabled packet-only Developer/Codex executor adapter foundation only, creating generated adapter contract, request/result packets, check report, compact invalid fixtures, proof-review package, and read-only UI Codex executor adapter snapshot/panel only. `R17-017` creates a disabled seed QA/Test Agent adapter foundation only, creating generated adapter contract, request/result/defect packets, check report, compact invalid fixtures, proof-review package, and read-only UI QA/Test Agent adapter snapshot/panel only. `R17-018` creates a disabled seed Evidence Auditor API adapter foundation only, creating generated adapter contract, request/response/verdict packets, check report, compact invalid fixtures, proof-review package, and read-only UI Evidence Auditor API adapter snapshot/panel only. `R17-019` creates a disabled/not-executed tool-call ledger foundation only, creating generated ledger contract, JSONL ledger seed records, check report, compact invalid fixtures, proof-review package, and read-only UI tool-call ledger snapshot only. `R17-020` defines A2A message and handoff contracts only, creating generated A2A message and handoff contracts, disabled/not-dispatched seed packets, check report, compact invalid fixtures, proof-review package, and read-only UI A2A contracts snapshot only. `R17-021` creates a bounded A2A dispatcher foundation only, consuming committed R17-020 seed A2A packets, validating deterministic route candidates, writing not-executed dispatch logs/check artifacts, compact invalid fixtures, proof-review package, and read-only UI dispatcher snapshot only. `R17-022` creates a bounded stop, retry, pause, block, and re-entry controls foundation only, creating deterministic control/re-entry packet candidates, check report, compact invalid fixtures, proof-review package, and read-only UI controls snapshot only. `R17-023` creates a repo-backed exercised Cycle 1 definition package only, with deterministic packet-only PM/Architect definition packets, scoped memory/artifact refs, A2A packet candidates, dispatch/control refs, board event evidence, a read-only UI snapshot, proof-review package, and ready-for-dev packet only. `R17-024` creates a repo-backed Cycle 2 Developer/Codex execution package only, capturing a Developer/Codex request/result packet, dev diff/status summary, packet-only A2A/dispatch/control/invocation/tool-call refs, deterministic board event evidence, a read-only UI snapshot, proof-review package, and card movement to Ready for QA as deterministic repo-backed board evidence only. `R17-025` creates a compact-safe local execution harness foundation only, with a contract, resumable work-order model, prompt packet examples, resume-state/check artifacts, compact invalid fixtures, read-only UI snapshot, and proof-review package after repeated compaction failures proved a smaller work-order harness was needed before further cycle execution. `R17-026` creates a compact-safe harness pilot only, splitting the future Cycle 3 QA/fix-loop into small work orders and prompt packets under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_prompt_packets/` without executing the full QA/fix-loop. `R17-027` creates an automated recovery-loop foundation only, with failure-event modelling, WIP classification, continuation packets, a new-context resume packet, retry/escalation policy, prompt packets under `state/runtime/r17_automated_recovery_loop_prompt_packets/`, read-only UI snapshot, tooling, tests, fixtures, and proof-review package. Repeated Codex compact failures remain unresolved, live automation is still not implemented, automatic new-thread creation remains future work, and `R17-028` creates the final reporting, KPI movement, evidence index, final-head support, and R18 planning package as a closeout candidate requiring operator decision. R17 aims to build the agentic operating surface, A2A runtime, Kanban release cycle, Dev/Codex adapter, QA/Test Agent adapter, Evidence Auditor API adapter, and four A2A cycles, but those runtime/product capabilities are not claimed as implemented by R17.

R17 non-claims remain preserved after R18 opening: no live recovery-loop runtime, no automatic new-thread creation, no live execution harness runtime, no harness pilot runtime execution, no OpenAI API invocation, no Codex API invocation, no autonomous Codex invocation, no live cycle runtime, no live Orchestrator runtime, no live PM/Architect agent invocation, no live Developer/Codex invocation, no live Developer/Codex adapter invocation, no live QA/Test Agent invocation, no autonomous Codex invocation by product runtime, no live board mutation, no runtime card creation, no live agent runtime, no live A2A runtime, no A2A messages sent, no adapter runtime, no tool-call runtime, no ledger runtime, no actual tool call, no external API calls, no external audit acceptance, no main merge, no R13 closure, no R14 caveat removal, no R15 caveat removal, no solved Codex compaction, no solved Codex reliability, no product runtime yet, no production runtime, no autonomous agents yet, no executable handoffs yet, no executable transitions yet, no runtime memory engine, no vector retrieval runtime, no Evidence Auditor API runtime yet, no Dev/Codex executor adapter runtime yet, no QA/Test Agent adapter runtime yet, no Kanban product runtime yet, no real Dev output, no real QA result, no real audit verdict, and no no-manual-prompt-transfer success claim.

`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation` is now closed narrowly after `R10-008` Phase 2 post-push final-head support verified candidate closeout commit `cfebd351922b192585ed5f9d3ca56bee30ea16ae` as the remote branch head. The Phase 1 candidate package is `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/`, and the Phase 2 support packet is `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`. The narrow closeout claim is only that one successful bounded external runner proof run exists from R10-005G, one external-runner-consuming QA signoff exists from R10-006, one two-phase final-head support procedure exists from R10-007, one Phase 1 candidate closeout package exists from R10-008, one Phase 2 post-push final-head support packet exists after the candidate push, and no successor milestone is opened. R10 does not prove broad CI/product coverage, UI or control-room productization, Standard runtime, multi-repo orchestration, swarms, broad autonomous milestone execution, unattended automatic resume, solved Codex context compaction, hours-long unattended milestone execution, destructive rollback, or general Codex reliability.

`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot` is now closed narrowly in repo truth after `R11-009` Phase 2 post-push final-head support. R11 opens after R10 closeout head `91035cfbb34f531684943d0bfd8c3ba660f48f08`; R10 remains the prior closed milestone and is not reopened or widened. `R11-001` through `R11-009` are complete. The Phase 1 candidate closeout package is `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/`, the candidate closeout commit is `545232bfd06df86018917bc677e6ba3374b3b9c4`, and the Phase 2 support packet is `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/final_head_support/final_remote_head_support_packet.json`. R11 closeout is limited to the bounded controlled-cycle pilot, R11-008 cycle evidence, the R11-009 candidate closeout package, and the R11-009 post-push final-head support packet. R11 does not claim unattended automatic resume, real production QA, production runtime, broad autonomous milestone execution, UI/control-room productization, Standard runtime, multi-repo orchestration, swarms, solved Codex context compaction, hours-long unattended execution, destructive rollback, broad CI/product coverage, productized control-room behavior, general Codex reliability, or any claim beyond one bounded R11 controlled-cycle pilot. The R11 closeout itself did not open R12 or any successor milestone.

`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot` is now closed narrowly in repo truth after `R12-021`. R12 starts from the verified R11 audit/R12 planning report commit `5aa08904b02663a5549d2c8a21971544476ae805` and starting tree `ac324d20d4538e50bfdcb92fe192185a824a2f48`, while preserving R11 final accepted closeout head `c3bcdf803c0370db66eaa0a9227b3c2301b28fa2` as the narrow R11 closeout truth. The planning report `governance/reports/AIOffice_V2_R11_Audit_and_R12_Planning_Report_v1.md` is a narrative planning artifact only, not milestone proof. R12 foundation work includes value-gate freeze, scorecard weight alignment, the operating-loop contract, remote-head/stale-phase detection, fresh-thread bootstrap packet generation, mandatory transition residue preflight, external runner contracts, GitHub Actions external-runner substrate tooling, bounded replay workflow/bundle wiring, external artifact evidence normalization, actionable QA report/fix queue foundations, cycle QA evidence gate tooling, static control-room status/view artifacts, an operator decision queue, a bounded one-command control-room refresh workflow, fresh-thread restart proof tooling, imported passing R12-019 external final-state replay evidence under `state/external_runs/r12_external_runner/r12_019_final_state_replay/`, final audit/report evidence at `governance/reports/AIOffice_V2_R12_Final_Audit_Report_v1.md`, and closeout/final-head support at `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/`. R12's strongest proof is the R12-019 external replay, not the report itself. R12-020 is a report artifact, not product proof by itself. R12-021 is closeout/final-head support only. R12 itself did not open R13 or any successor.

`R13 API-First QA Pipeline and Operator Control-Room Product Slice` remains active in repo truth through `R13-018` only, failed/partial, and not closed. R13 starts from the report-committed R12 branch head `9ad475faa87746cb3d6ef074545e4b703e77e786` on branch `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`. The planning authority is `governance/reports/AIOffice_V2_R12_Audit_and_R13_Planning_Report_v1.md`, committed at `9ad475faa87746cb3d6ef074545e4b703e77e786`; it is not product proof by itself.

`R14 Product Vision Pivot and Governance Enforcement` is accepted with caveats as a narrow documentation/governance/reporting-enforcement milestone through `R14-006`. R14 did not close R13, did not implement product runtime, did not integrate Symphony, Linear, GitHub Projects, or a custom board runtime, and did not implement R15 capability.

`R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations` is accepted with caveats by external audit as a bounded foundation milestone only through `R15-009`, at audited head `d9685030a0556a528684d28367db83f4c72f7fc9` and audited tree `7529230df0c1f5bec3625ba654b035a2af824e9b`. R15 opens from R14 head `43653f3dd2e18b46c9e7b02f0c9c095848aee6fc` and locally observed R14 tree `2af1a4aaa858af315e9b4d106d0643b5ce4ebfcc`. The post-audit support commit is `3058bd6ed5067c97f744c92b9b9235004f0568b0` and does not change R15 scope. The R15-009 stale `generated_from_head` and `generated_from_tree` caveat remains preserved for `r15_final_proof_review_package.json` and `evidence_index.json`.

`R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation` is complete for bounded foundation scope through `R16-026` only. R16-026 adds a bounded final proof/review package candidate and final-head support packet only through `contracts/governance/r16_final_proof_review_package.contract.json`, `tools/R16FinalProofReviewPackage.psm1`, `tools/new_r16_final_proof_review_package.ps1`, `tools/validate_r16_final_proof_review_package.ps1`, `tests/test_r16_final_proof_review_package.ps1`, fixtures under `tests/fixtures/r16_final_proof_review_package/`, generated final proof/review package candidate `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/r16_final_proof_review_package.json`, generated final evidence index `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json`, final-head support packet `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/final_head_support_packet.json`, and validation manifest `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/validation_manifest.md`. R16-015 implemented the exact context-load planner and generated a committed context-load plan state artifact only through `tools/R16ContextLoadPlanner.psm1`, `tools/new_r16_context_load_plan.ps1`, `tools/validate_r16_context_load_plan.ps1`, `tests/test_r16_context_load_planner.ps1`, `state/context/r16_context_load_plan.json`, fixtures under `tests/fixtures/r16_context_load_planner/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_015_context_load_planner/`. R16-016 implemented a bounded context budget estimator with approximation fields through `contracts/context/r16_context_budget_estimate.contract.json`, `tools/R16ContextBudgetEstimator.psm1`, `tools/new_r16_context_budget_estimate.ps1`, `tools/validate_r16_context_budget_estimate.ps1`, `tests/test_r16_context_budget_estimator.ps1`, `state/context/r16_context_budget_estimate.json`, fixtures under `tests/fixtures/r16_context_budget_estimator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_016_context_budget_estimator/`. R16-017 added a bounded over-budget context guard and no-full-repo-scan enforcement only through `contracts/context/r16_context_budget_guard.contract.json`, `tools/R16ContextBudgetGuard.psm1`, `tools/test_r16_context_budget_guard.ps1`, `tools/validate_r16_context_budget_guard_report.ps1`, `tests/test_r16_context_budget_guard.ps1`, `state/context/r16_context_budget_guard_report.json`, fixtures under `tests/fixtures/r16_context_budget_guard/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_017_context_budget_guard/`. R16-018 defines the role-run envelope contract only through `contracts/workflow/r16_role_run_envelope.contract.json`, `tools/R16RoleRunEnvelopeContract.psm1`, `tools/validate_r16_role_run_envelope_contract.ps1`, `tests/test_r16_role_run_envelope_contract.ps1`, fixtures under `tests/fixtures/r16_role_run_envelope_contract/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_018_role_run_envelope_contract/`. R16-019 generated role-run envelopes as committed state artifacts only through `tools/R16RoleRunEnvelopeGenerator.psm1`, `tools/new_r16_role_run_envelopes.ps1`, `tools/validate_r16_role_run_envelopes.ps1`, `tests/test_r16_role_run_envelope_generator.ps1`, `state/workflow/r16_role_run_envelopes.json`, compact mutation fixtures under `tests/fixtures/r16_role_run_envelope_generator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_019_role_run_envelope_generator/`. R16-020 adds bounded RACI transition gate validation/reporting only through `contracts/workflow/r16_raci_transition_gate_report.contract.json`, `tools/R16RaciTransitionGate.psm1`, `tools/test_r16_raci_transition_gate.ps1`, `tools/validate_r16_raci_transition_gate_report.ps1`, `tests/test_r16_raci_transition_gate.ps1`, generated state artifact `state/workflow/r16_raci_transition_gate_report.json`, fixtures under `tests/fixtures/r16_raci_transition_gate/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_020_raci_transition_gate/`. R16-021 adds bounded handoff packet generation/reporting only through `contracts/workflow/r16_handoff_packet_report.contract.json`, `tools/R16HandoffPacketGenerator.psm1`, `tools/new_r16_handoff_packets.ps1`, `tools/validate_r16_handoff_packet_report.ps1`, `tests/test_r16_handoff_packet_generator.ps1`, generated state artifact `state/workflow/r16_handoff_packet_report.json`, fixtures under `tests/fixtures/r16_handoff_packet_generator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_021_handoff_packet_generator/`. R16-022 adds bounded restart/compaction recovery drill reporting only through `contracts/workflow/r16_restart_compaction_recovery_drill.contract.json`, `tools/R16RestartCompactionRecoveryDrill.psm1`, `tools/new_r16_restart_compaction_recovery_drill.ps1`, `tools/validate_r16_restart_compaction_recovery_drill.ps1`, `tests/test_r16_restart_compaction_recovery_drill.ps1`, generated state artifact `state/workflow/r16_restart_compaction_recovery_drill.json`, fixtures under `tests/fixtures/r16_restart_compaction_recovery_drill/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_022_restart_compaction_recovery_drill/`. R16-023 adds bounded role-handoff drill reporting only through `contracts/workflow/r16_role_handoff_drill.contract.json`, `tools/R16RoleHandoffDrill.psm1`, `tools/new_r16_role_handoff_drill.ps1`, `tools/validate_r16_role_handoff_drill.ps1`, `tests/test_r16_role_handoff_drill.ps1`, generated state artifact `state/workflow/r16_role_handoff_drill.json`, fixtures under `tests/fixtures/r16_role_handoff_drill/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_023_role_handoff_drill/`. R16-024 adds bounded audit-readiness drill reporting only through `contracts/audit/r16_audit_readiness_drill.contract.json`, `tools/R16AuditReadinessDrill.psm1`, `tools/new_r16_audit_readiness_drill.ps1`, `tools/validate_r16_audit_readiness_drill.ps1`, `tests/test_r16_audit_readiness_drill.ps1`, generated state artifact `state/audit/r16_audit_readiness_drill.json`, fixtures under `tests/fixtures/r16_audit_readiness_drill/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_024_audit_readiness_drill/`. The recovery drill report, role-handoff drill report, and audit-readiness drill report are committed generated state artifacts only. The audit-readiness drill uses exact repo-backed refs only, exact audit input count 12, proof-review ref count 5, and evidence inspection route count 7. Evidence can be inspected through exact audit/artifact map refs and proof-review refs; raw chat history is not canonical evidence, and broad/full repo scan is not used. R16-025 adds bounded friction metrics reporting only through `contracts/governance/r16_friction_metrics_report.contract.json`, `tools/R16FrictionMetricsReport.psm1`, `tools/new_r16_friction_metrics_report.ps1`, `tools/validate_r16_friction_metrics_report.ps1`, `tests/test_r16_friction_metrics_report.ps1`, generated state artifact `state/governance/r16_friction_metrics_report.json`, fixtures under `tests/fixtures/r16_friction_metrics_report/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_025_friction_metrics_report/`. The friction metrics report captures operational friction and context-pressure findings for final R16 audit and next-milestone planning, captures Codex auto-compaction failures as operator-observed process evidence rather than machine proof, captures fixture bloat and compact fixture mitigation, captures the untracked-file visibility gap, captures deterministic byte/line drift, and keeps the failed-closed guard expected and unresolved. This is not external audit acceptance, not final R16 audit acceptance, not main merge, not R13 closure, not R14 caveat removal, not R15 caveat removal, not solved Codex compaction, not solved Codex reliability, not runtime execution, not runtime memory, not retrieval runtime, not vector search runtime, not product runtime, not autonomous agents, not external integrations, not executable handoffs, and not executable transitions. This is not closeout completion and not runtime execution, not runtime handoff execution, not autonomous recovery, not executable handoffs, and not executable transitions. No runtime handoff execution exists. No workflow drill execution beyond bounded report artifacts is claimed. No product runtime, runtime memory, retrieval runtime, vector search runtime, actual autonomous agents, external integrations, solved Codex compaction, or solved Codex reliability are claimed.

R13-001 through R13-011 remain the bounded evidence slices already recorded for opening, lifecycle contracts, issue detection, fix queue, bounded fix packet, demo failure-to-fix proof, local custom runner, skill registry/invocations, current control-room artifacts, operator demo, and passed/imported external replay. R13-012 adds bounded signoff evidence at `state/signoff/r13_meaningful_qa_signoff/`, with decision `accepted_bounded_scope`, aggregate verdict `passed`, and scope `bounded R13 representative QA failure-to-fix loop and evidence-backed operator workflow slice`. R13-013 adds bounded repo-truth continuity mitigation evidence at `state/continuity/r13_compaction_mitigation/`, records `accepted_as_generation_identity_not_current_identity`, cites signoff generation head `fb2179bb7b66d3d7dd1fd4eb2683aed825f01577` and durable R13-012 commit head `9f80291b0f3049ec1dd15635079705db031383fd`, and does not solve Codex compaction generally.

R13-014 adds the cycle evidence package only through `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/evidence/r13_014_cycle_evidence_package.json`, `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/evidence/r13_014_validation_manifest.md`, and `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/operator/r13_014_operator_decision_packet.json`. R13-015 adds calculable Vision Control scoring only through `contracts/vision_control/r13_vision_control_scorecard.contract.json`, `tools/R13VisionControlScorecard.psm1`, `tools/validate_r13_vision_control_scorecard.ps1`, `tests/test_r13_vision_control_scorecard.ps1`, `state/vision_control/r13_015_vision_control_scorecard.json`, and `state/vision_control/r13_015_validation_manifest.md`; the scorecard calculates R13 aggregate `51.9`, uplift `3.7` from the prior reported R12 aggregate and `5.7` from the recomputed R12 item-row aggregate, with no 10 to 15 percent progress claim. R13-016 adds final audit candidate packet only through `governance/reports/AIOffice_V2_R13_Final_Audit_Candidate_Packet_v1.md`. R13-017 adds fail-closed closeout decision packet only through `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/operator/r13_017_closeout_decision_packet.json`. R13-018 adds final failed/partial report and conditional successor recommendation only through `governance/reports/AIOffice_V2_R13_Final_Failed_Partial_Report_and_Conditional_Successor_Recommendation_v1.md`.

The meaningful QA loop hard gate is delivered only for that bounded representative scope, not for full product or production QA. API/custom-runner bypass, current operator control-room, skill invocation evidence, and operator demo remain partial. R13-018 is an operator report artifact only, R13 is not closed, and R14 does not change any R13 partial gate status. `runner.external_replay` is registered but not executed, and `control_room.refresh` is registered but not executed.

Current R16 status: R16 is complete for bounded foundation scope through R16-026 only. R16-026 produces a bounded final proof/review package candidate and final-head support packet only. R16-016 implemented a bounded context budget estimator with approximation fields. R16-017 adds bounded over-budget/no-full-repo-scan guard only. R16-018 defines the role-run envelope contract only. R16-019 generated role-run envelopes as committed state artifacts only. R16-020 adds bounded RACI transition gate validation/reporting only. R16-021 adds bounded handoff packet generation/reporting only. R16-022 adds bounded restart/compaction recovery drill reporting only. R16-023 adds bounded role-handoff drill reporting only. R16-024 adds bounded audit-readiness drill reporting only. R16-025 adds bounded friction metrics reporting only. `state/context/r16_context_load_plan.json` is a committed generated context-load plan state artifact only. `state/context/r16_context_budget_estimate.json` is a committed generated context budget estimate state artifact only. `state/context/r16_context_budget_guard_report.json` is a committed generated context budget guard report state artifact only. `state/workflow/r16_role_run_envelopes.json` is a committed generated role-run envelope state artifact only. `state/workflow/r16_raci_transition_gate_report.json` is a committed generated RACI transition gate report state artifact only. `state/workflow/r16_handoff_packet_report.json` is a committed generated handoff packet report state artifact only. `state/workflow/r16_restart_compaction_recovery_drill.json` is a committed generated restart/compaction recovery drill state artifact only. `state/workflow/r16_role_handoff_drill.json` is a committed generated role-handoff drill state artifact only. `state/audit/r16_audit_readiness_drill.json` is a committed generated audit-readiness drill state artifact only. `state/governance/r16_friction_metrics_report.json` is a committed generated friction metrics report state artifact only. `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/r16_final_proof_review_package.json` is a committed generated final proof/review package candidate state artifact only. `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json` is a committed generated final evidence index state artifact only. `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/final_head_support_packet.json` is a committed generated final-head support packet state artifact only. R16-001 through R16-025 evidence refs are indexed with 25 exact evidence refs, 25 proof-review refs, and 25 validation-manifest refs. R16-026 is a candidate package/final-head support task only. Recovery uses exact repo-backed inputs only; raw chat history is not canonical state; full repo scan is not used. The role handoff chain is `project_manager -> developer -> qa -> evidence_auditor`. All core handoffs are blocked/not executable because the R16-020 transition gate blocks transitions and the R16-017 guard remains `failed_closed_over_budget`. Audit-readiness inputs are exact repo-backed refs only; exact audit input count is 12, proof-review ref count is 5, and evidence inspection route count is 7. Evidence can be inspected through exact audit/artifact map refs and proof-review refs. raw chat history is not canonical evidence, and broad/full repo scan is not used. R16-025 adds bounded friction metrics reporting only through `contracts/governance/r16_friction_metrics_report.contract.json`, `tools/R16FrictionMetricsReport.psm1`, `tools/new_r16_friction_metrics_report.ps1`, `tools/validate_r16_friction_metrics_report.ps1`, `tests/test_r16_friction_metrics_report.ps1`, generated state artifact `state/governance/r16_friction_metrics_report.json`, fixtures under `tests/fixtures/r16_friction_metrics_report/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_025_friction_metrics_report/`. The friction metrics report captures operational friction and context-pressure findings for final R16 audit and next-milestone planning, captures Codex auto-compaction failures as operator-observed process evidence rather than machine proof, captures fixture bloat and compact fixture mitigation, captures the untracked-file visibility gap, captures deterministic byte/line drift, and keeps the failed-closed guard expected and unresolved. This is not external audit acceptance, not final R16 audit acceptance, not main merge, not R13 closure, not R14 caveat removal, not R15 caveat removal, not solved Codex compaction, not solved Codex reliability, not runtime execution, not runtime memory, not retrieval runtime, not vector search runtime, not product runtime, not autonomous agents, not external integrations, not executable handoffs, and not executable transitions. This is not closeout completion and not runtime execution, not runtime handoff execution, not autonomous recovery, not executable handoffs, and not executable transitions. No runtime handoff execution exists. No product runtime, runtime memory, retrieval runtime, vector search runtime, actual autonomous agents, external integrations, solved Codex compaction, or solved Codex reliability are claimed. R15 remains accepted with caveats by external audit as a bounded foundation milestone only at audited head `d9685030a0556a528684d28367db83f4c72f7fc9` and audited tree `7529230df0c1f5bec3625ba654b035a2af824e9b`. R14 remains accepted with caveats through R14-006 only.

Active branch:
`release/r16-operational-memory-artifact-map-role-workflow-foundation`

R15 accepted source branch:
`release/r15-knowledge-base-agent-identity-memory-raci-foundations`

R14 accepted source branch:
`release/r14-product-vision-pivot-and-governance-enforcement`

R13 failed/partial branch:
`release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`

R12 closed branch:
`release/r12-external-api-runner-actionable-qa-control-room-pilot`

Previous branch:
`feature/r5-closeout-remaining-foundations` remains the historical R9 closed/support line and should not be used for new R10+ milestone implementation.

## Most Recently Closed Milestone
`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`

Closeout summary:
`R12-001` through `R12-021` are complete and formally closed narrowly in repo truth. The closeout authority is `governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md`, the closeout proof-review package is `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/`, the candidate closeout commit is `4873068faef918608f9f4d74ecbf6ee779ba2ad4`, the candidate tree is `bb2f95efdaa194f2cae03a57ed29461c32eb5df8`, and the Phase 2 final-head support packet is `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/final_remote_head_support_packet.json`. R12 closeout remains bounded to R12-001 through R12-021 only and does not open R13 or any successor milestone.

Prior closed milestone:
`R11-001` through `R11-009` are complete and formally closed narrowly in repo truth. The closeout authority is `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, the Phase 1 candidate package is `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/`, the Phase 2 final-head support packet is `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/final_head_support/final_remote_head_support_packet.json`, and the candidate closeout commit is `545232bfd06df86018917bc677e6ba3374b3b9c4`. R11 closeout remains bounded to one controlled-cycle pilot and its final support evidence. The R11 closeout did not open a successor; R12 opens later only through the verified R12 branch action recorded above.

Prior closed milestone:
`R10-001` through `R10-008` are complete and formally closed narrowly in repo truth. The closeout authority is `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, the Phase 1 candidate package is `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/`, the Phase 2 final-head support packet is `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`, the candidate closeout commit is `cfebd351922b192585ed5f9d3ca56bee30ea16ae`, final R10 support head is `91035cfbb34f531684943d0bfd8c3ba660f48f08`, and decision authority is `D-0079`. R10 closeout remains bounded to the R10 evidence chain; R11 opens separately after accepted R10 closeout and approved operator report direction.

Prior closed milestone:
`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot` remains closed under `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, the committed proof-review basis under `state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/`, and decision authority `D-0061`.

Prior closed milestone:
`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` remains honestly closed under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review basis under `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, and decision authority `D-0053`.

R8 closeout summary:
`R8-001` through `R8-009` are complete and formally closed in repo truth. The closeout authority is `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review basis is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, the QA proof packet is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/artifacts/clean_checkout_qa/qa_proof_packet.json`, the starting remote-head verification artifact is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/artifacts/remote_head_verification/remote_head_verification_starting_head.json`, the starting remote head is `e27464278c2fb29cc3269b562019784124451288`, and decision authority is `D-0053`. This closeout remains bounded to one remote-gated QA/proof trust substrate for one repository and one active milestone cycle only.

Earlier closed milestone:
`R7 Fault-Managed Continuity and Rollback Drill` remains honestly closed under `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, the committed proof-review basis under `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, and decision authority `D-0050`.

## Tasks

## R18 Task Record

### `R18-001` Open R18 in repo truth and install transition authority
- Status: done
- Purpose: Install the R17 closeout and R18 opening authority only.

### `R18-002` Define agent card schema and validator
- Status: done
- Purpose: Define validated governance/runtime contract agent cards as seed artifacts only, not live agents.

### `R18-003` Define skill contract schema and validator
- Status: done
- Purpose: Define explicit skill contracts and validation as schema/seed governance artifacts only, not live skill execution.

### `R18-004` Define A2A handoff packet schema and validator
- Status: done
- Purpose: Define explicit validated A2A handoff packets as schema/seed governance artifacts only, not live A2A runtime.

### `R18-005` Define explicit role-to-skill permission matrix
- Status: done
- Purpose: Bind roles to allowed skills, forbidden skills, approval gates, evidence obligations, runtime false flags, and fail-closed constraints as a matrix-only governance artifact.

### `R18-006` Build Orchestrator chat/control intake contract
- Status: done
- Purpose: Define operator chat/control intake and refusal rules as a contract and seed-packet governance artifact only.

### `R18-007` Build local runner/CLI shell foundation
- Status: done
- Purpose: Create a dry-run-only local runner/CLI shell foundation that validates command shape, branch identity, authority refs, intake packet refs, path policy, and unsafe-command refusal without executing work orders.

### `R18-008` Implement work-order execution state machine foundation
- Status: done
- Purpose: Define the governed work-order state machine foundation, deterministic seed packets, transition evaluations, and fail-closed validation without executing work orders.

### `R18-009` Implement runner state store and resumable execution log
- Status: done
- Purpose: Persist deterministic runner state, JSONL state history, JSONL execution log, and a resume checkpoint foundation without executing work orders or implementing live runner runtime.

### `R18-010` Implement compact failure detector
- Status: done
- Purpose: Create a deterministic compact/context/stream failure detector foundation over committed seed signal artifacts only, producing failure-event evidence without recovery runtime.

### `R18-011` Implement WIP classifier
- Status: done
- Purpose: Create a deterministic seed git-inventory WIP classifier foundation that classifies safe/no-WIP, scoped tracked WIP, unexpected tracked WIP, unsafe historical evidence edits, operator-local backup paths, untracked local notes, generated artifact churn, staged files, and operator-decision WIP without cleanup or recovery actions.

### `R18-012` Implement remote branch verifier
- Status: done
- Purpose: Create bounded branch/head/tree/remote-head verifier foundation artifacts and one current branch verification packet without branch mutation, recovery, continuation generation, or release gate claims.

### `R18-013` Implement continuation packet generator
- Status: done
- Purpose: Create deterministic continuation packet contracts, input sets, seed continuation packets, validator, fixtures, and proof-review package from R18 runner/failure/WIP/remote/checkpoint refs without executing packets or generating new-context prompts.

### `R18-014` Implement new-context/new-thread prompt generator
- Status: done
- Purpose: Create deterministic exact-ref prompt input artifacts and copy/paste-ready new-context prompt text packets from R18-013 continuation packets without executing prompts, creating Codex threads, invoking APIs, or performing recovery.

### `R18-015` Implement retry and escalation policy
- Status: planned
- Purpose: Enforce retry limits and escalation stop behavior.

### `R18-016` Implement operator approval gate model
- Status: planned
- Purpose: Preserve operator decisions for risky actions only.

### `R18-017` Implement stage/commit/push gate
- Status: planned
- Purpose: Gate release actions on validation, evidence, status, and approvals.

### `R18-018` Implement status-doc gate automation wrapper
- Status: planned
- Purpose: Keep R18 status docs synchronized and fail closed on overclaims.

### `R18-019` Implement evidence package automation wrapper
- Status: planned
- Purpose: Generate proof packages from machine-readable runtime evidence.

### `R18-020` Implement board/card runtime event model
- Status: planned
- Purpose: Define append-only board/card runtime events.

### `R18-021` Implement agent invocation and tool-call evidence model
- Status: planned
- Purpose: Record invocation and tool-call evidence without fake live claims.

### `R18-022` Implement safety, secrets, budget, and token controls
- Status: planned
- Purpose: Create controls required before any API-backed automation.

### `R18-023` Implement optional API adapter stub only after controls
- Status: planned
- Purpose: Add only a disabled/dry-run adapter stub after controls exist.

### `R18-024` Exercise compact-failure recovery drill with local runner
- Status: planned
- Purpose: Drill compact-failure recovery through the local runner.

### `R18-025` Retry Cycle 3 QA/fix-loop using compact-safe harness
- Status: planned
- Purpose: Retry the QA/fix-loop with compact-safe execution evidence.

### `R18-026` Retry Cycle 4 audit/closeout using compact-safe harness
- Status: planned
- Purpose: Retry the audit/closeout loop with harness evidence.

### `R18-027` Measure operator burden reduction
- Status: planned
- Purpose: Measure reduction in repetitive manual GPT-to-Codex prompt relay.

### `R18-028` Produce R18 final proof package and acceptance recommendation
- Status: planned
- Purpose: Package R18 evidence and recommend acceptance or repair.

## Closed R17 Task Record

### `R17-001` Install R16 external audit/R17 planning report and revised R17 release plan
- Status: done
- Order: 1
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: final R16 head `5bae17229ea10dee4ce072b258f828220b9d1d8d`, final R16 tree `9de1a7b733f400da78f8e683ae4111977c70f1fb`, operator approval, and approved local planning artifacts
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `governance/reports/AIOffice_V2_R16_External_Audit_and_R17_Planning_Report_v1.md`, `governance/plans/AIOffice_V2_Revised_R17_Agentic_Operating_Surface_A2A_Runtime_Kanban_Release_Cycle_Plan_v1.md`, and `state/planning/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_001_planning_artifact_manifest.md`
- Done when: approved operator artifacts are installed as planning/report artifacts only and no external-audit, main-merge, product-runtime, A2A-runtime, autonomous-agent, solved-Codex, or historical-boundary claim is added

### `R17-002` Open R17 in repo truth
- Status: done
- Order: 2
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-001`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: R17 branch, R17 authority document, status-surface updates, decision-log update, and R17 task boundary through `R17-003`
- Done when: R17 is active through `R17-003` only, `R17-004` through `R17-028` remain planned only, and R13/R14/R15/R16 boundaries are preserved

### `R17-003` Add R17 KPI baseline and target scorecard
- Status: done
- Order: 3
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-002`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `state/governance/r17_kpi_baseline_target_scorecard.json`, `contracts/governance/r17_kpi_baseline_target_scorecard.contract.json`, `tools/validate_r17_kpi_baseline_target_scorecard.ps1`, and `tests/test_r17_kpi_baseline_target_scorecard.ps1`
- Done when: the ten-domain R17 KPI baseline/target scorecard validates, target scores remain future requirements only, and no R17-004-or-later implementation is claimed

### `R17-004` Define governed card, board-state, and board-event contracts
- Status: done
- Order: 4
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-003`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/board/r17_card.contract.json`, `contracts/board/r17_board_state.contract.json`, `contracts/board/r17_board_event.contract.json`, `tools/R17BoardContracts.psm1`, `tools/validate_r17_board_contracts.ps1`, `tests/test_r17_board_contracts.ps1`, fixtures under `tests/fixtures/r17_board_contracts/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/`
- Done when: governed card, board-state, and board-event contract shape and fixture behavior validate, invalid lanes/roles/missing fields/closure-without-user-approval/unsupported claims fail closed, and R17-004 remains contract/model proof only without board state store, Kanban UI, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, or product runtime

### `R17-005` Implement bounded board state store and deterministic event replay checks
- Status: done
- Order: 5
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-004`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `tools/R17BoardStateStore.psm1`, `tools/new_r17_board_state_store.ps1`, `tools/validate_r17_board_state_store.ps1`, `tests/test_r17_board_state_store.ps1`, fixtures under `tests/fixtures/r17_board_state_store/`, generated board state artifacts under `state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/`
- Done when: the R17-005 seed card and seed events validate against the R17-004 contract shapes and R17-005 boundary rules, deterministic replay generates a board state artifact and replay report with verdict `generated_r17_board_state_store_candidate`, invalid event fixtures fail closed, user approval remains required for closure, and no Kanban UI, Orchestrator runtime, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, or product runtime is implemented or claimed

### `R17-006` Build Kanban interface MVP
- Status: done
- Order: 6
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-005`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `scripts/operator_wall/r17_kanban_mvp/`, `state/ui/r17_kanban_mvp/r17_kanban_snapshot.json`, `tools/R17KanbanMvp.psm1`, `tools/new_r17_kanban_mvp.ps1`, `tools/validate_r17_kanban_mvp.ps1`, `tests/test_r17_kanban_mvp.ps1`, fixtures under `tests/fixtures/r17_kanban_mvp/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_006_kanban_mvp/`
- Done when: the operator can open the local/static read-only Kanban MVP and see the required R17 lanes, the R17-005 seed card in its replayed current lane, evidence refs, replay summary, user-decision state, and non-claims without treating R17-005 repo-backed state artifacts or the R17-006 UI as Kanban product runtime

### `R17-007` Add card detail evidence drawer
- Status: done
- Order: 7
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-006`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json`, updated local/static Kanban MVP files under `scripts/operator_wall/r17_kanban_mvp/`, `tools/R17CardDetailDrawer.psm1`, `tools/new_r17_card_detail_drawer.ps1`, `tools/validate_r17_card_detail_drawer.ps1`, `tests/test_r17_card_detail_drawer.ps1`, fixtures under `tests/fixtures/r17_card_detail_drawer/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_007_card_detail_evidence_drawer/`
- Done when: the operator can open the local/static Kanban MVP, select or inspect the R17-005 seed card, and see card identity, acceptance/QA criteria, memory refs, task packet ref, event history, evidence refs, user-decision state, non-claims, rejected claims, and explicit `not_implemented_in_r17_007` placeholders for Dev output, QA result, and audit verdict without claiming live board mutation, runtime agent execution, product runtime, or A2A runtime

### `R17-008` Add board event detail and evidence summary surface
- Status: done
- Order: 8
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-007`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json`, updated local/static Kanban MVP files under `scripts/operator_wall/r17_kanban_mvp/`, `tools/R17EventEvidenceSummary.psm1`, `tools/new_r17_event_evidence_summary.ps1`, `tools/validate_r17_event_evidence_summary.ps1`, `tests/test_r17_event_evidence_summary.ps1`, fixtures under `tests/fixtures/r17_event_evidence_summary/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_008_event_evidence_summary/`
- Done when: the operator can open the local/static Kanban MVP and inspect replay summary, event timeline, event-level evidence refs, validation refs, transition decisions, evidence grouping, missing/stale evidence summary, user-decision state, non-claims, rejected claims, and explicit `not_implemented_in_r17_008` placeholders for Dev output, QA result, and audit verdict without claiming live board mutation, runtime agent execution, product runtime, or A2A runtime

### `R17-009` Define Orchestrator identity and authority contract
- Status: done
- Order: 9
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-008`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/agents/r17_orchestrator_identity_authority.contract.json`, generated state artifacts under `state/agents/`, `tools/R17OrchestratorIdentityAuthority.psm1`, `tools/new_r17_orchestrator_identity_authority.ps1`, `tools/validate_r17_orchestrator_identity_authority.ps1`, `tests/test_r17_orchestrator_identity_authority.ps1`, fixtures under `tests/fixtures/r17_orchestrator_identity_authority/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_009_orchestrator_identity_authority/`
- Done when: the Orchestrator identity and authority contract, generated identity/authority state, non-executable route recommendation seed, and authority check report validate while preserving no Orchestrator runtime, live board mutation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict claims

### `R17-010` Implement Orchestrator loop state machine
- Status: done
- Order: 10
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-009`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json`, generated state artifacts under `state/orchestration/`, tooling `tools/R17OrchestratorLoopStateMachine.psm1`, `tools/new_r17_orchestrator_loop_state_machine.ps1`, and `tools/validate_r17_orchestrator_loop_state_machine.ps1`, focused test `tests/test_r17_orchestrator_loop_state_machine.ps1`, compact fixtures under `tests/fixtures/r17_orchestrator_loop_state_machine/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_010_orchestrator_loop_state_machine/`
- Done when: the bounded Orchestrator loop state machine contract, generated state-machine artifact, seed evaluation, and transition check report validate, required invalid transition/claim fixtures fail closed, current seed evaluation remains non-executable at `ready_for_user_review`, closure requires user approval, and no Orchestrator runtime, live board mutation, A2A runtime, adapters, autonomous agents, executable handoffs/transitions, external integrations, external audit acceptance, main merge, production runtime, product runtime, real Dev output, real QA result, or real audit verdict is implemented or claimed

### `R17-011` Add operator interaction endpoint/surface
- Status: done
- Order: 11
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-010`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/intake/r17_operator_intake.contract.json`, generated intake artifacts under `state/intake/`, `state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json`, updated local/static Kanban MVP intake panel, `tools/R17OperatorIntakeSurface.psm1`, wrapper scripts, focused tests, fixtures under `tests/fixtures/r17_operator_intake_surface/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_011_operator_interaction_surface/`
- Done when: a seed operator request produces a governed operator-intake packet, non-executable Orchestrator intake proposal, check report, UI snapshot, and local/static intake preview panel without live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, adapters, autonomous agents, executable handoffs, executable transitions, external integrations, production runtime, product runtime, real Dev output, real QA result, or real audit verdict

### `R17-012` Define agent registry and identity packets
- Status: done
- Order: 12
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-011`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/agents/r17_agent_registry.contract.json`, `contracts/agents/r17_agent_identity_packet.contract.json`, `state/agents/r17_agent_registry.json`, identity packets under `state/agents/r17_agent_identities/`, `state/agents/r17_agent_registry_check_report.json`, `state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json`, updated local/static Kanban MVP workforce panel, `tools/R17AgentRegistry.psm1`, wrapper scripts, focused tests, fixtures under `tests/fixtures/r17_agent_registry/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_012_agent_registry_identity_packets/`
- Done when: the required R17 agents have generated identity packets with authority, allowed/forbidden action, memory, tool, evidence, handoff, approval, and runtime false-flag boundaries, and validation rejects runtime agent invocation, A2A runtime, adapter runtime, API calls, autonomous-agent claims, fake multi-agent narration as proof, executable handoffs/transitions, live board mutation, runtime card creation, false Dev/QA/Audit outputs, external audit acceptance, main merge, and R13/R14/R15 boundary rewrites

### `R17-013` Implement R16 memory/artifact map loader for live agents
- Status: done
- Order: 13
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-012`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/context/r17_memory_artifact_loader.contract.json`, `tools/R17MemoryArtifactLoader.psm1`, `tools/new_r17_memory_artifact_loader.ps1`, `tools/validate_r17_memory_artifact_loader.ps1`, `state/context/r17_memory_artifact_loader_report.json`, `state/context/r17_memory_loaded_refs_log.json`, future-use packets under `state/agents/r17_agent_memory_packets/`, `state/ui/r17_kanban_mvp/r17_memory_loader_snapshot.json`, updated local/static Kanban MVP memory loader panel, focused test `tests/test_r17_memory_artifact_loader.ps1`, compact fixtures under `tests/fixtures/r17_memory_artifact_loader/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_013_memory_artifact_loader/`
- Done when: the deterministic loader validates exact repo-backed R17-012 and R16 refs, writes compact loaded-ref summaries and future-use agent memory packets without embedding full source file contents, rejects runtime memory/vector/live-agent claims, and avoids broad repo scans in the happy path

### `R17-014` Define agent invocation log
- Status: done
- Order: 14
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-013`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/runtime/r17_agent_invocation_log.contract.json`, `tools/R17AgentInvocationLog.psm1`, `tools/new_r17_agent_invocation_log.ps1`, `tools/validate_r17_agent_invocation_log.ps1`, `state/runtime/r17_agent_invocation_log.jsonl`, `state/runtime/r17_agent_invocation_log_check_report.json`, `state/ui/r17_kanban_mvp/r17_agent_invocation_log_snapshot.json`, updated local/static Kanban MVP invocation log panel, focused test `tests/test_r17_agent_invocation_log.ps1`, compact fixtures under `tests/fixtures/r17_agent_invocation_log/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_014_agent_invocation_log/`
- Done when: the repo-backed invocation log contract, seed/foundation invocation records, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass while preserving no live agent runtime, no live Orchestrator runtime, no live board mutation, no runtime card creation, no A2A runtime, no A2A messages sent, no adapters, no external API calls, no autonomous agents, no runtime memory engine, no vector retrieval, no executable handoffs, no executable transitions, no product runtime, no production runtime, no real Dev output, no real QA result, and no real audit verdict

### `R17-015` Define common tool adapter contract
- Status: done
- Order: 15
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-014`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/tools/r17_tool_adapter.contract.json`, `tools/R17ToolAdapterContract.psm1`, `tools/new_r17_tool_adapter_contract.ps1`, `tools/validate_r17_tool_adapter_contract.ps1`, `state/tools/r17_tool_adapter_seed_profiles.json`, `state/tools/r17_tool_adapter_contract_check_report.json`, `state/ui/r17_kanban_mvp/r17_tool_adapter_contract_snapshot.json`, updated local/static Kanban MVP tool adapter contract panel, focused test `tests/test_r17_tool_adapter_contract.ps1`, compact fixtures under `tests/fixtures/r17_tool_adapter_contract/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_015_tool_adapter_contract/`
- Done when: the common tool adapter contract foundation, disabled seed adapter profiles, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass while preserving no adapter runtime, no tool-call runtime, no live tool calls, no Codex executor invocation, no QA/Test Agent invocation, no Evidence Auditor API invocation, no external API calls, no A2A runtime, no A2A messages, no live agent runtime, no live Orchestrator runtime, no board mutation, no runtime card creation, no autonomous agents, no runtime memory engine, no vector retrieval, no executable handoffs, no executable transitions, no product runtime, no production runtime, no real Dev output, no real QA result, and no real audit verdict

### `R17-016` Create disabled Developer/Codex executor adapter foundation
- Status: done
- Order: 16
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-015`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/tools/r17_codex_executor_adapter.contract.json`, `tools/R17CodexExecutorAdapter.psm1`, `tools/new_r17_codex_executor_adapter.ps1`, `tools/validate_r17_codex_executor_adapter.ps1`, `state/tools/r17_codex_executor_adapter_request_packet.json`, `state/tools/r17_codex_executor_adapter_result_packet.json`, `state/tools/r17_codex_executor_adapter_check_report.json`, `state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json`, updated local/static Kanban MVP Codex executor adapter panel, focused test `tests/test_r17_codex_executor_adapter.ps1`, compact fixtures under `tests/fixtures/r17_codex_executor_adapter/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_016_codex_executor_adapter/`
- Done when: the disabled packet-only Developer/Codex executor adapter foundation, request packet, result packet, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass while preserving no Codex invocation, no adapter runtime, no tool-call runtime, no live tool calls, no external API calls, no A2A runtime, no A2A messages, no live agent runtime, no live Orchestrator runtime, no board mutation, no runtime card creation, no autonomous agents, no runtime memory engine, no vector retrieval, no executable handoffs, no executable transitions, no product runtime, no production runtime, no real Dev output, no real QA result, and no real audit verdict

### `R17-017` Implement QA/Test Agent adapter
- Status: done
- Order: 17
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-016`
- Durable output: `contracts/tools/r17_qa_test_agent_adapter.contract.json`, `tools/R17QaTestAgentAdapter.psm1`, `tools/new_r17_qa_test_agent_adapter.ps1`, `tools/validate_r17_qa_test_agent_adapter.ps1`, `state/tools/r17_qa_test_agent_adapter_request_packet.json`, `state/tools/r17_qa_test_agent_adapter_result_packet.json`, `state/tools/r17_qa_test_agent_adapter_defect_packet.json`, `state/tools/r17_qa_test_agent_adapter_check_report.json`, `state/ui/r17_kanban_mvp/r17_qa_test_agent_adapter_snapshot.json`, updated local/static Kanban MVP QA/Test Agent adapter panel, focused test `tests/test_r17_qa_test_agent_adapter.ps1`, compact fixtures under `tests/fixtures/r17_qa_test_agent_adapter/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_017_qa_test_agent_adapter/`.
- Done when: the disabled seed QA/Test Agent adapter foundation, request packet, result packet, defect packet, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass while preserving no QA/Test Agent invocation, no real QA execution, no validation execution through a live adapter, no defect opening runtime, no fix request runtime, no adapter runtime, no tool-call runtime, no live tool calls, no external API calls, no Codex executor invocation, no Evidence Auditor API invocation, no A2A runtime, no A2A messages, no live agent runtime, no live Orchestrator runtime, no board mutation, no runtime card creation, no autonomous agents, no runtime memory engine, no vector retrieval, no executable handoffs, no executable transitions, no product runtime, no production runtime, no real Dev output, no real QA result without committed validation evidence, and no real audit verdict.
### `R17-018` Implement Evidence Auditor API adapter
- Status: done
- Order: 18
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-017`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/tools/r17_evidence_auditor_api_adapter.contract.json`, `tools/R17EvidenceAuditorApiAdapter.psm1`, `tools/new_r17_evidence_auditor_api_adapter.ps1`, `tools/validate_r17_evidence_auditor_api_adapter.ps1`, `state/tools/r17_evidence_auditor_api_adapter_request_packet.json`, `state/tools/r17_evidence_auditor_api_adapter_response_packet.json`, `state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json`, `state/tools/r17_evidence_auditor_api_adapter_check_report.json`, `state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json`, updated local/static Kanban MVP Evidence Auditor API adapter panel, focused test `tests/test_r17_evidence_auditor_api_adapter.ps1`, compact fixtures under `tests/fixtures/r17_evidence_auditor_api_adapter/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_018_evidence_auditor_api_adapter/`.
- Done when: the disabled seed Evidence Auditor API adapter foundation, audit request packet, response placeholder packet, verdict placeholder packet, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass while preserving `adapter_enabled: false`, `evidence_auditor_api_invoked: false`, `external_api_call_performed: false`, `audit_verdict_claimed: false`, `real_audit_verdict: false`, `external_audit_acceptance_claimed: false`, `runtime_execution_performed: false`, no real audit verdict without committed external request/response/verdict evidence, no adapter runtime, no tool-call runtime, no A2A runtime, no live agent runtime, no board mutation, no runtime card creation, no autonomous agents, no product runtime, no production runtime, no main merge, and no R17-020 or later completion claim.

### `R17-019` Add tool-call ledger
- Status: done
- Order: 19
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-018`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/runtime/r17_tool_call_ledger.contract.json`, `state/runtime/r17_tool_call_ledger.jsonl`, `state/runtime/r17_tool_call_ledger_check_report.json`, `state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json`, tooling `tools/R17ToolCallLedger.psm1`, `tools/new_r17_tool_call_ledger.ps1`, and `tools/validate_r17_tool_call_ledger.ps1`, focused test `tests/test_r17_tool_call_ledger.ps1`, compact fixtures under `tests/fixtures/r17_tool_call_ledger/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/`.
- Done when: the disabled/not-executed tool-call ledger foundation, contract, JSONL seed records, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass while preserving no tool-call runtime, no ledger runtime, no actual tool call, no adapter runtime invocation, no Codex executor invocation, no QA/Test Agent invocation, no Evidence Auditor API invocation, no external API call, no A2A message, no board mutation, no runtime card creation, no product runtime, no production runtime, no real audit verdict, no external audit acceptance, no main merge, and no R17-020 or later completion claim.

### `R17-020` Define A2A message and handoff contracts
- Status: done
- Order: 20
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-019`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/a2a/r17_a2a_message.contract.json`, `contracts/a2a/r17_a2a_handoff.contract.json`, `state/a2a/r17_a2a_message_seed_packets.json`, `state/a2a/r17_a2a_handoff_seed_packets.json`, `state/a2a/r17_a2a_contract_check_report.json`, `state/ui/r17_kanban_mvp/r17_a2a_contracts_snapshot.json`, tooling `tools/R17A2aContracts.psm1`, `tools/new_r17_a2a_contracts.ps1`, and `tools/validate_r17_a2a_contracts.ps1`, focused test `tests/test_r17_a2a_contracts.ps1`, compact fixtures under `tests/fixtures/r17_a2a_contracts/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_020_a2a_contracts/.`
- Done when: the generated A2A message and handoff contracts, disabled/not-dispatched seed packets, check report, UI snapshot, compact invalid fixtures, validator, and focused test pass; every packet preserves registry-bound agent IDs, correlation/card IDs, evidence/authority refs, memory packet refs, invocation/tool-call/board refs, explicit false runtime flags, non-claims, and rejected claims; and no A2A runtime, dispatcher, message sending, message dispatch, agent invocation, adapter runtime, actual tool call, external API call, board mutation, runtime card creation, QA result, real audit verdict, external audit acceptance, main merge, or R17-021 or later completion claim is implemented or claimed.

### `R17-021` Implement A2A dispatcher
- Status: done
- Order: 21
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-020`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/a2a/r17_a2a_dispatcher.contract.json`, `state/a2a/r17_a2a_dispatcher_routes.json`, `state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl`, `state/a2a/r17_a2a_dispatcher_check_report.json`, `state/ui/r17_kanban_mvp/r17_a2a_dispatcher_snapshot.json`, tooling, compact fixtures, focused test, and proof-review package
- Done when: the bounded dispatcher foundation validates committed R17-020 seed message/handoff packets, produces deterministic route candidates and not-executed dispatch log entries, rejects unauthorized handoffs and unsafe runtime/future-task claims, preserves exact repo-relative refs, and does not send A2A messages, invoke live agents, invoke Orchestrator runtime, invoke adapters, perform tool/API calls, mutate the board, create runtime cards, claim QA/audit results, claim external audit acceptance, claim main merge, or complete R17-022 or later.

### `R17-022` Add stop, retry, pause, block, and re-entry controls
- Status: done
- Order: 22
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-021`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/runtime/r17_stop_retry_reentry_controls.contract.json`, `state/runtime/r17_stop_retry_reentry_control_packets.json`, `state/runtime/r17_stop_retry_reentry_reentry_packets.json`, `state/runtime/r17_stop_retry_reentry_check_report.json`, `state/ui/r17_kanban_mvp/r17_stop_retry_reentry_controls_snapshot.json`, tooling, compact fixtures, focused test, and proof-review package
- Done when: the bounded control foundation validates committed R17-021 dispatcher artifacts, produces deterministic stop/retry/pause/block/re-entry control packets and re-entry packets, rejects unsupported actions and unsafe runtime/future-task claims, preserves exact repo-relative refs, and does not perform live stop, retry, pause, block, re-entry, A2A dispatch, agent invocation, Orchestrator runtime, adapter runtime, tool/API calls, board mutation, QA result, audit verdict, external audit acceptance, main merge, or complete R17-023 or later

### `R17-023` Exercise Cycle 1: Orchestrator to PM/Architect to Board
- Status: done
- Order: 23
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-022`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/cycles/r17_cycle_1_definition.contract.json`, generated cycle state under `state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/`, cycle-specific board card/event/snapshot artifacts, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_cycle_1_definition_snapshot.json`, tooling `tools/R17Cycle1Definition.psm1`, `tools/new_r17_cycle_1_definition.ps1`, and `tools/validate_r17_cycle_1_definition.ps1`, focused test `tests/test_r17_cycle_1_definition.ps1`, compact fixtures under `tests/fixtures/r17_cycle_1_definition/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/`.
- Done when: the repo-backed exercised Cycle 1 definition package validates one bounded operator intent converted into a governed card snapshot, deterministic packet-only PM/Architect definitions, scoped memory/artifact refs, A2A packet candidates, dispatch/control refs, board event evidence, read-only UI snapshot, and ready-for-dev packet only without live cycle runtime, live Orchestrator runtime, live PM/Architect invocation, live A2A runtime, live A2A messages, adapter runtime, actual tool calls, external API calls, live board mutation, Codex executor invocation, Dev output, QA result, real audit verdict, external audit acceptance, autonomous agents, product runtime, main merge, or R17-024 or later completion claim.

### `R17-024` Exercise Cycle 2: Orchestrator to Developer/Codex to Board
- Status: done
- Order: 24
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-023`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/cycles/r17_cycle_2_dev_execution.contract.json`, generated cycle state under `state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution/`, cycle-specific board card/event/snapshot artifacts, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_cycle_2_dev_execution_snapshot.json`, tooling `tools/R17Cycle2DevExecution.psm1`, `tools/new_r17_cycle_2_dev_execution.ps1`, and `tools/validate_r17_cycle_2_dev_execution.ps1`, focused test `tests/test_r17_cycle_2_dev_execution.ps1`, compact fixtures under `tests/fixtures/r17_cycle_2_dev_execution/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution/`.
- Done when: the repo-backed Cycle 2 Developer/Codex execution package validates the R17-023 ready-for-dev packet transformed into a Developer/Codex request/result packet, dev diff/status summary, packet-only A2A/handoff/dispatch/control/invocation/tool-call refs, deterministic board event evidence, read-only UI snapshot, and card movement to Ready for QA as deterministic repo-backed board evidence only without live cycle runtime, live Orchestrator runtime, live Developer/Codex adapter invocation, autonomous Codex invocation by product runtime, live A2A runtime, live A2A messages, adapter runtime, actual tool calls, external API calls, live board mutation, runtime card creation, QA result, real audit verdict, external audit acceptance, autonomous agents, product runtime, main merge, no-manual-prompt-transfer success claim, or R17-025 or later completion claim.

### `R17-025` Compact-Safe Local Execution Harness Foundation
- Status: done
- Order: 25
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-024`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/runtime/r17_compact_safe_execution_harness.contract.json`, tooling `tools/R17CompactSafeExecutionHarness.psm1`, `tools/new_r17_compact_safe_execution_harness.ps1`, and `tools/validate_r17_compact_safe_execution_harness.ps1`, generated harness state under `state/runtime/r17_compact_safe_execution_harness_*`, prompt packet examples under `state/runtime/r17_compact_safe_execution_harness_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json`, focused test `tests/test_r17_compact_safe_execution_harness.ps1`, compact fixtures under `tests/fixtures/r17_compact_safe_execution_harness/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_025_compact_safe_execution_harness/`.
- Done when: the compact-safe local execution harness foundation validates a resumable work-order model, five small prompt packet examples, resume-after-compact model, stage/commit/push step model, compact invalid fixtures, and preserved non-claims without live execution harness runtime, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, no-manual-prompt-transfer success claim, solved Codex compaction/reliability claim, or R17-026 or later completion claim.

### `R17-026` Compact-Safe Harness Pilot for Cycle 3 QA/fix-loop
- Status: done
- Order: 26
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-025`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/runtime/r17_compact_safe_harness_pilot.contract.json`, tooling `tools/R17CompactSafeHarnessPilot.psm1`, `tools/new_r17_compact_safe_harness_pilot.ps1`, and `tools/validate_r17_compact_safe_harness_pilot.ps1`, generated pilot state under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_*`, prompt packets under `state/runtime/r17_compact_safe_harness_pilot_cycle_3_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json`, focused test `tests/test_r17_compact_safe_harness_pilot.ps1`, compact fixtures under `tests/fixtures/r17_compact_safe_harness_pilot/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_026_compact_safe_harness_pilot/`.
- Done when: the compact-safe harness pilot validates that the future Cycle 3 QA/fix-loop can be split into small resumable work orders and short prompt packets, including inventory, contract/skeleton, cycle packet generation, board/UI/proof package generation, validate/repair, status gate, stage/commit/push, and resume-after-compact steps, while preserving no live execution harness runtime, no harness pilot runtime execution, no OpenAI API invocation, no Codex API invocation, no autonomous Codex invocation, no live QA/Test Agent invocation, no live Developer/Codex invocation, no live A2A runtime, no adapter runtime, no actual tool call, no live board mutation, no QA result, no audit verdict, no product runtime, no main merge, no no-manual-prompt-transfer success claim, no solved Codex compaction/reliability claim, and no R17-028 or later completion claim.

### `R17-027` Automated Recovery Loop and New-Context Continuation Foundation
- Status: done
- Order: 27
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-026`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `contracts/runtime/r17_automated_recovery_loop.contract.json`, `tools/R17AutomatedRecoveryLoop.psm1`, `tools/new_r17_automated_recovery_loop.ps1`, `tools/validate_r17_automated_recovery_loop.ps1`, generated recovery-loop state under `state/runtime/r17_automated_recovery_loop_*`, prompt packets under `state/runtime/r17_automated_recovery_loop_prompt_packets/`, read-only UI snapshot `state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json`, focused test `tests/test_r17_automated_recovery_loop.ps1`, compact fixtures under `tests/fixtures/r17_automated_recovery_loop/`, and proof-review package `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_027_automated_recovery_loop/`
- Done when: the automated recovery-loop foundation validates failure-event modelling, WIP classification, preserve/abandon actions, continuation packet types, a new-context resume packet, retry limit, escalation policy, prompt packet limits, compact invalid fixtures, and preserved non-claims without live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live execution harness runtime, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, R17 closeout, no-manual-prompt-transfer success claim, solved Codex compaction/reliability claim, or R17-028 completion claim

### `R17-028` Produce R17 final report, KPI movement package, and final proof/review package
- Status: done
- Order: 28
- Milestone: `R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle`
- Depends on: `R17-027`
- Authority: `governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md`
- Durable output: `governance/reports/AIOffice_V2_R17_Final_Report_and_R18_Planning_Report_v1.md`, `state/governance/r17_final_kpi_movement_scorecard.json`, `contracts/governance/r17_final_kpi_movement_scorecard.contract.json`, final evidence package under `state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_028_final_evidence_package/`, final-head support packet `state/final_head_support/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_028_final_head_support_packet.json`, R18 planning brief `governance/plans/AIOffice_V2_R18_Automated_Recovery_Runtime_and_API_Orchestration_Plan_v1.md`, tooling, focused test, and fixtures.
- Done when: the final package validates as a closeout candidate, KPI movement is bounded to committed artifacts, compact failure findings and hard non-claims are preserved, R17 remains active pending operator decision, and no R17 closeout, R18 opening, main merge, external audit acceptance, four exercised A2A cycles, live runtime, API invocation, automatic new-thread creation, no-manual-prompt-transfer success, solved compaction, or solved reliability claim is made.

### `R16-001` Open R16 in repo truth
- Status: done
- Order: 1
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: source branch `release/r15-knowledge-base-agent-identity-memory-raci-foundations`, expected head `3058bd6ed5067c97f744c92b9b9235004f0568b0`, expected tree `045886694b19b90f70f08bcffc0e1b321b5c28a0`, and clean worktree
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`, `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, `governance/DECISION_LOG.md`, `governance/DOCUMENT_AUTHORITY_INDEX.md`
- Durable output: R16 release branch, R16 authority document, 26-task plan, status-surface updates, approved planning artifacts, and opening evidence package under `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/`
- Done when: R16 opens through R16-001 only, R16-002 through R16-026 remain planned only, R13 failed/partial and R14/R15 caveated postures are preserved, and no runtime/product/integration/main-merge/R13-closeout claim is made

### `R16-002` Install approved R16 planning artifacts and authority references
- Status: done
- Order: 2
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-001`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: approved v2 planning reports preserved and linked into authority/status surfaces as planning artifacts only, plus `contracts/governance/r16_planning_authority_reference.contract.json`, `tools/R16PlanningAuthorityReference.psm1`, `tools/validate_r16_planning_authority_reference.ps1`, `tests/test_r16_planning_authority_reference.ps1`, `state/fixtures/valid/governance/r16_planning_authority_reference.valid.json`, invalid fixtures under `state/fixtures/invalid/governance/r16_planning_authority_reference/`, `state/governance/r16_planning_authority_reference.json`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/`
- Done when: planning artifacts are installed, hash-identified, and validated as operator-approved planning artifacts only without treating either report as implementation proof by itself or claiming R16-003/later implementation

### `R16-003` Add R16 KPI baseline and target scorecard
- Status: done
- Order: 3
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-002`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/governance/r16_kpi_baseline_target_scorecard.contract.json`, `tools/R16KpiBaselineTargetScorecard.psm1`, `tools/validate_r16_kpi_baseline_target_scorecard.ps1`, `tests/test_r16_kpi_baseline_target_scorecard.ps1`, `state/fixtures/valid/governance/r16_kpi_baseline_target_scorecard.valid.json`, invalid fixtures under `state/fixtures/invalid/governance/r16_kpi_baseline_target_scorecard/`, `state/governance/r16_kpi_baseline_target_scorecard.json`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_003_kpi_baseline_target_scorecard/`
- Done when: target maturity is recorded without inflating achieved scores, the two priority maturity jumps are explicit, and future R16 implementation overclaims fail validation

### `R16-004` Define memory layer contract
- Status: done
- Order: 4
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-003`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/memory/r16_memory_layer.contract.json`, `tools/R16MemoryLayerContract.psm1`, `tools/validate_r16_memory_layer_contract.ps1`, `tests/test_r16_memory_layer_contract.ps1`, memory contract fixtures, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/`
- Done when: the memory layer contract is explicit and validator-backed as model/contract proof only, with broad scans, wildcard refs, stale refs without caveats, report-as-proof errors, runtime/product/agent/integration overclaims, and R16-005-or-later claims rejected

### `R16-005` Implement deterministic memory layer generator
- Status: done
- Order: 5
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-004`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `tools/R16MemoryLayerGenerator.psm1`, `tools/new_r16_memory_layers.ps1`, `tools/validate_r16_memory_layers.ps1`, `tests/test_r16_memory_layer_generator.ps1`, generated state artifact `state/memory/r16_memory_layers.json`, fixtures under `state/fixtures/valid/memory/` and `state/fixtures/invalid/memory/r16_memory_layers/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/`
- Done when: deterministic baseline memory layers can be generated from bounded repo refs without runtime memory overclaims; generated baseline memory layers are committed state artifacts, not runtime memory

### `R16-006` Add role-specific memory pack model
- Status: done
- Order: 6
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-005`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/memory/r16_role_memory_pack_model.contract.json`, `tools/R16RoleMemoryPackModel.psm1`, `tools/validate_r16_role_memory_pack_model.ps1`, `tests/test_r16_role_memory_pack_model.ps1`, `state/memory/r16_role_memory_pack_model.json`, valid fixture `state/fixtures/valid/memory/r16_role_memory_pack_model.valid.json`, invalid fixtures under `state/fixtures/invalid/memory/r16_role_memory_pack_model/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_006_role_memory_pack_model/`
- Done when: the model defines role catalog, aliases, required/allowed/forbidden layer types, exact memory layer dependencies, source-ref treatment, load priority, ref budgets, stale-ref policy, proof treatment, authority boundaries, forbidden actions, non-claims, and invalid-state rules for Operator, Project Manager, Architect, Developer, QA, Evidence Auditor, Knowledge Curator, and Release/Closeout Agent without generating baseline role memory packs or implementing a role memory pack generator

### `R16-007` Generate baseline memory packs for key roles
- Status: done
- Order: 7
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-006`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `tools/R16RoleMemoryPackGenerator.psm1`, `tools/new_r16_role_memory_packs.ps1`, `tools/validate_r16_role_memory_packs.ps1`, `tests/test_r16_role_memory_pack_generator.ps1`, generated baseline state artifact `state/memory/r16_role_memory_packs.json`, valid fixture `state/fixtures/valid/memory/r16_role_memory_packs.valid.json`, invalid fixtures under `state/fixtures/invalid/memory/r16_role_memory_packs/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/`
- Done when: all eight required roles have bounded deterministic memory packs with exact refs, role policies, load priority, budget categories, proof treatment, stale-ref policy, authority boundaries, forbidden actions, and state-artifact-only non-claims, while invalid role, dependency, source-ref, runtime, agent, integration, later-task, and boundary overclaims fail closed

### `R16-008` Add memory pack validation and stale-ref detection
- Status: done
- Order: 8
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-007`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/memory/r16_memory_pack_validation_report.contract.json`, `tools/R16MemoryPackValidation.psm1`, `tools/test_r16_memory_pack_refs.ps1`, `tools/validate_r16_memory_pack_validation_report.ps1`, `tests/test_r16_memory_pack_validation.ps1`, committed validation report state artifact `state/memory/r16_memory_pack_validation_report.json`, valid fixture `state/fixtures/valid/memory/r16_memory_pack_validation_report.valid.json`, invalid fixtures under `state/fixtures/invalid/memory/r16_memory_pack_validation_report/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/`
- Done when: stale, missing, broad, wildcard, proof-treatment, role-policy, overclaim, later-task, and R13/R14/R15 boundary violations fail closed; accepted stale generated_from boundaries are explicit caveats; and the validation report remains a committed state artifact only, not runtime memory or an artifact/audit/context-load/workflow implementation

### `R16-009` Define artifact map contract
- Status: done
- Order: 9
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-008`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/artifacts/r16_artifact_map.contract.json`, `tools/R16ArtifactMapContract.psm1`, `tools/validate_r16_artifact_map_contract.ps1`, `tests/test_r16_artifact_map_contract.ps1`, fixtures under `tests/fixtures/r16_artifact_map_contract/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_009_artifact_map_contract/`
- Done when: milestone-scoped evidence and authority paths have a machine-checkable map contract shape while generated artifact maps, artifact map generators, audit maps, context-load planners, runtime/product/agent/integration/retrieval/vector overclaims, R16-010 implementation, and R16-027-or-later task claims fail closed

### `R16-010` Implement artifact map generator for milestone scope
- Status: done
- Order: 10
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-009`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `tools/R16ArtifactMapGenerator.psm1`, `tools/new_r16_artifact_map.ps1`, `tools/validate_r16_artifact_map.ps1`, `tests/test_r16_artifact_map_generator.ps1`, `state/artifacts/r16_artifact_map.json`, fixtures under `tests/fixtures/r16_artifact_map_generator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/`
- Done when: the bounded artifact map is generated from curated exact milestone paths, validated fail-closed against overclaims, committed as a generated state artifact only, and not treated as runtime memory, an audit map, a context-load planner, or workflow execution

### `R16-011` Add audit map contract
- Status: done
- Order: 11
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-010`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/audit/r16_audit_map.contract.json`, `tools/R16AuditMapContract.psm1`, `tools/validate_r16_audit_map_contract.ps1`, `tests/test_r16_audit_map_contract.ps1`, fixtures under `tests/fixtures/r16_audit_map_contract/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_011_audit_map_contract/`
- Done when: authority level, evidence path, proof status, proof treatment, caveat, validation command, exact-ref policy, and inspection route fields are machine-checkable while generated audit map, audit map generator, R15/R16 audit map, artifact-map diff/check tooling, context-load planner, role-run envelope, handoff packet, workflow drill, runtime/product/agent/integration, R16-012-or-later implementation, and R16-027-or-later task claims fail closed

### `R16-012` Generate R15/R16 audit map showing exact evidence paths and authority levels
- Status: done
- Order: 12
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-011`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: generated R15/R16 audit map
- Done when: R15/R16 authority and evidence paths can be inspected from exact refs without broad repo scanning

### `R16-013` Add artifact-map diff/check tooling to prevent stale or missing evidence refs
- Status: done
- Order: 13
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-012`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/artifacts/r16_artifact_audit_map_check_report.contract.json`, `tools/R16ArtifactAuditMapCheck.psm1`, `tools/test_r16_artifact_audit_map_refs.ps1`, `tools/validate_r16_artifact_audit_map_check_report.ps1`, `tests/test_r16_artifact_audit_map_check.ps1`, `state/artifacts/r16_artifact_audit_map_check_report.json`, fixtures under `tests/fixtures/r16_artifact_audit_map_check/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_013_artifact_audit_map_check/`
- Done when: stale or missing artifact/audit-map refs fail closed, accepted stale R15 generated_from caveats remain explicit, and the check report remains a committed validation/check report state artifact only

### `R16-014` Define context-load plan contract
- Status: done
- Order: 14
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-013`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/context/r16_context_load_plan.contract.json`, `tools/R16ContextLoadPlanContract.psm1`, `tools/validate_r16_context_load_plan_contract.ps1`, `tests/test_r16_context_load_plan_contract.ps1`, fixtures under `tests/fixtures/r16_context_load_plan_contract/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_014_context_load_plan_contract/`
- Done when: scoped context loading contract fields, exact-path policy, planned budget schema, exclusions, and no-full-repo-scan rules are defined without generating a context-load plan or implementing planner behavior

### `R16-015` Implement exact context-load planner from memory packs and artifact maps
- Status: done
- Order: 15
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-014`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `tools/R16ContextLoadPlanner.psm1`, `tools/new_r16_context_load_plan.ps1`, `tools/validate_r16_context_load_plan.ps1`, `tests/test_r16_context_load_planner.ps1`, generated state artifact `state/context/r16_context_load_plan.json`, fixtures under `tests/fixtures/r16_context_load_planner/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_015_context_load_planner/`
- Done when: planner output ties role memory packs to artifact maps, the R15/R16 audit map, and the R16-013 check report with exact scoped loads while preserving budget-estimator, over-budget-validator, role-run-envelope, handoff, workflow-drill, runtime-memory, retrieval/vector, product-runtime, agent, integration, R13/R14/R15 boundary, and R16-016+ non-claims

### `R16-016` Add context budget estimator with token/cost approximation fields
- Status: done
- Order: 16
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-015`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/context/r16_context_budget_estimate.contract.json`, `tools/R16ContextBudgetEstimator.psm1`, `tools/new_r16_context_budget_estimate.ps1`, `tools/validate_r16_context_budget_estimate.ps1`, `tests/test_r16_context_budget_estimator.ps1`, generated state artifact `state/context/r16_context_budget_estimate.json`, fixtures under `tests/fixtures/r16_context_budget_estimator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_016_context_budget_estimator/`
- Done when: the estimator records approximate token bounds and relative cost proxy units from deterministic local file metrics, validates exact context-load plan paths, preserves R13/R14/R15 boundaries, and rejects exact provider token, exact provider billing, over-budget fail-closed validator, role-run envelope, RACI transition gate, handoff packet, workflow drill, R16-017+ implementation, and broad-scan claims

### `R16-017` Add over-budget fail-closed validation and no-full-repo-scan rules
- Status: done
- Order: 17
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-016`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/context/r16_context_budget_guard.contract.json`, `tools/R16ContextBudgetGuard.psm1`, `tools/test_r16_context_budget_guard.ps1`, `tools/validate_r16_context_budget_guard_report.ps1`, `tests/test_r16_context_budget_guard.ps1`, generated state artifact `state/context/r16_context_budget_guard_report.json`, fixtures under `tests/fixtures/r16_context_budget_guard/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_017_context_budget_guard/`
- Done when: over-budget plans and full-repo scan requests fail closed without exact provider tokenization, exact provider billing, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, solved Codex compaction, solved Codex reliability, role-run envelopes, RACI transition gates, handoff packets, workflow drills, R16-018+ implementation claims, or R13/R14/R15 boundary weakening

### `R16-018` Define role-run envelope contract
- Status: done
- Order: 18
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-017`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/workflow/r16_role_run_envelope.contract.json`, `tools/R16RoleRunEnvelopeContract.psm1`, `tools/validate_r16_role_run_envelope_contract.ps1`, `tests/test_r16_role_run_envelope_contract.ps1`, fixtures under `tests/fixtures/r16_role_run_envelope_contract/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_018_role_run_envelope_contract/`
- Done when: role identity, allowed actions, forbidden actions, required inputs, memory pack refs, context-load plan refs, budget estimate refs, context budget guard refs, evidence refs, output expectations, handoff constraints, and non-claims are machine-checkable while failed_closed_over_budget blocks executable envelopes and no generated envelopes, generator, RACI transition gate, handoff packet, or workflow drill is claimed

### `R16-019` Implement role-run envelope generator for PM, Architect, Developer, QA, Auditor, Knowledge Curator, and Release/Closeout
- Status: done
- Order: 19
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-018`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `tools/R16RoleRunEnvelopeGenerator.psm1`, `tools/new_r16_role_run_envelopes.ps1`, `tools/validate_r16_role_run_envelopes.ps1`, `tests/test_r16_role_run_envelope_generator.ps1`, generated state artifact `state/workflow/r16_role_run_envelopes.json`, compact mutation fixtures under `tests/fixtures/r16_role_run_envelope_generator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_019_role_run_envelope_generator/`
- Done when: bounded role-run envelopes are generated as committed state artifacts only, all envelopes remain non-executable under failed_closed_over_budget, and no runtime agents, RACI transition gate, handoff packet, workflow drill, R16-020+ implementation, or R13/R14/R15 boundary weakening is claimed

### `R16-020` Add RACI transition gate validator using role-run envelope, card state, required evidence, and allowed actions
- Status: done
- Order: 20
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-019`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/workflow/r16_raci_transition_gate_report.contract.json`, `tools/R16RaciTransitionGate.psm1`, `tools/test_r16_raci_transition_gate.ps1`, `tools/validate_r16_raci_transition_gate_report.ps1`, `tests/test_r16_raci_transition_gate.ps1`, generated state artifact `state/workflow/r16_raci_transition_gate_report.json`, fixtures under `tests/fixtures/r16_raci_transition_gate/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_020_raci_transition_gate/`
- Done when: bounded RACI transition gate validation/reporting exists, invalid role, state, evidence, or allowed-action transitions fail closed, all evaluated transitions are blocked while the guard remains `failed_closed_over_budget` and envelopes remain non-executable, and no executable transition, handoff packet generation, workflow drill, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, or R16-021+ implementation is claimed

### `R16-021` Add handoff packet generator tying card state, role, memory pack, context-load plan, and evidence refs together
- Status: done
- Order: 21
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-020`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/workflow/r16_handoff_packet_report.contract.json`, `tools/R16HandoffPacketGenerator.psm1`, `tools/new_r16_handoff_packets.ps1`, `tools/validate_r16_handoff_packet_report.ps1`, `tests/test_r16_handoff_packet_generator.ps1`, generated state artifact `state/workflow/r16_handoff_packet_report.json`, fixtures under `tests/fixtures/r16_handoff_packet_generator/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_021_handoff_packet_generator/`
- Done when: bounded handoff packet generation/reporting exists, generated handoff packets tie card state, role, memory pack, context-load plan, transition gate decision, and evidence refs together with exact paths, all generated handoff packets remain blocked/not executable while the R16-020 transition gate blocks all evaluated transitions and the guard remains `failed_closed_over_budget`, and no executable handoff, workflow drill, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, solved Codex compaction, solved Codex reliability, or R16-022+ implementation is claimed

### `R16-022` Run bounded Codex restart/compaction recovery drill using memory pack plus artifact map
- Status: done
- Order: 22
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-021`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/workflow/r16_restart_compaction_recovery_drill.contract.json`, `tools/R16RestartCompactionRecoveryDrill.psm1`, `tools/new_r16_restart_compaction_recovery_drill.ps1`, `tools/validate_r16_restart_compaction_recovery_drill.ps1`, `tests/test_r16_restart_compaction_recovery_drill.ps1`, generated state artifact `state/workflow/r16_restart_compaction_recovery_drill.json`, fixtures under `tests/fixtures/r16_restart_compaction_recovery_drill/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_022_restart_compaction_recovery_drill/`
- Done when: bounded restart/compaction recovery drill reporting exists as a committed state artifact only, uses exact repo-backed inputs only, records exact recovery input count 11, treats raw chat history as non-canonical, does not use a full repo scan, keeps the guard `failed_closed_over_budget`, keeps handoffs blocked/not executable, and makes no runtime memory, retrieval/vector runtime, product runtime, autonomous recovery, autonomous agents, external integrations, executable handoff, executable transition, solved Codex compaction, solved Codex reliability, R16-023+ implementation, or R13/R14/R15 boundary weakening claim

### `R16-023` Run bounded role-handoff drill from PM to Developer to QA to Auditor using generated handoff packets
- Status: done
- Order: 23
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-022`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/workflow/r16_role_handoff_drill.contract.json`, `tools/R16RoleHandoffDrill.psm1`, `tools/new_r16_role_handoff_drill.ps1`, `tools/validate_r16_role_handoff_drill.ps1`, `tests/test_r16_role_handoff_drill.ps1`, generated state artifact `state/workflow/r16_role_handoff_drill.json`, fixtures under `tests/fixtures/r16_role_handoff_drill/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_023_role_handoff_drill/`
- Done when: bounded role-handoff drill reporting exists as a committed state artifact only, records the `project_manager -> developer -> qa -> evidence_auditor` role handoff chain, keeps all core handoffs blocked/not executable because the R16-020 transition gate blocks transitions and the R16-017 guard remains `failed_closed_over_budget`, and makes no runtime handoff execution, executable handoff, executable transition, autonomous agent, autonomous recovery, runtime memory, retrieval/vector runtime, product runtime, external integration, solved Codex compaction, solved Codex reliability, R16-024+ implementation, or R13/R14/R15 boundary weakening claim

### `R16-024` Run bounded audit-readiness drill proving evidence can be inspected through audit map without broad repo scanning
- Status: done
- Order: 24
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-023`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/audit/r16_audit_readiness_drill.contract.json`, `tools/R16AuditReadinessDrill.psm1`, `tools/new_r16_audit_readiness_drill.ps1`, `tools/validate_r16_audit_readiness_drill.ps1`, `tests/test_r16_audit_readiness_drill.ps1`, generated state artifact `state/audit/r16_audit_readiness_drill.json`, fixtures under `tests/fixtures/r16_audit_readiness_drill/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_024_audit_readiness_drill/`
- Done when: bounded audit-readiness drill reporting exists as a committed state artifact only, evidence inspection works through exact audit/artifact map refs and proof-review refs without broad/full repo scanning, exact audit input count is 12, proof-review ref count is 5, evidence inspection route count is 7, raw chat history is not canonical evidence, the guard remains `failed_closed_over_budget`, executable handoffs and executable transitions remain zero, and no final audit acceptance, closeout completion, final proof package completion, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, solved Codex compaction, solved Codex reliability, R16-025+ implementation, or R13/R14/R15 boundary weakening claim is made

### `R16-025` Capture friction metrics: loaded files, exact refs, manual steps, context budget, restart recovery steps, stale-ref findings
- Status: done
- Order: 25
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-024`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/governance/r16_friction_metrics_report.contract.json`, `tools/R16FrictionMetricsReport.psm1`, `tools/new_r16_friction_metrics_report.ps1`, `tools/validate_r16_friction_metrics_report.ps1`, `tests/test_r16_friction_metrics_report.ps1`, generated state artifact `state/governance/r16_friction_metrics_report.json`, fixtures under `tests/fixtures/r16_friction_metrics_report/`, and proof-review package `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_025_friction_metrics_report/`
- Done when: bounded friction metrics reporting exists as a committed generated state artifact only, captures operational friction and context-pressure findings for final R16 audit and next-milestone planning, records Codex auto-compaction failures as operator-observed process evidence rather than machine proof, captures fixture bloat and compact fixture mitigation, captures the untracked-file visibility gap, captures deterministic byte/line drift and regeneration cascade cost, keeps the guard `failed_closed_over_budget` as an expected unresolved signal, and makes no final audit acceptance, closeout completion, final proof package completion, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, executable handoff, executable transition, solved Codex compaction, solved Codex reliability, R16-026 implementation, or R13/R14/R15 boundary weakening claim

### `R16-026` Produce R16 final proof/review package and final-head support packet
- Status: done
- Order: 26
- Milestone: `R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation`
- Depends on: `R16-025`
- Authority: `governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md`
- Durable output: `contracts/governance/r16_final_proof_review_package.contract.json`, `tools/R16FinalProofReviewPackage.psm1`, `tools/new_r16_final_proof_review_package.ps1`, `tools/validate_r16_final_proof_review_package.ps1`, `tests/test_r16_final_proof_review_package.ps1`, fixtures under `tests/fixtures/r16_final_proof_review_package/`, generated final proof/review package candidate `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/r16_final_proof_review_package.json`, generated final evidence index `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json`, final-head support packet `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/final_head_support_packet.json`, and validation manifest `state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/validation_manifest.md`
- Done when: R16-001 through R16-025 evidence refs are indexed, the generated final proof/review package candidate and final-head support packet validate, non-claims are preserved, R13/R14/R15 boundaries remain intact, and no external-audit-acceptance/main-merge/runtime/product/agent/integration/executable-handoff/executable-transition/solved-Codex overclaims are made

### `R15-001` Open R15 in repo truth
- Status: done
- Order: 1
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: accepted-with-caveats R14 posture, source R14 head `43653f3dd2e18b46c9e7b02f0c9c095848aee6fc`, and source R14 tree observed locally as `2af1a4aaa858af315e9b4d106d0643b5ce4ebfcc`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, `governance/DECISION_LOG.md`
- Durable output: R15 release branch, R15 authority document, R15 task plan, status-surface updates, and opening evidence package under `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/opening/`
- Done when: R15 opens as a foundation milestone only, R13 remains failed/partial and not closed, R14 remains accepted narrowly through R14-006, and no R15 implementation beyond R15-001 is claimed

### `R15-002` Define artifact classification taxonomy
- Status: done
- Order: 2
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-001`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/knowledge/artifact_classification_taxonomy.contract.json`, `tools/R15ArtifactClassificationTaxonomy.psm1`, `tools/validate_r15_artifact_classification_taxonomy.ps1`, `tests/test_r15_artifact_classification_taxonomy.ps1`
- Durable output: artifact classification taxonomy contract, validator module, CLI wrapper, valid/invalid fixtures, committed taxonomy artifact, validation manifest, and R15-002 evidence folder
- Done when: taxonomy validation and focused tests pass, status surfaces record R15 active through R15-002 only at the R15-002 boundary, and no R15-004 or later implementation is claimed

### `R15-003` Create repo knowledge index model
- Status: done
- Order: 3
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-002`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/knowledge/repo_knowledge_index.contract.json`, `tools/R15RepoKnowledgeIndex.psm1`, `tools/validate_r15_repo_knowledge_index.ps1`, `tests/test_r15_repo_knowledge_index.ps1`
- Durable output: repo knowledge index contract, validator module, CLI wrapper, valid/invalid fixtures, bounded seed index artifact, validation manifest, and R15-003 evidence folder
- Done when: repo knowledge index validation and focused tests passed at the R15-003 boundary and no full repo index or knowledge-base engine is claimed

### `R15-004` Define agent identity packet model
- Status: done
- Order: 4
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-003`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/agents/agent_identity_packet.contract.json`, `tools/R15AgentIdentityPacket.psm1`, `tools/validate_r15_agent_identity_packet.ps1`, `tests/test_r15_agent_identity_packet.ps1`
- Durable output: agent identity packet contract, validator module, CLI wrapper, valid/invalid fixtures, baseline packet set, validation manifest, bounded knowledge index entries, and R15-004 evidence folder
- Done when: agent identity packet validation and focused tests pass, status surfaces recorded R15 active through R15-004 only at the R15-004 boundary, R15-005 through R15-009 remained planned only at that boundary, and no actual agent runtime, memory engine, RACI matrix, board routing, or R16 opening was claimed

### `R15-005` Define agent memory scope model
- Status: done
- Order: 5
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-004`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/agents/agent_memory_scope.contract.json`, `tools/R15AgentMemoryScope.psm1`, `tools/validate_r15_agent_memory_scope.ps1`, `tests/test_r15_agent_memory_scope.ps1`
- Durable output: agent memory scope contract, validator module, CLI wrapper, valid/invalid fixtures, baseline memory scope model, validation manifest, bounded knowledge index entries, and R15-005 evidence folder
- Done when: agent memory scope validation and focused tests pass, status surfaces recorded R15 active through R15-005 only at the R15-005 boundary, R15-006 through R15-009 remained planned only at that boundary, and no agent runtime, persistent memory engine, runtime memory loading, retrieval, vector search, RACI matrix, card re-entry packet, integration, product runtime, or R16 opening was claimed

### `R15-006` Define RACI and state-transition matrix
- Status: done
- Order: 6
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-005`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/agents/raci_state_transition_matrix.contract.json`, `tools/R15RaciStateTransitionMatrix.psm1`, `tools/validate_r15_raci_state_transition_matrix.ps1`, `tests/test_r15_raci_state_transition_matrix.ps1`
- Durable output: RACI/state-transition matrix contract, validator module, CLI wrapper, valid/invalid fixtures, baseline matrix model, validation manifest, bounded knowledge index entries, and R15-006 evidence folder
- Done when: RACI and state-transition validation and focused tests pass, the R15-006 boundary was recorded without agent runtime, board routing runtime, PM automation, actual workflow execution, card re-entry runtime, integration, product runtime, or R16 opening claims, and status surfaces preserved R15-008 through R15-009 planned only at that boundary

### `R15-007` Define card re-entry packet model
- Status: done
- Order: 7
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-006`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/agents/card_reentry_packet.contract.json`, `tools/R15CardReentryPacket.psm1`, `tools/validate_r15_card_reentry_packet.ps1`, `tests/test_r15_card_reentry_packet.ps1`
- Durable output: card re-entry packet contract, validator module, CLI wrapper, valid/invalid fixtures, baseline packet model, validation manifest, bounded knowledge index entries, and R15-007 evidence folder
- Done when: card re-entry packet validation and focused tests pass, status surfaces recorded R15 active through R15-007 only at the R15-007 boundary, R15-008 through R15-009 remained planned only at that boundary, and no agent runtime, memory runtime, retrieval engine, vector search, board routing runtime, card re-entry runtime, dry run, product runtime, integration, or R16 opening was claimed

### `R15-008` Run one classification and re-entry dry run
- Status: done
- Order: 8
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-007`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `contracts/agents/classification_reentry_dry_run.contract.json`, `tools/R15ClassificationReentryDryRun.psm1`, `tools/validate_r15_classification_reentry_dry_run.ps1`, `tests/test_r15_classification_reentry_dry_run.ps1`
- Durable output: bounded classification/re-entry dry-run contract, validator module, CLI wrapper, valid/invalid fixtures, committed dry-run artifact, validation manifest, bounded knowledge index entries, and R15-008 evidence folder
- Done when: one bounded R14 evidence slice is classified with exact knowledge-index refs, evidence-auditor role selection, memory-scope constraints, RACI transition constraints, a model-only card re-entry packet output, and explicit dry-run/runtime distinction, while R15-009 remained planned only at the R15-008 boundary

### `R15-009` Produce R15 proof/review package
- Status: done
- Order: 9
- Milestone: `R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations`
- Depends on: `R15-008`
- Authority: `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md`, `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/`, `governance/reports/AIOffice_V2_R15_Proof_Review_Package_and_R16_Readiness_Recommendation_v1.md`
- Durable output: final bounded R15 proof/review package, evidence index, validation manifest, non-claims, rejected claims, next-stage recommendation, operator report, bounded knowledge index entries, and status-surface updates
- Done when: R15-001 through R15-009 evidence is consolidated, final validation passes, R15 is marked complete through R15-009 for audit review, R13 failed/partial and R14 caveated postures are preserved, and no R16 opening, main merge, runtime, integration, or product runtime claim is made

### `R14-001` Open R14 in repo truth
- Status: done
- Order: 1
- Milestone: `R14 Product Vision Pivot and Governance Enforcement`
- Depends on: explicit operator approval of the post-R13 product vision pivot strategy after R13-018, starting head `d3123256e83505098ee13829648f0f6e531f96ef`, and starting tree `6ebd9940929667c6b31533d4a2b9f8b677389fce`
- Authority: `governance/R14_PRODUCT_VISION_PIVOT_AND_GOVERNANCE_ENFORCEMENT.md`, `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, `governance/DECISION_LOG.md`
- Durable output: R14 release branch, R14 boundary, task plan, R13 failed/partial preservation, and R15 non-opening posture
- Done when: R14 opens as documentation/governance/reporting enforcement only, R13 remains failed/partial and not closed, and no product runtime or R15 opening is claimed

### `R14-002` Install approved pivot documents
- Status: done
- Order: 2
- Milestone: `R14 Product Vision Pivot and Governance Enforcement`
- Depends on: `R14-001`
- Authority: `governance/_operator_inbox/aioffice_vision_update/`, `state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/source_pack_inventory.json`, `state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/document_inventory.json`
- Durable output: every approved source-pack file installed by source-pack mapping rules, source pack preserved in inbox, hashes recorded, and overwrites recorded
- Done when: every source-pack file is inventoried, mapped, installed or intentionally preserved, and no unmapped file is silently dropped

### `R14-003` Add document authority index
- Status: done
- Order: 3
- Milestone: `R14 Product Vision Pivot and Governance Enforcement`
- Depends on: `R14-002`
- Authority: `governance/DOCUMENT_AUTHORITY_INDEX.md`
- Durable output: document authority classes A through H, current major document ownership, proof treatment, dependencies, and replacement/deprecation notes
- Done when: generated Markdown and reports are explicitly classified as operator artifacts unless backed by committed machine evidence

### `R14-004` Add lightweight reporting standard enforcement
- Status: done
- Order: 4
- Milestone: `R14 Product Vision Pivot and Governance Enforcement`
- Depends on: `R14-003`
- Authority: `tools/validate_milestone_reporting_standard.ps1`, `tests/test_milestone_reporting_standard.ps1`
- Durable output: validator and focused test for required reporting-standard files, required section text, and operator-artifact versus machine-evidence distinction
- Done when: the validator checks the milestone reporting standard, KPI model, report template, document authority index, required report sections, and artifact boundary without becoming a full reporting engine

### `R14-005` Add R14 validation/evidence package
- Status: done
- Order: 5
- Milestone: `R14 Product Vision Pivot and Governance Enforcement`
- Depends on: `R14-004`
- Authority: `state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/`
- Durable output: README, validation manifest, source-pack inventory, document inventory, non-claims, and validation summary
- Done when: the package lists source files, installed documents, overwrites, preserved inbox files, updated status files, validation commands, results, R13 failed/partial preservation, explicit non-claims, and no R15 opening

### `R14-006` Produce R14 closeout and R15 planning brief
- Status: done
- Order: 6
- Milestone: `R14 Product Vision Pivot and Governance Enforcement`
- Depends on: `R14-005`
- Authority: `governance/reports/AIOffice_V2_R14_Pivot_Closeout_and_R15_Planning_Brief_v1.md`
- Durable output: R14 operator closeout and planning-only R15 recommendation
- Done when: the report includes required R14 closeout sections, recommends R15 planning direction only, does not open R15, and does not create active R15 tasks

### `R13-001` Open R13 and freeze hard value gates
- Status: done
- Order: 1
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: report-committed R12 head `9ad475faa87746cb3d6ef074545e4b703e77e786`, planning report `governance/reports/AIOffice_V2_R12_Audit_and_R13_Planning_Report_v1.md`, and verified clean branch truth
- Authority: `governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md`, `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, `governance/DECISION_LOG.md`
- Durable output: R13 release branch, frozen hard gates, R13 task plan, explicit non-claims, and no-successor posture
- Done when: R13 opens narrowly from the report-committed R12 source, R12 remains closed narrowly, no R13 hard value gate is delivered by the opening slice, and no R14 or successor milestone is opened

### `R13-002` Define ideal QA lifecycle contract
- Status: done
- Order: 2
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-001`
- Authority: `contracts/actionable_qa/r13_qa_lifecycle.contract.json`, `tools/R13QaLifecycle.psm1`, `tools/validate_r13_qa_lifecycle.ps1`, `state/fixtures/valid/actionable_qa/r13_qa_lifecycle.valid.json`, `state/fixtures/invalid/actionable_qa/r13_qa_lifecycle/`, and `tests/test_r13_qa_lifecycle.ps1`
- Durable output: QA lifecycle contract plus validator, CLI, valid initialized fixture, and invalid fixtures for pass-without-rerun, pass-without-fix, pass-without-evidence, narrative-only QA, executor self-certification, local-only external proof, missing operator summary, unresolved blocking issues as pass, missing non-claims, and R14 successor opening
- Done when: schema validation, static lint, test execution, external replay, and operator usefulness are distinct; invalid narrative-only or no-evidence QA states fail closed; signed-off states cannot pass without fix evidence, rerun, before/after comparison, external replay, and operator summary; and R13 remains active through `R13-002` only with no hard value gate delivered

### `R13-003` Build actionable QA issue detector v2
- Status: done
- Order: 3
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-002`
- Authority: `contracts/actionable_qa/r13_qa_issue_detection_report.contract.json`, `tools/R13QaIssueDetector.psm1`, `tools/invoke_r13_qa_issue_detector.ps1`, `tools/validate_r13_qa_issue_detection_report.ps1`, `state/fixtures/valid/actionable_qa/r13_qa_issue_detection_report.clean.valid.json`, `state/fixtures/valid/actionable_qa/r13_qa_issue_detection_report.with_issues.valid.json`, invalid report fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_issue_detector/`, seeded detector inputs under `state/fixtures/invalid/actionable_qa/r13_detector_inputs/`, `tests/test_r13_qa_issue_detector.ps1`, and `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json`
- Durable output: source-mapped issue detector v2 only, with severity, component, file path, line when available, reproduction command, expected behavior, observed behavior, recommended fix, evidence refs, explicit PSScriptAnalyzer dependency status, safe-scope refusal, and seeded invalid-input proof
- Done when: selected repo paths are inspected, PSScriptAnalyzer absence is explicit, malformed JSON, missing evidence refs, missing reproduction commands, narrative-only QA, executor self-certification, local-only external proof, missing recommended fixes, hidden unresolved blocking issues, and stale identity are detected from controlled fixtures, and the task does not claim fix queue, bounded fix execution, rerun, comparison, external replay, current control room, signoff, meaningful QA loop, or any R13 hard value gate

### `R13-004` Build QA fix queue and fix-plan generator v2
- Status: done
- Order: 4
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-003`
- Authority: `contracts/actionable_qa/r13_qa_fix_queue.contract.json`, `tools/R13QaFixQueue.psm1`, `tools/export_r13_qa_fix_queue.ps1`, `tools/validate_r13_qa_fix_queue.ps1`, `state/fixtures/valid/actionable_qa/r13_qa_fix_queue.ready.valid.json`, `state/fixtures/valid/actionable_qa/r13_qa_fix_queue.blocked.valid.json`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_fix_queue/`, `tests/test_r13_qa_fix_queue.ps1`, and `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json`
- Durable output: blocking issue to bounded fix/no-fix item mapping with target files, allowed commands, validation commands, risk, rollback notes, and expected future evidence refs
- Done when: every R13-003 blocking issue maps to a bounded fix item or explicit no-fix item, orphan fix items and hidden blocking issues are rejected, and the queue does not claim fix execution, rerun, comparison, external replay, signoff, meaningful QA loop delivery, or any R13 hard value gate

### `R13-005` Implement bounded fix execution packet model
- Status: done
- Order: 5
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-004`
- Authority: `contracts/actionable_qa/r13_bounded_fix_execution.contract.json`, `tools/R13BoundedFixExecution.psm1`, `tools/new_r13_bounded_fix_execution_packet.ps1`, `tools/validate_r13_bounded_fix_execution.ps1`, `state/fixtures/valid/actionable_qa/r13_bounded_fix_execution.authorization.valid.json`, `state/fixtures/valid/actionable_qa/r13_bounded_fix_execution.dry_run.valid.json`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_bounded_fix_execution/`, `tests/test_r13_bounded_fix_execution.ps1`, and `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json`
- Durable output: bounded authorization/dry-run packet model for future fix execution, preserving selected fix items, selected source issues, target files, allowed commands, validation commands, rollback plans, and expected future evidence refs
- Done when: unqueued fixes, source/fix ID mismatch, outside-repo targets, broad scope without explicit authorization, missing rollback or validation evidence, executor self-certification, local-only external proof, premature rerun/comparison/external replay/signoff/hard-gate claims, and R14/successor opening are rejected without executing fixes

### `R13-006` Run one real seeded QA failure through the full loop
- Status: done
- Order: 6
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-005`
- Authority: `contracts/actionable_qa/r13_qa_failure_fix_cycle.contract.json`, `contracts/actionable_qa/r13_fix_execution_result.contract.json`, `contracts/actionable_qa/r13_qa_before_after_comparison.contract.json`, `tools/R13QaFailureFixCycle.psm1`, `tools/run_r13_qa_failure_fix_cycle.ps1`, `tools/validate_r13_fix_execution_result.ps1`, `tools/validate_r13_qa_before_after_comparison.ps1`, `tools/validate_r13_qa_failure_fix_cycle.ps1`, valid fixtures under `state/fixtures/valid/actionable_qa/`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_failure_fix_cycle/`, `tests/test_r13_qa_failure_fix_cycle.ps1`, and evidence under `state/cycles/r13_qa_cycle_demo/`
- Durable output: one controlled seeded malformed JSON defect copied into a demo before file, bounded demo after repair, before/after detector reports, fix execution result, before/after comparison, cycle summary, and validation manifest
- Done when: before/after QA movement is proved with committed demo evidence, canonical invalid fixtures remain unchanged, and no external replay, final signoff, hard R13 value gate, or R14/successor opening is claimed

### `R13-007` Add API/custom-runner execution path foundation
- Status: done
- Order: 7
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-006`
- Authority: `contracts/runner/r13_custom_runner_request.contract.json`, `contracts/runner/r13_custom_runner_result.contract.json`, `tools/R13CustomRunner.psm1`, `tools/invoke_r13_custom_runner.ps1`, `tools/validate_r13_custom_runner_request.ps1`, `tools/validate_r13_custom_runner_result.ps1`, valid fixtures under `state/fixtures/valid/runner/`, invalid fixtures under `state/fixtures/invalid/runner/r13_custom_runner/`, `tests/test_r13_custom_runner.ps1`, and evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/`
- Durable output: local API-shaped/custom-runner request packet in, bounded non-mutating validation command execution, result packet out, raw logs, preserved evidence refs, and fail-closed unsafe command handling
- Done when: a bounded runner request over existing R13-006 evidence records a passed result packet with command results and raw logs, mutation commands are refused, dependency or strict-identity failures can be represented as blocked results, and no production runtime, skill invocation, external replay, control-room delivery, operator demo, final signoff, hard gate, R14, or successor claim is made

### `R13-008` Add skill registry and skill invocation evidence
- Status: done
- Order: 8
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-007`
- Authority: `contracts/skills/r13_skill_registry.contract.json`, `contracts/skills/r13_skill_invocation_request.contract.json`, `contracts/skills/r13_skill_invocation_result.contract.json`, `tools/R13SkillRegistry.psm1`, `tools/R13SkillInvocation.psm1`, `tools/validate_r13_skill_registry.ps1`, `tools/validate_r13_skill_invocation_request.ps1`, `tools/validate_r13_skill_invocation_result.ps1`, `tools/invoke_r13_skill.ps1`, valid fixtures under `state/fixtures/valid/skills/`, invalid fixtures under `state/fixtures/invalid/skills/r13_skill_invocation/`, `tests/test_r13_skill_registry_and_invocation.ps1`, and evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/`
- Durable output: `qa.detect`, `qa.fix_plan`, `runner.external_replay`, and `control_room.refresh` skill registry entries plus two real bounded invocation request/result packets and raw logs
- Done when: `qa.detect` and `qa.fix_plan` produce durable evidence refs, `runner.external_replay` and `control_room.refresh` remain registered but not executed, and no broad autonomous agent, external replay, current control-room, final signoff, hard gate, R14, or successor claim is made

### `R13-009` Make control room current and cycle-aware
- Status: done
- Order: 9
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-008`
- Authority: `contracts/control_room/r13_control_room_status.contract.json`, `contracts/control_room/r13_control_room_view.contract.json`, `contracts/control_room/r13_control_room_refresh_result.contract.json`, `tools/R13ControlRoomStatus.psm1`, `tools/render_r13_control_room_view.ps1`, `tools/refresh_r13_control_room.ps1`, `tools/validate_r13_control_room_status.ps1`, `tools/validate_r13_control_room_view.ps1`, `tools/validate_r13_control_room_refresh_result.ps1`, `tests/test_r13_control_room_status.ps1`, and current artifacts under `state/control_room/r13_current/`
- Durable output: current branch/head/tree, active milestone and scope, completed `R13-001` through `R13-009`, planned `R13-010` through `R13-018`, hard gate posture, QA pipeline posture, runner/custom-runner posture, skill invocation posture, external replay posture, blockers, attention items, next legal action, operator decisions, evidence refs, non-claims, and validation manifest
- Done when: stale source state is refused and the control-room status, Markdown view, refresh result, and validation manifest reflect current branch/head/tree and exact R13 evidence without claiming a fully delivered hard gate

### `R13-010` Add operator demo artifact
- Status: done
- Order: 10
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-009`
- Authority: `contracts/control_room/r13_operator_demo.contract.json`, `tools/render_r13_operator_demo.ps1`, `tools/validate_r13_operator_demo.ps1`, `tests/test_r13_operator_demo.ps1`, `state/control_room/r13_current/operator_demo.md`, and `state/control_room/r13_current/operator_demo_validation_manifest.md`
- Durable output: human-readable demo report with actual QA failure-to-fix cycle evidence, current control-room posture, runner posture, skill invocation posture, blockers, next legal action, exact evidence refs, and non-claims
- Done when: the operator can understand the current pipeline without reading raw JSON first and the artifact validates without claiming external replay, final signoff, hard gate delivery, productized UI, production runtime, R14, or any successor

### `R13-011` Run external replay after QA fix loop
- Status: done
- Order: 11
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-010`
- Authority: external replay request/result/import contracts, imported external replay evidence, blocked dispatch evidence, and manual dispatch packet
- Durable output: exact request head/tree, passed external replay result packet, import packet, imported artifact root, blocked dispatch command results, manual dispatch packet, raw logs, and validation manifest
- Done when: actual external run evidence exists and imports cleanly, or unavailable dispatch fails closed without claiming proof. R13-011 is now passed/evidenced through run `25241730946`, artifact `6759970924`, digest `sha256:50bc3e28d47c5aca5c4ff6a5e595a967c3aa4153c6611dd20e09f47864ee3769`, observed head `4787d5a59c67d5312ed72231f7a5571b435c1528`, observed tree `f76567051d8b830a6153374b7d60376cf923e7bd`, and 10/10 passed command results; no final QA signoff is claimed.

### `R13-012` Add meaningful QA signoff gate
- Status: done
- Order: 12
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-011`
- Authority: `contracts/actionable_qa/r13_meaningful_qa_signoff.contract.json`, `contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json`, `tools/R13MeaningfulQaSignoff.psm1`, `tools/new_r13_meaningful_qa_signoff.ps1`, `tools/validate_r13_meaningful_qa_signoff.ps1`, `tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1`, `tests/test_r13_meaningful_qa_signoff.ps1`, `state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json`, `state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json`, and `state/signoff/r13_meaningful_qa_signoff/validation_manifest.md`
- Durable output: bounded signoff gate requiring detector, fix queue, bounded fix evidence, rerun, comparison, external replay evidence, current control-room status, operator demo evidence, explicit residual risks, and no blockers for the bounded signoff scope
- Done when: valid bounded signoff passes; missing external replay, stale control-room status, missing operator demo, missing evidence matrix, product-wide QA claim, production runtime claim, R13 closeout claim, and R14/successor claim fail validation

### `R13-013` Add Codex-compaction mitigation proof
- Status: done
- Order: 13
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-012`
- Authority: `contracts/continuity/r13_compaction_mitigation_packet.contract.json`, `contracts/continuity/r13_restart_prompt.contract.json`, `tools/R13CompactionMitigation.psm1`, `tools/new_r13_compaction_mitigation_packet.ps1`, `tools/validate_r13_compaction_mitigation_packet.ps1`, `tools/validate_r13_restart_prompt.ps1`, `tests/test_r13_compaction_mitigation.ps1`, `state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json`, `state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json`, `state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md`, and `state/continuity/r13_compaction_mitigation/validation_manifest.md`
- Durable output: bounded repo-truth continuity mitigation packet, restart prompt, and identity reconciliation for the R13-013 boundary, including signoff generation head `fb2179bb7b66d3d7dd1fd4eb2683aed825f01577`, durable R13-012 commit head `9f80291b0f3049ec1dd15635079705db031383fd`, and verdict `accepted_as_generation_identity_not_current_identity`
- Done when: the proof recovers current branch/head/tree, active task, planned task range, QA state, external replay state, control-room state, next legal action, forbidden actions, and non-claims from repo evidence, while remaining bounded repo-truth continuity mitigation only and not claiming Codex compaction is solved generally

### `R13-014` Produce R13 cycle evidence package
- Status: done
- Order: 14
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-013`
- Authority: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/evidence/r13_014_cycle_evidence_package.json`, `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/evidence/r13_014_validation_manifest.md`, and `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/operator/r13_014_operator_decision_packet.json`
- Durable output: consolidated QA lifecycle, issue report, fix queue, bounded fix packet, rerun, comparison, skill invocations, runner packets, external replay evidence, control-room demo, restart proof, and operator decision packet refs
- Done when: the R13 cycle package commits all evidence refs under the R13 cycle package root, distinguishes evidence categories, preserves non-claims, keeps R13 open, leaves R13-015 planned only, and opens no R14 or successor milestone

### `R13-015` Update Vision Control scoring with calculable evidence
- Status: done
- Order: 15
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-014`
- Authority: approved formula from `governance/reports/AIOffice_V2_R12_Audit_and_R13_Planning_Report_v1.md`, `contracts/vision_control/r13_vision_control_scorecard.contract.json`, `tools/R13VisionControlScorecard.psm1`, `tools/validate_r13_vision_control_scorecard.ps1`, `tests/test_r13_vision_control_scorecard.ps1`, `state/vision_control/r13_015_vision_control_scorecard.json`, and `state/vision_control/r13_015_validation_manifest.md`
- Durable output: R13 scoring with evidence-backed dimensions and penalties, R13 aggregate `51.9`, uplift `3.7` from prior reported R12 aggregate and `5.7` from recomputed R12 item-row aggregate, and no 10 to 15 percent progress claim
- Done when: scoring is calculable and not inflated beyond committed evidence

### `R13-016` Generate R13 final audit candidate packet
- Status: done
- Order: 16
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-015`
- Authority: `governance/reports/AIOffice_V2_R13_Final_Audit_Candidate_Packet_v1.md`
- Durable output: passed/partial gates, exact evidence refs, non-claims, operator demo usefulness, manual burden assessment, Vision Control score posture, and explicit closeout block
- Done when: the packet is candidate-only, preserves partial gate posture, keeps R13 open, does not start R13-017 or R13-018, and does not open R14 or a successor

### `R13-017` Close R13 narrowly only if all hard gates pass
- Status: done
- Order: 17
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-016`
- Authority: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/operator/r13_017_closeout_decision_packet.json`, `state/vision_control/r13_015_vision_control_scorecard.json`, and `governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md`
- Durable output: fail-closed closeout eligibility decision that keeps R13 open because committed evidence does not prove all hard gates pass
- Done when: closeout is rejected from committed evidence, the four partial gates remain partial, no two-phase final-head support runs, R13 is not closed, R13-018 remained planned only at the R13-017 acceptance boundary, and no R14 is opened

### `R13-018` Produce R13 final failed/partial report and conditional successor recommendation
- Status: done
- Order: 18
- Milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- Depends on: `R13-017`
- Authority: `governance/reports/AIOffice_V2_R13_Final_Failed_Partial_Report_and_Conditional_Successor_Recommendation_v1.md`
- Durable output: R13 final failed/partial report with Vision Control Table R6 through R13, explicit 10 to 15 percent progress failure statement, preserved R13-017 fail-closed closeout block, and conditional successor recommendation that does not open R14 or any successor
- Done when: report exists as an operator artifact only, R13 remains open, the four partial gates remain partial, no final-head support or closeout package is created, no merge to main occurs, and no R14 or successor milestone is opened

### `R12-001` Open R12 on a proper release branch and freeze value gates
- Status: done
- Order: 1
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: R11 final accepted closeout head `c3bcdf803c0370db66eaa0a9227b3c2301b28fa2`, planning-report commit `5aa08904b02663a5549d2c8a21971544476ae805`, and verified clean branch truth
- Authority: `governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md`, `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, `governance/DECISION_LOG.md`
- Durable output: R12 release branch, frozen value gates, explicit non-claims, and no-successor posture
- Done when: R12 is active only through `R12-001` before later Phase A work, R10 and R11 remain closed, R9 remains historical and unchanged, R13 is not opened, and status docs do not imply value gates are delivered

### `R12-002` Add honest KPI/value scorecard foundation
- Status: done
- Order: 2
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-001`
- Authority: `contracts/value_scorecard/r12_value_scorecard.contract.json`, `tools/ValueScorecard.psm1`, `tools/update_value_scorecard.ps1`, `state/value_scorecards/r12_baseline.json`, `state/fixtures/valid/value_scorecard/`, `state/fixtures/invalid/value_scorecard/`, `tests/test_value_scorecard.ps1`
- Durable output: scorecard contract, validator module, CLI wrapper, baseline scorecard, valid fixture, invalid overclaim/missing-proof/target-as-proved/weight-drift fixtures, and focused tests
- Done when: baseline and valid fixtures validate, invalid overclaim/missing-proof/target-as-proved/weight-drift fixtures fail, corrected weights match the operator-value model, and the scorecard separates baseline, target, and proved scores without allowing 10 percent or larger uplift unless all four value gates are proved

### `R12-003` Define R12 operating-loop contract
- Status: done
- Order: 3
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-002`
- Authority: `contracts/operating_loop/r12_operating_loop.contract.json`, `tools/OperatingLoop.psm1`, `tools/validate_operating_loop.ps1`, `state/fixtures/valid/operating_loop/`, `state/fixtures/invalid/operating_loop/`, `tests/test_operating_loop.ps1`
- Durable output: canonical operating-loop contract, validator module, CLI wrapper, valid closed-loop shape fixture, invalid missing external evidence/QA without actionable report/operator decision without control-room/successor/chat-memory fixtures, and focused tests
- Done when: the validator rejects chat transcript authority, missing refs, illegal transitions, closeout without external evidence, QA pass without actionable QA, operator decision without control-room status, final support before candidate closeout, successor milestone opening, and broad autonomy/product/runtime claims

### `R12-004` Implement remote-head and stale-phase detector
- Status: done
- Order: 4
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-003`
- Authority: `contracts/remote_head_phase/remote_head_phase_detection.contract.json`, `tools/RemoteHeadPhaseDetector.psm1`, `tools/invoke_remote_head_phase_detector.ps1`, `state/fixtures/valid/remote_head_phase/`, `state/fixtures/invalid/remote_head_phase/`, `tests/test_remote_head_phase_detector.ps1`
- Durable output: bounded remote-head/stale-phase detector with phase match, allowed advanced remote head, branch mismatch, dirty worktree, missing remote ref, unknown remote head, missing evidence, and R11-009-like stale-head coverage
- Done when: phase-match and allowed advanced remote-head fixtures pass; branch mismatch, dirty worktree, unknown remote head, missing remote ref, and missing evidence fail closed; and the R11-009-like stale-head fixture returns controlled `advanced_remote_head` instead of a generic false stop

### `R12-005` Make fresh-thread bootstrap the default execution protocol
- Status: done
- Order: 5
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-004`
- Authority: `contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json`, `tools/FreshThreadBootstrap.psm1`, `tools/prepare_fresh_thread_bootstrap.ps1`, `state/fixtures/valid/bootstrap/`, `state/fixtures/invalid/bootstrap/`, `tests/test_fresh_thread_bootstrap.ps1`
- Durable output: bounded fresh-thread bootstrap packet and compact next-prompt generator from repo truth and explicit inputs
- Done when: valid packet passes; missing branch/head/tree, chat-memory authority, missing fail-closed rules, missing non-claims, and value-gate claims without proof refs fail; and the generated next prompt includes branch/head/tree truth, current task, exact next action, fail-closed rules, evidence refs, non-claims, and no reliance on prior chat context

### `R12-006` Integrate residue guard into mandatory transition preflight
- Status: done
- Order: 6
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-005`
- Authority: `contracts/residue_guard/transition_residue_preflight.contract.json`, `tools/TransitionResiduePreflight.psm1`, `tools/invoke_transition_residue_preflight.ps1`, `state/fixtures/valid/residue_guard/`, `state/fixtures/invalid/residue_guard/`, `tests/test_transition_residue_preflight.ps1`
- Durable output: mandatory transition residue preflight validator/generator for protected R12 operating-loop transitions
- Done when: clean and expected generated-artifact fixtures pass; dirty tracked files, unexpected untracked files, missing preflight, stale head/tree preflight, broad quarantine candidates, and outside-repo quarantine candidates fail closed; and no deletion, destructive rollback, broad cleanup, or value-gate delivery is claimed

### `R12-007` Define external runner request/result contracts
- Status: done
- Order: 7
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-006`
- Authority: `contracts/external_runner/external_runner_request.contract.json`, `contracts/external_runner/external_runner_result.contract.json`, `contracts/external_runner/external_runner_artifact_manifest.contract.json`, `tools/ExternalRunnerContract.psm1`, `tools/validate_external_runner_request.ps1`, `tools/validate_external_runner_result.ps1`, `tools/validate_external_runner_artifact_manifest.ps1`, fixtures under `state/fixtures/valid/external_runner/` and `state/fixtures/invalid/external_runner/`, `tests/test_external_runner_contracts.ps1`
- Durable output: external runner request/result/artifact manifest contracts, validators, fixtures, and focused tests
- Done when: valid request/result/manifest fixtures pass; missing run id, head mismatch, success without artifact manifest, failed run as pass, local-only evidence as external proof, and missing non-claims fail closed

### `R12-008` Implement GitHub Actions external runner invoker/monitor
- Status: done
- Order: 8
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-007`
- Authority: `tools/ExternalRunnerGitHubActions.psm1`, `tools/invoke_external_runner_github_actions.ps1`, `tools/watch_external_runner_github_actions.ps1`, `tools/capture_external_runner_github_actions.ps1`, fixtures under `state/fixtures/valid/external_runner_github_actions/` and `state/fixtures/invalid/external_runner_github_actions/`, `tests/test_external_runner_github_actions.ps1`
- Durable output: bounded GitHub Actions dependency/dispatch/watch/capture/summarize/manual-dispatch substrate with fail-closed dependency and ambiguous-run handling
- Done when: dependency, dispatch, capture, and manual fixtures pass; missing `gh`, missing auth, ambiguous run selection, and manual dispatch mislabeled as API-controlled fail closed

### `R12-009` Add R12 external replay workflow
- Status: done
- Order: 9
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-008`
- Authority: `.github/workflows/r12-external-replay.yml`, `contracts/external_replay/r12_external_replay_bundle.contract.json`, `tools/new_r12_external_replay_bundle.ps1`, `tools/validate_r12_external_replay_bundle.ps1`, fixtures under `state/fixtures/valid/external_replay/` and `state/fixtures/invalid/external_replay/`, `tests/test_r12_external_replay_bundle.ps1`, `tests/test_r12_external_replay_workflow.ps1`
- Durable output: bounded workflow_dispatch replay workflow, replay bundle generator/validator, fixtures, and workflow structure test
- Done when: valid bundle passes; head mismatch, missing logs, failed command as pass, local-only bundle as external proof fail; workflow structure includes exact branch/head/tree inputs and artifact upload wiring

### `R12-010` Implement external artifact retrieval and evidence normalization
- Status: done
- Order: 10
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-009`
- Authority: `contracts/external_runner/external_artifact_evidence_packet.contract.json`, `tools/ExternalArtifactEvidence.psm1`, `tools/import_external_runner_artifact.ps1`, fixtures under `state/fixtures/valid/external_artifact_evidence/` and `state/fixtures/invalid/external_artifact_evidence/`, `tests/test_external_artifact_evidence.ps1`
- Durable output: artifact evidence packet contract, validator/import tooling, local-only normalization handling, fixtures, and focused tests
- Done when: external and local-only valid fixtures pass; head mismatch, failed replay as pass, path traversal, missing run/artifact identity for external claim, and missing non-claims fail closed

### `R12-011` Add QA/linter suite foundation
- Status: done
- Order: 11
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-010`
- Authority: `contracts/actionable_qa/actionable_qa_report.contract.json`, `contracts/actionable_qa/actionable_qa_issue.contract.json`, `tools/ActionableQa.psm1`, `tools/invoke_actionable_qa.ps1`, fixtures under `state/fixtures/valid/actionable_qa/` and `state/fixtures/invalid/actionable_qa/`, `tests/test_actionable_qa.ps1`
- Durable output: actionable QA report and issue contracts, bounded QA runner, valid and invalid fixtures, and focused tests
- Done when: valid report fixtures pass, PSScriptAnalyzer absence is explicit in non-strict mode, missing identity/dependency status/non-claims/reproduction commands fail, missing evidence refs fail, and blocking issues cannot produce aggregate `passed`

### `R12-012` Make QA output actionable, not just pass/fail
- Status: done
- Order: 12
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-011`
- Authority: `contracts/actionable_qa/actionable_qa_fix_queue.contract.json`, `tools/ActionableQaFixQueue.psm1`, `tools/export_actionable_qa_fix_queue.ps1`, fixtures under `state/fixtures/valid/actionable_qa_fix_queue/` and `state/fixtures/invalid/actionable_qa_fix_queue/`, `tests/test_actionable_qa_fix_queue.ps1`
- Durable output: actionable QA fix queue contract, exporter, Markdown summary output, valid and invalid fixtures, and focused tests
- Done when: every fix item maps to a source issue, every blocking issue has a fix item, reproduction commands and recommended fixes are required, hidden blocking counts fail, Markdown summaries include issue count, blocking count, commands, and next action

### `R12-013` Gate cycle transitions on actionable QA and external evidence
- Status: done
- Order: 13
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-012`
- Authority: `contracts/actionable_qa/cycle_qa_evidence_gate.contract.json`, `tools/ActionableQaEvidenceGate.psm1`, `tools/invoke_actionable_qa_evidence_gate.ps1`, fixtures under `state/fixtures/valid/actionable_qa_evidence_gate/` and `state/fixtures/invalid/actionable_qa_evidence_gate/`, `tests/test_actionable_qa_evidence_gate.ps1`
- Durable output: cycle QA evidence gate contract/tooling, mocked passed fixture, missing-external blocked fixture, invalid fixtures, and focused tests
- Done when: the gate refuses pass without actionable QA report, fix queue, external runner result, external artifact evidence, residue preflight, remote-head detection, and no unresolved blocking QA issues; local-only evidence and head/tree mismatch cannot pass

### `R12-014` Generate operator control-room status model
- Status: done
- Order: 14
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-013`
- Authority: `contracts/control_room/control_room_status.contract.json`, `tools/ControlRoomStatus.psm1`, `tools/export_control_room_status.ps1`, fixtures under `state/fixtures/valid/control_room/` and `state/fixtures/invalid/control_room/`, `state/control_room/r12_current/control_room_status.json`, `tests/test_control_room_status.ps1`
- Durable output: machine-readable current R12 control-room status model with branch/head/tree, task posture, value gates, blockers, attention items, next actions, operator decisions, evidence refs, and explicit non-claims
- Done when: valid fixture and current generated status validate; missing identity, missing value gate, external evidence overclaim, QA pass without external evidence, missing blocker, closeout claim, and missing non-claims fail closed

### `R12-015` Generate human-readable control-room view
- Status: done
- Order: 15
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-014`
- Authority: `contracts/control_room/control_room_view.contract.json`, `tools/render_control_room_view.psm1`, fixtures under `state/fixtures/valid/control_room_view/` and `state/fixtures/invalid/control_room_view/`, `state/control_room/r12_current/control_room.md`, `tests/test_control_room_view.ps1`
- Durable output: static Markdown control-room view generated from the status model with exact evidence refs, blockers, QA posture, external-runner posture, next actions, operator decisions, and non-claims
- Done when: valid fixture and current Markdown view validate; missing section, missing non-claims, productized UI wording, hidden blocker, and missing evidence refs fail closed

### `R12-016` Add approval/decision queue foundation
- Status: done
- Order: 16
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-015`
- Authority: `contracts/control_room/operator_decision_queue.contract.json`, `tools/OperatorDecisionQueue.psm1`, `tools/export_operator_decision_queue.ps1`, fixtures under `state/fixtures/valid/operator_decision_queue/` and `state/fixtures/invalid/operator_decision_queue/`, `state/control_room/r12_current/operator_decision_queue.json`, `state/control_room/r12_current/operator_decision_queue.md`, `tests/test_operator_decision_queue.ps1`
- Durable output: bounded operator decision queue that makes external evidence, control-room review, next-slice authorization, and no-successor posture explicit
- Done when: valid fixture and current JSON/Markdown queue validate; missing consequence, missing evidence refs, implicit successor authorization, premature final acceptance, hidden blocking decision, and missing non-claims fail closed

### `R12-017` Run one real useful build/change through the cycle
- Status: done
- Order: 17
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-016`
- Authority: `contracts/control_room/control_room_refresh_result.contract.json`, `tools/ControlRoomRefresh.psm1`, `tools/refresh_control_room.ps1`, `tests/test_control_room_refresh.ps1`, `state/control_room/r12_current/control_room_refresh_result.json`, and `state/cycles/r12_real_build_cycle/`
- Durable output: one-command bounded control-room refresh workflow, valid/invalid refresh fixtures, current refresh result, refreshed control-room status/view/decision-queue artifacts, and bounded cycle evidence
- Done when: the refresh command verifies explicit repository/branch/head/tree, regenerates and validates status/view/queue artifacts, emits a blocked refresh result preserving missing external evidence, and focused refresh tests pass

### `R12-018` Demonstrate fresh-thread restart without operator reconstruction
- Status: done
- Order: 18
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-017`
- Authority: `contracts/bootstrap/fresh_thread_restart_proof.contract.json`, `tools/FreshThreadRestartProof.psm1`, `tools/record_fresh_thread_restart_proof.ps1`, `tests/test_fresh_thread_restart_proof.ps1`, `state/fixtures/valid/bootstrap/fresh_thread_restart_proof.valid.json`, `state/fixtures/invalid/bootstrap/`, and `state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json`
- Durable output: durable fresh-thread restart proof that resolves post-R12-017 remote head `3629d0e8a6659bb31db69b8dd2f25ffaa277ca14`, tree `0ce853ffd37ece19c202e9731b27335ae0cc1756`, completed-through state, planned state, blockers, value-gate posture, control-room refresh result, non-claims, and next legal scope from repo truth and bootstrap artifacts
- Done when: valid restart proof passes, invalid missing bootstrap/handoff/control-room refresh/stale-head/local-head/dirty-worktree/R12-019-or-later/R12-closeout/missing-non-claims cases fail closed, and `state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json` records verdict `passed` without relying on prior chat context

### `R12-019` Run external final-state replay
- Status: done
- Order: 19
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-018`
- Authority: `state/external_runs/r12_external_runner/r12_019_final_state_replay/external_runner_result.json`, `state/external_runs/r12_external_runner/r12_019_final_state_replay/external_runner_artifact_manifest.json`, `state/external_runs/r12_external_runner/r12_019_final_state_replay/external_artifact_evidence_packet.json`, `state/external_runs/r12_external_runner/r12_019_final_state_replay/validation_manifest.md`, `state/external_runs/r12_external_runner/r12_019_final_state_replay/raw_logs/`, and `state/external_runs/r12_external_runner/r12_019_final_state_replay/downloaded_artifact/`
- Durable output: imported passing external final-state replay evidence for run `25204481986`, artifact `6745869087`, head `09b7fbc6e1946ec7e915ec235b9bf9bd934a5591`, and tree `9c4f51b9c0312bb47ed21f3af96a9179cf24809a`
- Done when: external runner result, artifact manifest, external artifact evidence packet, replay bundle, command results, downloaded artifact, and validation manifest all preserve the concrete run/artifact identity and validate with aggregate verdict `passed`

### `R12-020` Generate final audit/report from repo truth
- Status: done
- Order: 20
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-019`
- Authority: `governance/reports/AIOffice_V2_R12_Final_Audit_Report_v1.md`
- Durable output: final audit/report from repo truth
- Done when: report exists in committed repo truth and does not claim product proof by itself

### `R12-021` Close R12 narrowly with two-phase final-head support
- Status: done
- Order: 21
- Milestone: `R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`
- Depends on: `R12-020`
- Authority: `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/closeout_packet.json`, `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/closeout_review.md`, `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/final_remote_head_support_packet.json`, `state/proof_reviews/r12_external_api_runner_actionable_qa_and_operator_control_room_workflow_pilot/validation_manifest.md`
- Durable output: narrow R12 closeout package and Phase 2 final-head support evidence
- Done when: R12 is closed narrowly after R12-021, R12 includes R12-001 through R12-021 only, R12-019 remains the strongest proof, R12-020 remains a report artifact rather than product proof, non-claims remain explicit, and no R13 or successor milestone is opened

### `R11-001` Open R11 and freeze boundary
- Status: done
- Order: 1
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: R10 closeout head `91035cfbb34f531684943d0bfd8c3ba660f48f08`, `D-0079`, approved R10 audit/report direction
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`
- Durable output: repo-truth surfaces that open R11 and freeze it as a controlled cycle-controller pilot only
- Done when: at R11-001 completion, R10 remains the most recently closed prior milestone, R11 is active through R11-001 only, R11-002 through R11-009 remain planned only, no R12 or successor opens, and status-doc gates reject broad autonomy, solved compaction, unattended automatic resume, UI/control-room productization, multi-repo/swarms/Standard runtime, stale R10-active contradiction, and R11 opening without R10 closeout evidence

### `R11-002` Define cycle ledger/state machine
- Status: done
- Order: 2
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-001`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/foundation.contract.json`, `contracts/cycle_controller/cycle_ledger.contract.json`, `tools/CycleLedger.psm1`, `tools/validate_cycle_ledger.ps1`, `tests/test_cycle_ledger.ps1`
- Durable output: canonical cycle states, allowed transitions, per-state evidence/ref requirements, validator-only fixture, invalid fixtures, validator module, CLI validator, and focused tests
- Done when: cycle ledger/state machine contracts define repo-truth authority, allowed transitions, evidence refs, current-step consistency, transition-history validation, non-claims, and fail-closed invalid state handling

### `R11-003` Build cycle controller CLI
- Status: done
- Order: 3
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-002`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/controller_command.contract.json`, `contracts/cycle_controller/controller_result.contract.json`, `tools/CycleController.psm1`, `tools/invoke_cycle_controller.ps1`, `tests/test_cycle_controller.ps1`
- Durable output: thin controller commands to initialize, inspect, advance, and refuse cycles from repo truth, plus valid command fixtures under `state/fixtures/valid/cycle_controller/` and invalid command fixtures under `state/fixtures/invalid/cycle_controller/`
- Done when: the CLI initializes, inspects, advances, blocks, and stops cycle ledger artifacts from committed ledger truth without chat transcript authority, while rejecting illegal transitions, missing evidence, missing actor/reason, missing required refs, terminal-state transitions, outside-root writes, overwrite without explicit flag, wrong repo/branch, malformed Git identity, successor claims, and broad autonomy/productization claims

### `R11-004` Add bootstrap/resume from repo truth
- Status: done
- Order: 4
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-003`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/cycle_bootstrap_packet.contract.json`, `contracts/cycle_controller/cycle_next_action_packet.contract.json`, `tools/CycleBootstrap.psm1`, `tools/prepare_cycle_bootstrap.ps1`, `tests/test_cycle_bootstrap_resume.ps1`
- Durable output: bootstrap packet contract, next-action packet contract, valid packet fixtures, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, bootstrap module, CLI wrapper, and focused bootstrap/resume proof tests
- Done when: bootstrap and next-action packets are derived from a valid committed cycle ledger, validated against contract, and refused when ledger state, authority, branch/head/tree identity, allowed next state, or required non-claims contradict repo truth

### `R11-005` Add local-only residue detection/quarantine
- Status: done
- Order: 5
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-004`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/local_residue_policy.contract.json`, `contracts/cycle_controller/local_residue_scan_result.contract.json`, `contracts/cycle_controller/local_residue_quarantine_result.contract.json`, `tools/LocalResidueGuard.psm1`, `tools/invoke_local_residue_guard.ps1`, `tests/test_local_residue_guard.ps1`
- Durable output: local-only residue policy contract, scan-result contract, quarantine-result contract, clean/dirty/quarantine valid fixtures, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, guard module, CLI wrapper, and focused proof test
- Done when: `git status --short --untracked-files=all` residue scans record raw status and classify tracked/untracked states, dirty tracked files refuse, exact untracked candidates can dry-run, authorized quarantine moves only exact untracked candidates outside the repo, broad/root/.git/outside/missing/tracked candidates refuse, no deletion occurs without dry-run and explicit authorization, tracked files are not modified, and local-only residue is never evidence or repo truth

### `R11-006` Add bounded Dev execution adapter
- Status: done
- Order: 6
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-005`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/dev_dispatch_packet.contract.json`, `contracts/cycle_controller/dev_execution_result_packet.contract.json`, `tools/DevExecutionAdapter.psm1`, `tools/invoke_dev_execution_adapter.ps1`, `tests/test_dev_execution_adapter.ps1`
- Durable output: bounded implementation dispatch/result packet contracts, valid dispatch/result fixtures, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, adapter module, CLI wrapper, and focused proof test
- Done when: at least two bounded task packets are representable and executor result packets preserve evidence refs, scope, dispatch/cycle identity, and head/tree identity while rejecting QA authority, QA verdict, complete controlled cycle, successor, broad autonomy/productization/runtime/orchestration, and unbounded path claims

### `R11-007` Add separate QA gate for cycle tasks
- Status: done
- Order: 7
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-006`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/cycle_qa_gate.contract.json`, `contracts/cycle_controller/cycle_qa_signoff_packet.contract.json`, `tools/CycleQaGate.psm1`, `tools/invoke_cycle_qa_gate.ps1`, `tests/test_cycle_qa_gate.ps1`
- Durable output: separate QA gate contracts/tooling over bounded Dev evidence, valid QA signoff fixture, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, module, CLI wrapper, and focused proof test
- Done when: QA consumes Dev evidence refs, preserves dispatch/result/cycle refs, rejects executor self-certification as QA authority, rejects Dev-result QA authority or QA verdict claims, rejects complete controlled cycle and successor claims, and requires a separate QA actor or explicit non-self-certification independence boundary

### `R11-008` Execute one complete controlled cycle
- Status: done
- Order: 8
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-007`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `contracts/cycle_controller/cycle_audit_packet.contract.json`, `contracts/cycle_controller/operator_decision_packet.contract.json`, `state/cycles/r11_008_controlled_cycle_pilot/`, `tests/test_r11_controlled_cycle_pilot.ps1`
- Durable output: one operator-approved bounded controlled-cycle pilot with request, plan, approval, ledger, bootstrap, clean residue preflight, one Dev dispatch with two bounded tasks, Dev result evidence, separate QA, audit packet, and decision packet
- Done when: the cycle reduces manual per-task prompting, all state transitions are ledger/evidence-backed, `operator_intervention_count` is 2, `manual_bootstrap_count` is 0 after initial approval, and the claim remains limited to one bounded R11-008 controlled-cycle pilot

### `R11-009` Close R11 narrowly with final support
- Status: done
- Order: 9
- Milestone: `R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`
- Depends on: `R11-008`
- Authority: `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`, `governance/DECISION_LOG.md`
- Durable output: candidate R11 proof-review package at `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/`, candidate closeout commit `545232bfd06df86018917bc677e6ba3374b3b9c4`, and post-push final-head support at `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/final_head_support/final_remote_head_support_packet.json`
- Done when: R11 closes only after cycle evidence, final support, non-claims, and no-successor posture are present. Phase 1 candidate output was not R11 closeout until Phase 2 support verified the pushed candidate closeout head.

### `R10-001` Open R10 narrowly and freeze boundary
- Status: done
- Order: 1
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: post-R9 final-head support commit `3c225f863add07f64a9026661d9465d02024a83d`, `D-0061`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`
- Durable output: repo-truth surfaces that open R10 narrowly and freeze the boundary
- Done when: R10 is active in repo truth, R9 remains most recently closed, R10 scope is external-runner artifact identity plus exact final-head clean replay only, and limitation-only external-runner evidence is explicitly insufficient for R10 closeout

### `R10-002` Harden external-runner artifact identity contract for closeout use
- Status: done
- Order: 2
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-001`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `contracts/external_runner_artifact/external_runner_closeout_identity.contract.json`, `tools/ExternalRunnerArtifactIdentity.psm1`, `tools/validate_external_runner_closeout_identity.ps1`, `tests/test_external_runner_closeout_identity.ps1`
- Durable output: closeout-facing external-runner identity validation hardening plus validator-only shape fixture under `state/fixtures/valid/external_runner_artifact/r10_closeout_identity.valid.json`
- Done when: validation rejects empty/synthetic run identity, missing workflow identity, missing artifact identity, missing exact head/tree, success without command logs, success without final-head support evidence, and unavailable limitation described as proof

### `R10-003` Build the external proof artifact bundle format
- Status: done
- Order: 3
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-002`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `contracts/external_proof_bundle/foundation.contract.json`, `contracts/external_proof_bundle/external_proof_artifact_bundle.contract.json`, `tools/ExternalProofArtifactBundle.psm1`, `tools/validate_external_proof_artifact_bundle.ps1`, `tests/test_external_proof_artifact_bundle.ps1`
- Durable output: standard external proof artifact bundle format plus validator-only shape fixture under `state/fixtures/valid/external_proof_bundle/external_proof_artifact_bundle.valid.json`
- Done when: a standard bundle format exists for repository, branch, triggering ref, runner identity, run ID/URL, artifact identity, remote/tested head/tree, clean status, command manifest, logs, exit codes, verdict, refusal reasons, and non-claims

### `R10-004` Wire one GitHub Actions or equivalent runner path
- Status: done
- Order: 4
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-003`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `.github/workflows/r10-external-proof-bundle.yml`, `tools/invoke_r10_external_proof_bundle.ps1`, `tests/test_r10_external_proof_workflow.ps1`
- Durable output: one focused external runner path with controlled workflow dispatch, focused command capture, bundle validation, artifact upload wiring, and R10-004B checkout compatibility hardening for `ubuntu-latest` plus `pwsh`
- Done when: one real external runner path can be triggered on the R10 release branch or controlled dispatch, runs a focused proof set, uploads a standard artifact bundle, and does not claim broad CI/product coverage
- Corrective support: failed run `25032362789` is recorded only as failure analysis at `state/external_runs/r10_external_proof_bundle/25032362789/FAILED_RUN_ANALYSIS.md`; it is not accepted R10-005 proof.

### `R10-005` Capture one real external run identity
- Status: done
- Order: 5
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-004`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`
- Durable output: initial failed run evidence under `state/external_runs/r10_external_proof_bundle/25033063285/`, failed retry evidence under `state/external_runs/r10_external_proof_bundle/25034566460/`, and successful bounded external proof evidence under `state/external_runs/r10_external_proof_bundle/25040949422/`
- Done when: a committed packet contains real run ID, run URL, workflow name/ref, runner identity, artifact name, artifact retrieval instruction, head SHA, tree SHA, branch, run status, conclusion, QA/evidence refs, and non-claims
- Initial result: real run `25033063285` completed with conclusion `failure`; the artifact is retrievable, but it was not successful external proof.
- Corrective support: `R10-005A` records failed validation analysis at `state/external_runs/r10_external_proof_bundle/25033063285/FAILED_VALIDATION_ANALYSIS.md` and fixes the Linux/pwsh external proof bundle validation path without advancing R10 beyond `R10-005`.
- Retry support: `R10-005B` records failed retry run `25034566460`, artifact `r10-external-proof-bundle-25034566460-1`, identity packet `state/external_runs/r10_external_proof_bundle/25034566460/external_runner_closeout_identity.json`, downloaded artifact contents, and analysis `state/external_runs/r10_external_proof_bundle/25034566460/FAILED_RERUN_ANALYSIS.md`. The retry is not successful external proof, so `R10-006` remains planned only.
- Corrective support: `R10-005C` hardens PowerShell Core JSON-root and object-shape handling in the external proof and closeout identity validators. It does not establish successful external proof; a new external run must pass before `R10-006`.
- Corrective support: `R10-005D` adds the canonical fail-closed JSON-root reader under `tools/JsonRoot.psm1` and routes the external proof and closeout identity validators/tests through it. Failed run `25036440624` repeated the same root-shape failure class and was not committed as R10 proof evidence. At that point, R10 remained active through `R10-005` only.
- Corrective support: `R10-005F` preserves timestamp strings under PowerShell Core in the canonical JSON-root reader. Failed run `25037934779` exposed timestamp coercion after the array-root path was corrected, and it was not committed as R10 proof evidence. At that point, R10 remained active through `R10-005` only.
- Retry support: `R10-005G` records successful run `25040949422`, artifact `r10-external-proof-bundle-25040949422-1`, committed identity packet `state/external_runs/r10_external_proof_bundle/25040949422/external_runner_closeout_identity.json`, downloaded artifact contents, and retrieval instruction `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430/zip`. This is one bounded external runner proof run only; R10-006 consumes it for external-runner-consuming QA signoff without making final-head clean replay or closeout claims.

### `R10-006` Add external-runner-consuming QA signoff
- Status: done
- Order: 6
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-005`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `contracts/isolated_qa/external_runner_consuming_qa_signoff.contract.json`, `tools/ExternalRunnerConsumingQaSignoff.psm1`, `tools/validate_external_runner_consuming_qa_signoff.ps1`, `tests/test_external_runner_consuming_qa_signoff.ps1`
- Durable output: external-runner-consuming QA signoff validation tied to real external runner artifacts, plus `state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff.json`
- Done when: QA signoff validation rejects local-only QA for R10 closeout, executor-only evidence, missing external run packet, missing artifact retrieval instruction, missing final-head support ref, and external-runner limitation presented as QA proof

### `R10-007` Add two-phase final-head closeout support procedure
- Status: done
- Order: 7
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-006`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `governance/R10_TWO_PHASE_FINAL_HEAD_CLOSEOUT_SUPPORT_PROCEDURE.md`, `contracts/post_push_support/r10_two_phase_final_head_closeout_procedure.contract.json`, `tools/R10TwoPhaseFinalHeadSupport.psm1`, `tools/validate_r10_two_phase_final_head_support.ps1`, `tests/test_r10_two_phase_final_head_support.ps1`
- Durable output: non-self-referential final-head closeout support procedure plus `state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure.valid.json`
- Done when: the repo distinguishes candidate closeout commit, external run identity, final-head support commit, and final accepted R10 posture

### `R10-008` Close R10 only with real external final-head proof
- Status: done
- Order: 8
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-007`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `governance/DECISION_LOG.md`
- Durable output: Phase 1 candidate package at `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/`, candidate closeout commit `cfebd351922b192585ed5f9d3ca56bee30ea16ae`, and Phase 2 post-push final-head support packet at `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`
- Done when: R10 proof package exists, real external run identity exists, external artifact bundle is referenced and retrievable, final-head support packet exists after push, status-doc gate passes, non-claims are preserved, and no successor milestone is opened

### `R9-001` Open R9 and freeze boundary
- Status: done
- Order: 1
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: post-R8 correction commit `4140780c08c90af03d398644050682de42ee0b1d`, `D-0053`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: repo-truth surfaces that open R9 narrowly and freeze the boundary
- Done when: R9 opens only after the post-R8 correction, R8 remains the most recently closed milestone, R9 scope is isolated QA plus continuity-managed execution pilot only, and UI, Standard runtime, swarms, multi-repo behavior, broad autonomy, and unattended execution are explicitly excluded

### `R9-002` Define isolated QA role and signoff packet
- Status: done
- Order: 2
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-001`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/isolated_qa/foundation.contract.json`, `contracts/isolated_qa/qa_signoff_packet.contract.json`, `tools/IsolatedQaSignoff.psm1`, `tools/validate_isolated_qa_signoff.ps1`, `state/fixtures/valid/isolated_qa/qa_signoff_packet.valid.json`, and `tests/test_isolated_qa_signoff.ps1`
- Done when: QA signoff consumes executor evidence and remote or clean-checkout artifacts, records `qa_role_identity`, `qa_runner_kind`, `qa_authority_type`, `source_artifacts`, `verdict`, `refusal_reasons`, and `independence_boundary`, and fails closed if executor self-certification is presented as QA authority, if separate QA role or runner identity is missing, if executor evidence is the only source artifact, if required remote-head or clean-checkout/external QA refs are missing, or if the independence boundary says the same executor produced and approved the signoff

### `R9-003` Define exact-final post-push verification support model
- Status: done
- Order: 3
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-002`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/post_push_support/foundation.contract.json`, `contracts/post_push_support/final_remote_head_support_packet.contract.json`, `tools/FinalRemoteHeadSupport.psm1`, `tools/validate_final_remote_head_support.ps1`, `state/fixtures/valid/post_push_support/final_remote_head_support_packet.valid.json`, and `tests/test_final_remote_head_support.ps1`
- Done when: final-head support evidence is distinguished from the milestone closeout commit itself, `verification_timing` is `after_closeout_push`, follow-up support commit or external artifact publication is allowed without pretending same-commit proof exists, and self-referential proof, empty evidence refs, invalid status/refusal combinations, missing non-claims, or CI/external claims without run identity fail closed

### `R9-004` Capture real external or CI runner artifact identity
- Status: done
- Order: 4
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-003`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/external_runner_artifact/foundation.contract.json`, `contracts/external_runner_artifact/external_runner_artifact_identity.contract.json`, `tools/ExternalRunnerArtifactIdentity.psm1`, `tools/validate_external_runner_artifact_identity.ps1`, `state/fixtures/valid/external_runner_artifact/external_runner_limitation.valid.json`, and `tests/test_external_runner_artifact_identity.ps1`
- Done when: the external-runner identity contract and validator fail closed on missing run or artifact identity for completed or successful runs, GitHub Actions run URLs must be concrete, success requires QA and remote-head evidence refs, required non-claims are present, and this environment records an explicit unavailable limitation without faking run identity or describing the limitation as proof

### `R9-005` Add continuity-managed execution segment model
- Status: done
- Order: 5
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-004`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/execution_segments/foundation.contract.json`, `contracts/execution_segments/execution_segment_dispatch.contract.json`, `contracts/execution_segments/execution_segment_checkpoint.contract.json`, `contracts/execution_segments/execution_segment_result.contract.json`, `contracts/execution_segments/execution_segment_resume_request.contract.json`, `contracts/execution_segments/execution_segment_handoff.contract.json`, `tools/ExecutionSegmentContinuity.psm1`, `tools/validate_execution_segment_artifact.ps1`, `state/fixtures/valid/execution_segments/`, and `tests/test_execution_segment_continuity.ps1`
- Done when: `execution_segment_dispatch`, `execution_segment_checkpoint`, `execution_segment_result`, `execution_segment_resume_request`, and `execution_segment_handoff` artifacts validate as a bounded restartable segment model; each segment declares a context budget and allowed scope; checkpoints, results, resume requests, and handoffs resolve from durable repo artifacts rather than chat memory; and the focused tests pass without claiming the R9-006 pilot, unattended resume, solved compaction, or hours-long unattended execution

### `R9-006` Pilot one tiny milestone through segmented execution
- Status: done
- Order: 6
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-005`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `state/pilots/r9_tiny_segmented_milestone_pilot/` and `tests/test_r9_tiny_segmented_pilot.ps1`
- Done when: the pilot runs request, plan, approve or freeze, segment dispatch, Codex execution evidence, isolated QA, audit summary, and operator decision without claiming full autonomous milestone execution, external or CI proof, solved Codex context compaction, unattended automatic resume, or hours-long unattended processing

### `R9-007` Close R9 narrowly
- Status: done
- Order: 7
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-006`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, `governance/DECISION_LOG.md`
- Durable output: `state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/`
- Done when: isolated QA signoff exists, final remote-head support model exists, local QA evidence exists, external/CI runner identity limitation is explicitly recorded, status-doc gate passes, no self-certification is accepted, continuity segment artifacts prove the one tiny pilot can resume from durable repo-state refs, and all non-claims are preserved

## Closed R8 Task Record

### `R8-001` Open R8 and freeze the remote-gated QA boundary
- Status: done
- Order: 1
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, `D-0050`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: updated repo-truth surfaces that open R8 as planning only and freeze the exact remote-gated QA boundary
- Done when: R8 is open in repo truth, R7 remains honestly closed, no post-R8 milestone is opened, and scope or non-scope or stop conditions are explicit

### `R8-002` Define QA proof packet contract
- Status: done
- Order: 2
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-001`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one durable machine-validated QA proof packet contract plus future validation surfaces
- Done when: the packet requires remote head, tree hash, command list, raw logs, exit codes, environment, dirty or clean status, artifact hashes, QA verdict, and refusal reasons

### `R8-003` Implement remote-head verification gate
- Status: done
- Order: 3
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-002`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one gate that records branch, local head, remote head, commit subject, tree, timestamp, and pass or fail for remote branch truth
- Done when: local-only completion claims fail closed on local or remote mismatch

### `R8-004` Implement post-push verification gate
- Status: done
- Order: 4
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-003`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one final remote-head verification artifact path that proves the exact landed SHA after push
- Done when: completion cannot be claimed without post-push verification for the exact final remote SHA

### `R8-005` Implement clean-checkout QA runner
- Status: done
- Order: 5
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-004`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one clean or disposable checkout QA runner pinned to the exact remote SHA, with raw log output root
- Done when: the runner checks out the exact remote head, runs declared commands, captures stdout or stderr or exit codes, and records clean or dirty status before and after

### `R8-006` Harden proof-package validator for complete command logs
- Status: done
- Order: 6
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-005`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one proof-validator hardening layer that rejects claimed commands without raw or support log coverage
- Done when: generator, validator, proof-review test, Git hygiene, remote-head, and QA runner commands all fail closed if coverage is missing

### `R8-007` Add CI or equivalent external proof runner
- Status: done
- Order: 7
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-006`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one external proof execution path with concrete artifact identity
- Done when: CI or equivalent external execution can run the clean-checkout QA flow and publish or reference artifacts with concrete run identity

### `R8-008` Add status-doc gating
- Status: done
- Order: 8
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-007`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one status-doc gating layer across `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, and `governance/DECISION_LOG.md`
- Done when: status docs cannot claim milestone `done` or `closed` without QA packet, remote-head verification, and proof refs, and stale "most recently closed" contradictions fail validation

### `R8-009` Pilot and close R8 narrowly
- Status: done
- Order: 9
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-008`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, `governance/DECISION_LOG.md`
- Durable output: one bounded R8 closeout path that uses the remote-gated QA process on itself
- Done when: R8 closes only after remote-gated clean-checkout QA passes, explicit non-claims remain intact, and no broader automation claim is made

## Explicitly Out Of Scope For This Milestone
- no UI or control-room productization
- no Standard runtime
- no multi-repo orchestration
- no swarms
- no broad autonomous milestone execution
- no unattended automatic resume
- no solved Codex context compaction
- no hours-long unattended milestone execution
- no destructive rollback on the primary working tree
- no production-grade general CI for every future workflow
- no productized control-room behavior
- no general "Codex is now reliable" claims
- claiming Codex context compaction is solved
- claiming hours-long milestones can now run unattended
- closing R10 on limitation-only external-runner evidence
- using `feature/r5-closeout-remaining-foundations` for new R10+ milestone implementation
