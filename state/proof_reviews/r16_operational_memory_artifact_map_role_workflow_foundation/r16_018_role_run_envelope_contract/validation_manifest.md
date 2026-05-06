# R16-018 Role-Run Envelope Contract Validation Manifest

Status: passed.

This manifest is for the R16-018 role-run envelope contract only. It records a machine-checkable contract for future role-run envelopes and does not generate role-run envelopes, implement a role-run envelope generator, implement a RACI transition gate, implement a handoff packet, or run workflow drills.

The current R16-017 guard report remains repo truth: `state/context/r16_context_budget_guard_report.json` has aggregate verdict `failed_closed_over_budget` because the approximate upper bound is `1323518` and the configured threshold is `150000`. R16-018 does not create a mitigation and does not weaken R16-017.

## Required Commands

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_run_envelope_contract.ps1`
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_run_envelope_contract.ps1`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_context_budget_guard.ps1`
4. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_guard_report.ps1`
5. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_guard.ps1`
6. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_estimate.ps1`
7. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_estimator.ps1`
8. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan.ps1`
9. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_planner.ps1`
10. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_packs.ps1 -PacksPath state/memory/r16_role_memory_packs.json -ModelPath state/memory/r16_role_memory_pack_model.json -MemoryLayersPath state/memory/r16_memory_layers.json`
11. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_generator.ps1`
12. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1`
13. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1`
14. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1 -PacketPath state/governance/r16_planning_authority_reference.json`
15. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1`
16. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r16_kpi_baseline_target_scorecard.json`
17. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1`
18. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layer_contract.ps1 -ContractPath contracts/memory/r16_memory_layer.contract.json`
19. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_contract.ps1`

All listed commands passed during the R16-018 validation sweep.

## Non-Claims

- R16-018 defines the role-run envelope contract only.
- No generated role-run envelopes exist yet.
- No role-run envelope generator exists yet.
- No RACI transition gate exists yet.
- No handoff packet exists yet.
- No workflow drill exists yet.
- R16-019 through R16-026 remain planned only.
- R16-017 guard remains failed_closed_over_budget for the current context load plan.
- This does not solve Codex compaction or Codex reliability.
