# R13-011 External Replay Validation Manifest

- artifact_type: `r13_external_replay_validation_manifest`
- request_ref: `state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json`
- blocked_result_ref: `state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json`
- manual_dispatch_packet_ref: `state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json`
- raw_logs_ref: `state/external_runs/r13_external_replay/r13_011/raw_logs/`
- branch: `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`
- requested_head: `e9e8b4e21147d7c0906b4916297e3162690dbf64`
- requested_tree: `520e2adf5e5fcbce2f81b23c872206d746e6b9c2`
- aggregate_verdict: `blocked`
- generated_at_utc: `2026-05-02T00:44:35Z`

## External Identity

- workflow_name: `R13 External Replay`
- workflow_ref: `github_actions_manual_dispatch_or_equivalent_external_runner_required`
- run_id: not available
- run_url: not available
- run_attempt: `0`
- artifact_id: not available
- artifact_name: `r13-external-replay-<run_id>-<run_attempt>`
- artifact_digest: not available
- imported_artifact_ref: not available

## Commands Run

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r13_external_replay_request.ps1 -OutputPath state\external_runs\r13_external_replay\r13_011\r13_011_external_replay_request.json -ExpectedResultRef state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json`: passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r13_external_replay.ps1 -RequestPath state\external_runs\r13_external_replay\r13_011\r13_011_external_replay_request.json -OutputRoot state\external_runs\r13_external_replay\r13_011`: blocked result emitted
- `Get-Command gh -ErrorAction SilentlyContinue`: blocked; see `state/external_runs/r13_external_replay/r13_011/raw_logs/check_github_cli_stderr.log`
- `Test GH_TOKEN and GITHUB_TOKEN environment variable presence without reading secret values`: blocked; see `state/external_runs/r13_external_replay/r13_011/raw_logs/check_github_tokens_stdout.log`
- `gh workflow run r13-external-replay.yml --repo RodneyMuniz/AIOffice_V2 --ref release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice -f branch=release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice -f expected_head=e9e8b4e21147d7c0906b4916297e3162690dbf64 -f expected_tree=520e2adf5e5fcbce2f81b23c872206d746e6b9c2 -f replay_scope=r13_011_external_replay_after_operator_demo`: not executed because authenticated dispatch prerequisites were unavailable
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_external_replay_request.ps1 -RequestPath state\external_runs\r13_external_replay\r13_011\r13_011_external_replay_request.json`: passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_external_replay_result.ps1 -ResultPath state\external_runs\r13_external_replay\r13_011\r13_011_external_replay_blocked.json`: passed

## Validation Results

- Request validator: passed for request `r13errq-6f4decf18a466337`, input refs `9`, command refs `8`.
- Blocked result validator: passed for result `r13err-775abf95e46412a0`, command results `3`, blocked commands `3`, aggregate verdict `blocked`.
- Manual dispatch packet: present at `state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json`.
- Raw logs: present under `state/external_runs/r13_external_replay/r13_011/raw_logs/`.

## Limitations

- Authenticated dispatch was unavailable because `gh` was not installed or not on `PATH`.
- `GH_TOKEN` and `GITHUB_TOKEN` were not present in the local environment.
- The available GitHub connector tools discovered in this session exposed workflow run/job/log reads, but no callable workflow dispatch or artifact import action.
- No GitHub Actions run ID, run URL, artifact ID, or artifact digest exists for R13-011.
- No external replay artifact was imported.
- R13-012 final QA signoff remains blocked until external replay evidence or an authorized later gate exists.

## Explicit Non-Claims

- no external replay has occurred
- no external replay proof is claimed
- no imported external replay artifact is claimed
- no final QA signoff has occurred
- no R13 hard value gate fully delivered by R13-011
- R13 is active through R13-011 only
- R13-012 through R13-018 remain planned only
- no R14 or successor opening
