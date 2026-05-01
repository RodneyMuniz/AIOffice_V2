# R12-019 Failed External Replay Diagnostic

This diagnostic records failed GitHub Actions run `25202850123`. It does not complete R12-019 and is not external final-state replay evidence.

## Run Identity

- Workflow: `R12 External Replay`
- Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25202850123`
- Run ID: `25202850123`
- Run conclusion: `failure`
- Target branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Target head: `82c32d9da7b4df3bbeac93aa83b06b5d4327519b`
- Target tree: `a65babfd032bc694161286bd5da99c44fbc77a43`
- Replay scope: `r12-019-final-state-replay`

## Artifact Identity

- Artifact name: `r12-external-replay-25202850123-1`
- Artifact ID: `6745298859`
- Artifact digest/hash: `sha256:6dcff00363825286462e0f059aa4ed3c4d8a6c92ba477f553868bdb90eb6c9c8`
- Artifact status: exists, diagnostic only, not imported as passing external evidence.

## Failure

The run failed in `Generate and validate R12 replay bundle`.

Direct validator error:

```text
R12 external replay bundle clean_status_before.evidence_ref 'command_logs/clean_status_before.log' does not exist.
```

Root cause: the workflow wrote clean-status evidence with `git status --short --untracked-files=all | Set-Content ...`. When the worktree is clean, `git status --short` can produce no pipeline output, leaving `command_logs/clean_status_before.log` absent even though the bundle references it.

Correction in this branch: capture clean-status output into an array and write an explicit empty file when the array has no lines. The same robustness is applied to `command_logs/clean_status_after.log`.

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
