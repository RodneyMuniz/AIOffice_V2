# R16-016 Context Budget Estimator Validation Manifest

Status: passed after recovery validation.

This manifest is for the R16-016 bounded context budget estimator and committed generated context budget estimate state artifact only. It must not be used as exact provider tokenization, exact provider billing, an over-budget fail-closed validator, runtime memory, runtime memory loading, retrieval runtime, vector search runtime, product runtime, a role-run envelope, a RACI transition gate, a handoff packet, workflow execution, autonomous-agent runtime, external integration claim, solved Codex compaction claim, or solved Codex reliability claim.

## Final Commands

The recovery sweep ran these required R16-016 and dependent validation commands:

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_context_budget_estimate.ps1`
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_estimate.ps1`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_estimator.ps1`
4. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_context_load_plan.ps1`
5. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan.ps1`
6. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_planner.ps1`
7. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan_contract.ps1`
8. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_plan_contract.ps1`
9. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_artifact_audit_map_refs.ps1`
10. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_audit_map_check_report.ps1`
11. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_audit_map_check.ps1`
12. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_audit_map.ps1`
13. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_map.ps1`
14. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_map_generator.ps1`
15. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_map.ps1`
16. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_map_generator.ps1`
17. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1`
18. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1`
19. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_pack_validation.ps1`
20. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_pack_validation_report.ps1`

The related R16/status validators also ran:

21. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layer_contract.ps1 -ContractPath contracts/memory/r16_memory_layer.contract.json`
22. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_contract.ps1`
23. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layers.ps1 -MemoryLayersPath state/memory/r16_memory_layers.json -ContractPath contracts/memory/r16_memory_layer.contract.json`
24. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_generator.ps1`
25. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_pack_model.ps1`
26. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_model.ps1`
27. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_packs.ps1 -PacksPath state/memory/r16_role_memory_packs.json -ModelPath state/memory/r16_role_memory_pack_model.json -MemoryLayersPath state/memory/r16_memory_layers.json`
28. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_generator.ps1`
29. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_memory_pack_refs.ps1`
30. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r16_kpi_baseline_target_scorecard.json`
31. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1`
32. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1 -PacketPath state/governance/r16_planning_authority_reference.json`
33. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1`
34. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_milestone_reporting_standard.ps1`
35. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_milestone_reporting_standard.ps1`

Final status: all commands passed after the recovery retries below.

## Fail-Closed Retries

Initial recovery found the estimator validator reused `$estimate` as a loop-local variable, overwriting the `$Estimate` parameter because PowerShell variable names are case-insensitive. The variable was renamed to keep the top-level estimate object intact, after which generation, validation, and the focused invalid-fixture refusals passed through the missing-proof-package checkpoint.

Final recovery sweep then found two stale historical test harness assumptions and five direct-wrapper invocation errors:

- `tests/test_r16_context_load_planner.ps1` and `tests/test_r16_context_load_plan_contract.ps1` still rejected the existence of the legitimate R16-016 estimator module as a future overbuild artifact. The repo-existence ban was removed for `tools/R16ContextBudgetEstimator.psm1`; artifact-level checks still reject context-budget-estimator claims inside the R16-014/R16-015 contract/plan outputs.
- Direct calls to older validators for memory-layer contract, memory layers, role memory packs, KPI scorecard, and planning authority reference required explicit path parameters. They passed when rerun with the committed artifact paths listed above.

Final rerun status: passed.

## Restored Deterministic Side Effects

`powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_memory_pack_refs.ps1` deterministically rewrote `state/memory/r16_memory_pack_validation_report.json` with the current invocation boundary. That file is an older R16-008 state artifact and is outside the R16-016 commit scope, so it was restored to the pre-existing tracked version. After restoration, `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_pack_validation.ps1` and `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_pack_validation_report.ps1` both passed.
