# R16-011 Audit Map Contract Validation Manifest

Status: passed with recorded fail-closed retries.

This manifest is for the contract-only R16-011 audit map contract. It must not be used as a generated audit map, audit map generator, R15/R16 audit map, context-load planner, role-run envelope, handoff packet, workflow drill, runtime memory, product runtime, autonomous agent claim, external integration claim, solved Codex compaction claim, or solved Codex reliability claim.

## Commands

| Command | Result |
| --- | --- |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_audit_map_contract.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_audit_map_contract.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1` | FAIL, then fixed gate regex to allow contract-only audit map wording |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1` | FAIL, then fixed gate regex to allow contract-only audit map wording |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_planning_authority_reference.ps1` | FAIL, missing mandatory `-PacketPath` parameter |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1` | FAIL, then fixed planning-reference status regex to allow contract-only audit map wording |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_planning_authority_reference.ps1 -PacketPath state\governance\r16_planning_authority_reference.json` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_artifact_map.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_artifact_map_generator.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_artifact_map_contract.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_artifact_map_contract.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_pack_validation.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_pack_validation_report.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layers.ps1` | FAIL, missing mandatory path parameters |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_layer_generator.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layers.ps1 -MemoryLayersPath state\memory\r16_memory_layers.json -ContractPath contracts\memory\r16_memory_layer.contract.json` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_role_memory_packs.ps1 -PacksPath state\memory\r16_role_memory_packs.json -ModelPath state\memory\r16_role_memory_pack_model.json -MemoryLayersPath state\memory\r16_memory_layers.json` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_role_memory_pack_generator.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state\governance\r16_kpi_baseline_target_scorecard.json` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_kpi_baseline_target_scorecard.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_role_memory_pack_model.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_role_memory_pack_model.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layer_contract.ps1 -ContractPath contracts\memory\r16_memory_layer.contract.json` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_layer_contract.ps1` | PASS |
| `git diff --check` | PASS |
| `git diff --cached --check` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_audit_map_contract.ps1` | PASS, final rerun after proof-review package update |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_audit_map_contract.ps1` | PASS, final rerun after proof-review package update |
| `git diff --check` | PASS, final rerun after proof-review package update |
| `git diff --cached --check` | PASS, final rerun after proof-review package update |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1` | PASS, rerun after final Active State boundary correction |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1` | PASS, rerun after final Active State boundary correction |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1` | PASS, rerun after final Active State boundary correction |
| `git diff --check` | PASS, rerun after final Active State boundary correction |
