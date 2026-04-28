# R10 Candidate Closeout Replay Commands

The Phase 1 candidate package is replayed with these commands before committing:

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r10_two_phase_final_head_support.ps1`
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r10_two_phase_final_head_support.ps1 -ProcedurePath state\fixtures\valid\post_push_support\r10_two_phase_final_head_closeout_procedure.valid.json`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_external_runner_consuming_qa_signoff.ps1`
4. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_external_runner_consuming_qa_signoff.ps1 -PacketPath state\external_runs\r10_external_proof_bundle\25040949422\qa\external_runner_consuming_qa_signoff.json`
5. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_external_runner_closeout_identity.ps1 -PacketPath state\external_runs\r10_external_proof_bundle\25040949422\external_runner_closeout_identity.json`
6. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_external_proof_artifact_bundle.ps1 -BundlePath state\external_runs\r10_external_proof_bundle\25040949422\downloaded_artifact\external_proof_artifact_bundle.json`
7. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
8. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
9. `git diff --check`
10. `git diff --cached --check`

Raw command output is stored under `raw_logs/`.
