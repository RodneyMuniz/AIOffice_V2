# R12-019 Failed External Replay Diagnostic

This diagnostic records failed GitHub Actions run `25191914525`. It does not complete R12-019 and is not external final-state replay evidence.

## Run Identity

- Workflow: `R12 External Replay`
- Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25191914525`
- Run ID: `25191914525`
- Run conclusion: `failure`
- Target branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Target head: `e6db53682fa79cae04c65d6fa56383580e54555f`
- Target tree: `c622e001edb60214d4050c2d125678a2e514bfa6`
- Replay scope: `r12-019-final-state-replay`

## Artifact Identity

- Artifact name: `r12-external-replay-25191914525-1`
- Artifact ID: `6741265940`
- Artifact digest/hash: `sha256:dbf774ef7b373a8afca576e1f9e6298ab0a86eb003c69931413e4cead378dd78`
- Artifact status: exists, diagnostic only, not imported as passing external evidence.

## Failure

The run failed in `Generate and validate R12 replay bundle`.

Direct validator error:

```text
R12 external replay bundle clean_status_before.evidence_ref 'clean_status_before.log' does not exist.
```

Root cause: the workflow wrote clean status logs under `command_logs/clean_status_before.log` and `command_logs/clean_status_after.log`, but passed `clean_status_before.log` and `clean_status_after.log` into `tools/new_r12_external_replay_bundle.ps1`.

Correction in this branch: pass `command_logs/clean_status_before.log` and `command_logs/clean_status_after.log` into the replay bundle.

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
