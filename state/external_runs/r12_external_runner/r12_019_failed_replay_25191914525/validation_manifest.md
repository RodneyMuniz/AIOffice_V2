# R12-019 Failed Replay Validation Manifest

This manifest records the local validation for the diagnostic failed-run packet and workflow correction. It does not record R12-019 completion.

## Diagnostic Evidence

- `state/external_runs/r12_external_runner/r12_019_failed_replay_25191914525/failed_external_runner_result.json`
- `state/external_runs/r12_external_runner/r12_019_failed_replay_25191914525/failed_artifact_manifest.json`
- `state/external_runs/r12_external_runner/r12_019_failed_replay_25191914525/failed_replay_analysis.md`

## Failure Recorded

- Run conclusion: `failure`
- Artifact exists: yes, diagnostic only
- Failure cause: clean-status evidence refs omitted `command_logs/`
- Invalid refs: `clean_status_before.log`, `clean_status_after.log`
- Correct refs: `command_logs/clean_status_before.log`, `command_logs/clean_status_after.log`

## Validation Commands

- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_external_runner_result.ps1 -ResultPath state\external_runs\r12_external_runner\r12_019_failed_replay_25191914525\failed_external_runner_result.json`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r12_external_replay_workflow.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r12_external_replay_bundle.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_external_artifact_evidence.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_external_runner_contracts.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- Passed: `git diff --check`

## Explicit Non-Claims

- R12-019 remains not done.
- No successful external replay exists yet.
- No external artifact evidence is accepted.
- No R12-020 or R12-021 work is included.
- No R12 closeout is claimed.
- No R13 is opened.
