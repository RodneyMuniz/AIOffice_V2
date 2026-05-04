# R15-008 Classification Re-entry Dry Run Validation Manifest

Status: passed.

This manifest records the required R15-008 validation battery after the bounded classification/re-entry dry-run artifact, status surfaces, knowledge index entries, and proof-review evidence were completed.

## Required Results

| Command | Result |
| --- | --- |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_classification_reentry_dry_run.ps1` | Passed. Valid passed: 3. Invalid rejected: 19. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_classification_reentry_dry_run.ps1 -DryRunPath state\agents\r15_classification_reentry_dry_run.json` | Passed. Dry-run id `aioffice-r15-008-classification-reentry-dry-run-v1`, 4 target paths, 4 classifications, 16 index lookups, target agent `evidence_auditor`, transition `audit_review_to_audit_accepted`, verdict `passed`. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_card_reentry_packet.ps1` | Passed. Valid passed: 3. Invalid rejected: 51. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_card_reentry_packet.ps1 -PacketPath state\agents\r15_card_reentry_packet.json` | Passed. 5 packet records; model-only flags preserved. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_raci_state_transition_matrix.ps1` | Passed. Valid passed: 3. Invalid rejected: 18. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_raci_state_transition_matrix.ps1 -MatrixPath state\agents\r15_raci_state_transition_matrix.json` | Passed. 15 states, 29 transitions, 6 prohibited transitions; runtime state machine flags preserved false. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_agent_memory_scope.ps1` | Passed. Valid passed: 3. Invalid rejected: 14. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_agent_memory_scope.ps1 -ScopePath state\agents\r15_agent_memory_scope.json` | Passed. 10 memory scopes, 10 role mappings; runtime memory flags preserved false. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_agent_identity_packet.ps1` | Passed. Valid passed: 3. Invalid rejected: 18. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_agent_identity_packet.ps1 -PacketPath state\agents\r15_agent_identity_packet.json` | Passed. 10 roles; model-only and runtime-agent flags preserved. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_repo_knowledge_index.ps1` | Passed. Valid passed: 3. Invalid rejected: 23. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_repo_knowledge_index.ps1 -IndexPath state\knowledge\r15_repo_knowledge_index.json` | Passed. 32 bounded entries; `bounded_seed_only=True`, `full_repo_index=False`. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_artifact_classification_taxonomy.ps1` | Passed. Valid passed: 3. Invalid rejected: 9. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_artifact_classification_taxonomy.ps1 -TaxonomyPath state\knowledge\r15_artifact_classification_taxonomy.json` | Passed. 19 classes, 11 evidence kinds, 10 authority kinds, 9 lifecycle states, 6 proof statuses. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1` | Passed. Valid passed: 1. Invalid rejected: 58. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1` | Passed. Status gate accepts R15 active through R15-008 with R15-009 planned only. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1` | Passed. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1` | Passed. 4 required files and 8 required section texts present. |
| `git diff --check` | Failed once on `state/knowledge/r15_repo_knowledge_index.json` trailing whitespace/line-ending churn, then passed after mechanical encoding/line-ending cleanup. |
| `git status --short` | Passed after manifest update; output showed expected R15-008 working tree changes before commit. |
| `git rev-parse HEAD` | Passed after manifest update; pre-commit head `2b116618c4992b2e17921b2c5de86e020a0ebe11`. |
| `git rev-parse HEAD^{tree}` | Passed after manifest update; pre-commit tree `52ef7676ab76cd3a2a1ea6e94b3c168cfeee19d6`. |
| `git branch --show-current` | Passed after manifest update; branch `release/r15-knowledge-base-agent-identity-memory-raci-foundations`. |

## Corrected Failure

`git diff --check` initially rejected `state/knowledge/r15_repo_knowledge_index.json` for trailing whitespace/line-ending churn introduced while updating the bounded R15-008 entries. The file was mechanically rewritten as UTF-8 without BOM and LF line endings only. The dependent repo knowledge index validator and focused tests were rerun and passed, and `git diff --check` was rerun and passed.

## Boundary Confirmation

- R15 is active through `R15-008` only.
- `R15-009` is planned only.
- R13 remains failed/partial through `R13-018` only.
- R14 remains accepted with caveats through `R14-006` only.
- No R16 was opened.
- The R15-008 dry run executed only as bounded model/evidence application.
- No runtime agents, workflow execution, board routing runtime, card re-entry runtime, product runtime, integration runtime, retrieval engine, vector search, or final R15 proof package was implemented.
