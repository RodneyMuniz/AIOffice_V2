# R16-017 Context Budget Guard Validation Manifest

Status: passed.

This manifest is for the R16-017 bounded over-budget context guard and no-full-repo-scan enforcement only. It records a deterministic local guard that reads `state/context/r16_context_load_plan.json` and `state/context/r16_context_budget_estimate.json`, rejects unsafe/broad load surfaces, and can fail closed when approximate upper-bound context size exceeds the configured threshold.

The current committed report fails closed over budget because the refreshed R16-016 approximate upper bound is `1314676` and the configured threshold is `150000`.

## Required Commands

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_context_budget_guard.ps1`
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_guard_report.ps1`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_guard.ps1`
4. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_estimate.ps1`
5. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_estimator.ps1`
6. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan.ps1`
7. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_planner.ps1`
8. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1`
9. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1`
10. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1 -PacketPath state/governance/r16_planning_authority_reference.json`
11. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1`
12. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r16_kpi_baseline_target_scorecard.json`
13. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1`
14. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layer_contract.ps1 -ContractPath contracts/memory/r16_memory_layer.contract.json`
15. `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_contract.ps1`

All listed commands passed during the R16-017 validation sweep. The tool-level guard test was rerun sequentially after an initial parallel fixture-write collision.

## Non-Claims

- R16-017 is not runtime memory.
- R16-017 is not retrieval runtime.
- R16-017 is not vector search runtime.
- R16-017 is not product runtime.
- R16-017 does not solve Codex compaction or Codex reliability.
- R16-017 does not implement role-run envelopes, RACI transition gates, handoff packets, workflow drills, autonomous agents, or external integrations.
- R16-018 through R16-026 remain planned only.
