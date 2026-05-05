# R16-014 Context-Load Plan Contract Validation Manifest

Status: passed.

This manifest is for the R16-014 context-load plan contract only. It must not be used as a generated context-load plan, context-load planner, context budget estimator, over-budget fail-closed validator, role-run envelope, RACI transition gate, handoff packet, workflow drill, runtime memory, product runtime, autonomous-agent runtime, external integration claim, solved Codex compaction claim, or solved Codex reliability claim.

## Final Commands

| Command | Result |
| --- | --- |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan_contract.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_plan_contract.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_artifact_audit_map_refs.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_audit_map_check_report.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_audit_map_check.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_audit_map.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_map.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_map_generator.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_map.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_map_generator.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_pack_validation.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_pack_validation_report.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layer_contract.ps1 -ContractPath contracts/memory/r16_memory_layer.contract.json` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_contract.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layers.ps1 -MemoryLayersPath state/memory/r16_memory_layers.json -ContractPath contracts/memory/r16_memory_layer.contract.json` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_generator.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_pack_model.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_model.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_packs.ps1 -PacksPath state/memory/r16_role_memory_packs.json -ModelPath state/memory/r16_role_memory_pack_model.json -MemoryLayersPath state/memory/r16_memory_layers.json` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_generator.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_memory_pack_refs.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r16_kpi_baseline_target_scorecard.json` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1 -PacketPath state/governance/r16_planning_authority_reference.json` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_milestone_reporting_standard.ps1` | Passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_milestone_reporting_standard.ps1` | Passed |

## Fail-Closed Retries

- One local retry occurred after `tests/test_status_doc_gate.ps1` rejected the context-load planner overclaim but emitted a broader refusal label than the focused test expected. The gate behavior was fail-closed; the claim label was tightened to preserve the expected `context-load planner implementation` fragment while still rejecting generated context-load plan claims.
- The full 29-command validation suite was rerun after the retry and passed.
