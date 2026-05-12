# R18-014 New-Context Prompt Generator Validation Manifest

Required validation commands:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_new_context_prompt_generator.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_new_context_prompt_generator.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_new_context_prompt_generator.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_continuation_packet_generator.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_continuation_packet_generator.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_remote_branch_verifier.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_remote_branch_verifier.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_wip_classifier.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_wip_classifier.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_detector.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_detector.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_runner_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_runner_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_work_order_state_machine.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_work_order_state_machine.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_local_runner_cli.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_local_runner_cli.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_orchestrator_control_intake.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_orchestrator_control_intake.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_role_skill_permission_matrix.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_role_skill_permission_matrix.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_a2a_handoff_packet_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_a2a_handoff_packet_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_skill_contract_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_skill_contract_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`

Expected status truth: R18 active through R18-014 only; R18-015 through R18-028 planned only.
Expected non-claims: no prompt execution, no automatic new-thread creation, no Codex/OpenAI API invocation, no continuation packet execution, no recovery action, no retry execution, no WIP cleanup, no branch mutation, no stage/commit/push by the generator, no A2A message, no live agent or skill execution, no no-manual-prompt-transfer success, and no main merge.
