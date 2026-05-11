# R18-007 Validation Manifest

Required local validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_local_runner_cli.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_local_runner_cli.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\status_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\inspect_repo_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\validate_intake_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\refuse_execute_work_order_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_local_runner_cli.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

Expected truth after validation: R18 is active through R18-007 only; R18-008 through R18-028 remain planned only.
