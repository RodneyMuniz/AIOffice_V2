# R11 Candidate Closeout Evidence Inventory

## R11 Slice Evidence
- R11-001 opening and boundary freeze: `governance/DECISION_LOG.md`, `governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md`
- R11-002 cycle ledger/state-machine contract and validator: `contracts/cycle_controller/cycle_ledger.contract.json`, `tools/CycleLedger.psm1`, `tools/validate_cycle_ledger.ps1`, `tests/test_cycle_ledger.ps1`
- R11-003 thin cycle controller CLI: `tools/CycleController.psm1`, `tools/invoke_cycle_controller.ps1`, `tests/test_cycle_controller.ps1`
- R11-004 bootstrap/resume-from-repo-truth packets: `tools/CycleBootstrap.psm1`, `tools/prepare_cycle_bootstrap.ps1`, `tests/test_cycle_bootstrap_resume.ps1`
- R11-005 local-only residue guard: `tools/LocalResidueGuard.psm1`, `tools/invoke_local_residue_guard.ps1`, `tests/test_local_residue_guard.ps1`
- R11-006 bounded Dev execution adapter: `tools/DevExecutionAdapter.psm1`, `tools/invoke_dev_execution_adapter.ps1`, `tests/test_dev_execution_adapter.ps1`
- R11-007 separate QA gate: `tools/CycleQaGate.psm1`, `tools/invoke_cycle_qa_gate.ps1`, `tests/test_cycle_qa_gate.ps1`
- R11-008 controlled-cycle pilot root: `state/cycles/r11_008_controlled_cycle_pilot/`

## R11-008 Pilot Evidence
- Cycle ID: `cycle-r11-008-controlled-cycle-pilot`
- Operator request: `state/cycles/r11_008_controlled_cycle_pilot/operator_request.json`
- Cycle plan: `state/cycles/r11_008_controlled_cycle_pilot/cycle_plan.json`
- Operator approval: `state/cycles/r11_008_controlled_cycle_pilot/operator_approval.json`
- Cycle ledger: `state/cycles/r11_008_controlled_cycle_pilot/cycle_ledger.json`
- Bootstrap packet: `state/cycles/r11_008_controlled_cycle_pilot/bootstrap/bootstrap_packet.json`
- Next-action packet: `state/cycles/r11_008_controlled_cycle_pilot/bootstrap/next_action_packet.json`
- Clean local-residue preflight: `state/cycles/r11_008_controlled_cycle_pilot/residue_guard/preflight_scan.json`
- Dev dispatch packet: `state/cycles/r11_008_controlled_cycle_pilot/dev/dev_dispatch.json`
- Dev result packet: `state/cycles/r11_008_controlled_cycle_pilot/dev/dev_execution_result.json`
- Separate QA signoff: `state/cycles/r11_008_controlled_cycle_pilot/qa/cycle_qa_signoff.json`
- Audit packet: `state/cycles/r11_008_controlled_cycle_pilot/audit/cycle_audit_packet.json`
- Operator decision packet: `state/cycles/r11_008_controlled_cycle_pilot/decision/operator_decision_packet.json`
- Cycle summary: `state/cycles/r11_008_controlled_cycle_pilot/summary.md`

## Candidate Closeout Package
- Candidate packet: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/closeout_packet.json`
- Candidate review: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/closeout_review.md`
- Evidence inventory: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/evidence_inventory.md`
- Non-claims: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/non_claims.md`
- Candidate head ref: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/candidate_closeout_head_ref.md`
- Candidate tree ref: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/candidate_closeout_tree_ref.md`
- Validation manifest: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/validation_manifest.md`
- Raw validation logs: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/raw_logs/`

## Phase 2 Evidence Required Later
- Post-push final-head support packet: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/final_head_support/final_remote_head_support_packet.json`
- Raw post-push support logs: `state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/final_head_support/raw_logs/`