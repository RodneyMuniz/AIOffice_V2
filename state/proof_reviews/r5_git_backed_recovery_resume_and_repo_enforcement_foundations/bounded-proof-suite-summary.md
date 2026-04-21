# Bounded Proof Suite Summary

- Created at: 2026-04-21T13:54:39Z
- Repo branch: feature/r5-closeout-remaining-foundations
- Repo HEAD: 1a97ff0cef9675c88030d3b618ef928093ee080c
- Output root: C:\Users\rodne\OneDrive\Documentos\AIOffice_V2\state\proof_reviews\r5_git_backed_recovery_resume_and_repo_enforcement_foundations
- PowerShell executable: C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe
- Passed: 4
- Failed: 0
- Workspace mutation check passed: True

## Commands Replayed
- powershell -ExecutionPolicy Bypass -File tests\test_milestone_baseline.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_restore_gate.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_baton_persistence.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_resume_reentry.ps1

## Results
- r5-milestone-baseline: passed (49.553s) -> state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/tests/r5-milestone-baseline.txt
- r5-restore-gate: passed (22.988s) -> state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/tests/r5-restore-gate.txt
- r5-baton-continuity: passed (2.993s) -> state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/tests/r5-baton-continuity.txt
- r5-resume-reentry: passed (10.61s) -> state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/tests/r5-resume-reentry.txt
