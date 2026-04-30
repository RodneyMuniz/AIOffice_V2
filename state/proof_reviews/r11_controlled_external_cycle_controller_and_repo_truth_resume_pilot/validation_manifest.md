# R11 Candidate Closeout Validation Manifest

Phase 1 validation logs are recorded under `raw_logs/`.

Status: all Phase 1 candidate closeout validations passed.

## Commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_cycle_ledger.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_ledger.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_ledger.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_cycle_ledger.ps1 -LedgerPath state\fixtures\valid\cycle_controller\cycle_ledger.valid.json`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/validate_cycle_ledger.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/validate_cycle_ledger.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_cycle_controller.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_controller.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_controller.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_cycle_bootstrap_resume.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_bootstrap_resume.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_bootstrap_resume.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_local_residue_guard.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_local_residue_guard.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_local_residue_guard.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_dev_execution_adapter.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_dev_execution_adapter.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_dev_execution_adapter.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_cycle_qa_gate.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_qa_gate.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_cycle_qa_gate.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r11_controlled_cycle_pilot.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_r11_controlled_cycle_pilot.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_r11_controlled_cycle_pilot.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_status_doc_gate.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/test_status_doc_gate.stderr.log`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/validate_status_doc_gate.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/validate_status_doc_gate.stderr.log`
- `git diff --check`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/git_diff_check.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/git_diff_check.stderr.log`
- `git diff --cached --check`: exit code `0`; stdout `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/git_diff_cached_check.stdout.log`; stderr `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/git_diff_cached_check.stderr.log`

## Candidate Boundary
- This manifest supports only the Phase 1 candidate closeout package.
- R11 is not accepted as closed until Phase 2 post-push final-head support verifies the pushed candidate closeout commit.
- No R12 or successor milestone is opened by this candidate package.
- No claim beyond one bounded R11 controlled-cycle pilot is accepted.
