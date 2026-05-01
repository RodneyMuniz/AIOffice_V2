# R12-019 Failed External Replay Diagnostic

This diagnostic records failed GitHub Actions run `25200724371`. It does not complete R12-019 and is not external final-state replay evidence.

## Run Identity

- Workflow: `R12 External Replay`
- Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25200724371`
- Run ID: `25200724371`
- Run conclusion: `failure`
- Target branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Target head: `874eedbd6f72b95fec4c00fd199cba216cc23718`
- Target tree: `8766b4d8b29a9e61e038b08d50829e1073db36b6`
- Replay scope: `r12-019-final-state-replay`

## Artifact Identity

- Artifact name: `r12-external-replay-25200724371-1`
- Artifact ID: `6744584299`
- Artifact digest/hash: `sha256:c861490a962433e2cba1b86cadeddb33d651432eeadaf6c491f1591add59c238`
- Artifact status: exists, diagnostic only, not imported as passing external evidence.

## Failure

The run failed in `Generate and validate R12 replay bundle`.

Direct validator error:

```text
R12 external replay bundle clean_status_before.evidence_ref 'command_logs/clean_status_before.log' does not exist.
```

Root cause: the workflow wrote and referenced the correct artifact-relative path, `command_logs/clean_status_before.log`, but `tools/validate_r12_external_replay_bundle.ps1` resolved bundle evidence refs from the wrong root instead of from the directory containing `r12_external_replay_bundle.json`.

Correction in this branch: resolve relative evidence refs against the bundle root, reject absolute evidence refs, and reject path traversal outside the bundle root while keeping missing-log and failed-command validation fail-closed.

## Explicit Non-Claims

- This failed run does not complete R12-019.
- This failed run is not external final-state replay evidence.
- The artifact is diagnostic only and is not accepted external artifact evidence.
- No R12-020 or R12-021 work is included.
- No R12 closeout is claimed.
- No R13 is opened.
- No broad CI/product coverage is claimed.
- No production runtime is claimed.
- No productized control-room behavior is claimed.
- No solved Codex reliability is claimed.
