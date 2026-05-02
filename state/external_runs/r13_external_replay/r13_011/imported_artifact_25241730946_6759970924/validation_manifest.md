# R13 External Replay Validation Manifest

- Workflow: R13 External Replay
- Repository: RodneyMuniz/AIOffice_V2
- Run ID: 25241730946
- Run URL: https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25241730946
- Run attempt: 1
- Branch input: release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice
- Expected head: 4787d5a59c67d5312ed72231f7a5571b435c1528
- Expected tree: f76567051d8b830a6153374b7d60376cf923e7bd
- Observed head: 4787d5a59c67d5312ed72231f7a5571b435c1528
- Observed tree: f76567051d8b830a6153374b7d60376cf923e7bd
- Replay scope: r13_011_external_replay_after_operator_demo
- Aggregate verdict: passed
- Artifact name: r13-external-replay-25241730946-1

## Command Results

- assert_requested_identity: passed (exit 0); stdout raw_logs/assert_requested_identity.stdout.log; stderr raw_logs/assert_requested_identity.stderr.log
- validate_r13_failure_fix_cycle: passed (exit 0); stdout raw_logs/validate_r13_failure_fix_cycle.stdout.log; stderr raw_logs/validate_r13_failure_fix_cycle.stderr.log
- validate_r13_before_after_comparison: passed (exit 0); stdout raw_logs/validate_r13_before_after_comparison.stdout.log; stderr raw_logs/validate_r13_before_after_comparison.stderr.log
- validate_r13_operator_demo: passed (exit 0); stdout raw_logs/validate_r13_operator_demo.stdout.log; stderr raw_logs/validate_r13_operator_demo.stderr.log
- validate_r13_control_room_status: passed (exit 0); stdout raw_logs/validate_r13_control_room_status.stdout.log; stderr raw_logs/validate_r13_control_room_status.stderr.log
- validate_r13_control_room_view: passed (exit 0); stdout raw_logs/validate_r13_control_room_view.stdout.log; stderr raw_logs/validate_r13_control_room_view.stderr.log
- validate_r13_control_room_refresh_result: passed (exit 0); stdout raw_logs/validate_r13_control_room_refresh_result.stdout.log; stderr raw_logs/validate_r13_control_room_refresh_result.stderr.log
- validate_r13_external_replay_request: passed (exit 0); stdout raw_logs/validate_r13_external_replay_request.stdout.log; stderr raw_logs/validate_r13_external_replay_request.stderr.log
- validate_r13_external_replay_blocked_result: passed (exit 0); stdout raw_logs/validate_r13_external_replay_blocked_result.stdout.log; stderr raw_logs/validate_r13_external_replay_blocked_result.stderr.log
- validate_status_doc_gate: passed (exit 0); stdout raw_logs/validate_status_doc_gate.stdout.log; stderr raw_logs/validate_status_doc_gate.stderr.log

## Limitations

- GitHub assigns artifact ID and artifact digest after upload; capture those from the completed workflow run before importing or claiming proof.
- This workflow performs bounded validation only and does not perform final QA signoff.
- This workflow does not open R14 or any successor milestone.

## Non-Claims

- no final QA signoff has occurred
- no R13 hard value gate fully delivered by R13-011
- no R14 or successor opening
