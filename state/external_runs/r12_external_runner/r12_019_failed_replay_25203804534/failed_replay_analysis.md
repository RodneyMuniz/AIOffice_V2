# R12-019 Failed But Externally Valid Replay Diagnostic

This diagnostic records GitHub Actions run `25203804534`. The GitHub Actions job conclusion was `success`, the artifact exists, and the replay bundle validated structurally, but the replay bundle aggregate verdict was `failed`.

This does not complete R12-019 and is not passing external final-state replay evidence.

## Run Identity

- Workflow: `R12 External Replay`
- Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25203804534`
- Run ID: `25203804534`
- GitHub Actions job conclusion: `success`
- Target branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Target head: `076a696cc9bcc7632e0c8cea66265da53a549842`
- Target tree: `ef930ff75870a83bfbc79bcb3e455f2a70e94693`
- Replay scope: `r12-019-final-state-replay`

## Artifact Identity

- Artifact name: `r12-external-replay-25203804534-1`
- Artifact ID: `6745614492`
- Artifact digest/hash: `sha256:37c26577108c5f9a950ed8c7e360e1484b360ec504c7934586ba3d08b0870c7f`
- Artifact status: exists, diagnostic only, not imported as passing external evidence.

## Bundle Verdict

- Replay bundle structural validation: valid
- Replay bundle aggregate verdict: `failed`
- Bundle refusal reason: command `test_transition_residue_preflight` exited `1`

## Failed Command

- Command ID: `test_transition_residue_preflight`
- Command: `pwsh -NoProfile -ExecutionPolicy Bypass -File tests/test_transition_residue_preflight.ps1`
- Exit code: `1`
- Failed case: `invalid-outside-repo-quarantine-candidate was accepted unexpectedly`

Stdout summary: the transition residue preflight test passed its earlier valid and invalid cases, then accepted the outside-repo quarantine candidate unexpectedly. Stderr was empty.

## Root Cause

The invalid fixture used the quarantine candidate path `C:/outside-repo/residue.tmp`. On the Linux GitHub Actions runner, `[System.IO.Path]::IsPathRooted("C:/outside-repo/residue.tmp")` is not treated as rooted. The residue preflight module therefore treated that Windows-style absolute path as repo-relative and failed to reject it as an outside-repo quarantine candidate.

Correction in this branch: add portable path validation for POSIX absolute paths, Windows drive-rooted paths, UNC-like paths, and relative traversal that escapes the repository root.

## Explicit Non-Claims

- This failed replay does not complete R12-019.
- This failed replay is not passing external final-state replay evidence.
- The artifact is diagnostic only and is not accepted external artifact evidence.
- No R12-020 or R12-021 work is included.
- No R12 closeout is claimed.
- No R13 is opened.
- No broad CI/product coverage is claimed.
- No production runtime is claimed.
