# R18-011 Validation Manifest

Expected status truth after this package: R18 active through R18-011 only; R18-012 through R18-028 planned only.

Required validation commands:
- `tools/validate_r18_wip_classifier.ps1`
- `tests/test_r18_wip_classifier.ps1`
- `tools/validate_r18_compact_failure_detector.ps1`
- `tests/test_r18_compact_failure_detector.ps1`
- `tools/validate_r18_runner_state_store.ps1`
- `tests/test_r18_runner_state_store.ps1`
- `tools/validate_r18_work_order_state_machine.ps1`
- `tests/test_r18_work_order_state_machine.ps1`
- `tools/validate_r18_local_runner_cli.ps1`
- `tests/test_r18_local_runner_cli.ps1`
- `tools/validate_r18_orchestrator_control_intake.ps1`
- `tests/test_r18_orchestrator_control_intake.ps1`
- `tools/validate_r18_role_skill_permission_matrix.ps1`
- `tests/test_r18_role_skill_permission_matrix.ps1`
- `tools/validate_r18_a2a_handoff_packet_schema.ps1`
- `tests/test_r18_a2a_handoff_packet_schema.ps1`
- `tools/validate_r18_skill_contract_schema.ps1`
- `tests/test_r18_skill_contract_schema.ps1`
- `tools/validate_r18_agent_card_schema.ps1`
- `tests/test_r18_agent_card_schema.ps1`
- `tools/validate_r18_opening_authority.ps1`
- `tests/test_r18_opening_authority.ps1`
- `tools/validate_status_doc_gate.ps1`
- `tests/test_status_doc_gate.ps1`
- `git diff --check`

The WIP classifier is deterministic over seed inventory artifacts only and performs no cleanup, abandonment, restore/delete, staging, commit, push, remote verification, continuation generation, new-context prompt generation, recovery action, work-order execution, live agent/skill/A2A runtime, API invocation, or automatic new-thread creation.
