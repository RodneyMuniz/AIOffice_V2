# R12-019 Failed Replay Validation Manifest

This manifest records local validation for the failed-but-externally-valid replay diagnostic and the residue-preflight portability correction. It does not record R12-019 completion.

## Diagnostic Evidence

- `state/external_runs/r12_external_runner/r12_019_failed_replay_25203804534/failed_external_runner_result.json`
- `state/external_runs/r12_external_runner/r12_019_failed_replay_25203804534/failed_artifact_manifest.json`
- `state/external_runs/r12_external_runner/r12_019_failed_replay_25203804534/failed_replay_analysis.md`

## Failure Recorded

- GitHub Actions job conclusion: `success`
- Replay bundle structural validation: valid
- Replay bundle aggregate verdict: `failed`
- Failed command: `test_transition_residue_preflight`
- Failed command exit code: `1`
- Root cause: cross-platform absolute path detection failed to reject Windows-style outside-repo path `C:/outside-repo/residue.tmp` on Linux

## Validation Commands

- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_transition_residue_preflight.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r12_external_replay_bundle.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r12_external_replay_workflow.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_external_artifact_evidence.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_external_runner_contracts.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- Passed: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- Passed: `git diff --check`

## Explicit Non-Claims

- R12-019 remains not done.
- No passing external replay exists yet.
- No external artifact evidence is accepted as passing.
- No R12-020 or R12-021 work is included.
- No R12 closeout is claimed.
- No R13 is opened.
