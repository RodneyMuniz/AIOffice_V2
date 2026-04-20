# Bounded Proof Suite Summary

- Created at: 2026-04-20T11:34:32Z
- Repo branch: main
- Repo HEAD: 47b7cf99f1720c2f191f044e95b354de1a814047
- Output root: C:\Users\rodne\AppData\Local\Temp\aioffice-r4-corrective-983c483b5a0147618ba062299b4f9222\state\proof_reviews\r4_control_kernel_hardening_and_ci_foundations
- PowerShell executable: C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe
- Passed: 13
- Failed: 0
- Workspace mutation check passed: True

## Commands Replayed
- powershell -ExecutionPolicy Bypass -File tests\test_stage_artifact_contracts.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_packet_record_storage.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_gate.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_action.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_supervised_admin_flow.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_governed_work_object_contracts.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_planning_record_storage.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_work_artifact_contracts.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_request_brief_task_packet_flow.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_execution_bundle_qa_gate.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_baton_persistence.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_r3_planning_replay.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_bounded_proof_ci_foundation.ps1

## Results
- r2-stage-artifact-contracts: passed (0.47s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r2-stage-artifact-contracts.txt
- r2-packet-record-storage: passed (0.98s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r2-packet-record-storage.txt
- r2-apply-promotion-gate: passed (1.221s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r2-apply-promotion-gate.txt
- r2-apply-promotion-action: passed (1.399s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r2-apply-promotion-action.txt
- r2-supervised-admin-flow: passed (1.999s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r2-supervised-admin-flow.txt
- r3-governed-work-object-contracts: passed (0.534s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-governed-work-object-contracts.txt
- r3-planning-record-storage: passed (1.276s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-planning-record-storage.txt
- r3-work-artifact-contracts: passed (1.397s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-work-artifact-contracts.txt
- r3-request-brief-task-packet-flow: passed (1.389s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-request-brief-task-packet-flow.txt
- r3-execution-bundle-qa-gate: passed (5.923s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-execution-bundle-qa-gate.txt
- r3-baton-persistence: passed (2.814s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-baton-persistence.txt
- r3-planning-replay: passed (2.448s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r3-planning-replay.txt
- r4-ci-foundation: passed (0.193s) -> state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/r4-ci-foundation.txt
