# R13-006 Validation Manifest

- Selected fix item ID: $selectedFixItemId
- Selected source issue ID: $selectedSourceIssueId
- Selected issue type: $selectedIssueType
- Source issue report ref: $issueReportRef
- Fix queue ref: $fixQueueRef
- Bounded fix execution ref: $boundedExecutionRef
- Before report ref: $beforeReportRef
- After report ref: $afterReportRef
- Comparison ref: $comparisonRef

## Exact Validation Commands Run

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_r13_qa_failure_fix_cycle.ps1 -IssueReportPath state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json -FixQueuePath state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json -BoundedFixExecutionPath state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json -OutputRoot state/cycles/r13_qa_cycle_demo -FixItemId r13qf-5efcc675b9ec2995
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_fix_execution_result.ps1 -ResultPath state/cycles/r13_qa_cycle_demo/fix_execution_result.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_before_after_comparison.ps1 -ComparisonPath state/cycles/r13_qa_cycle_demo/before_after_comparison.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_failure_fix_cycle.ps1 -CyclePath state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r13_qa_failure_fix_cycle.ps1

## Explicit Non-Claims

- R13-006 runs one controlled demo workspace QA failure-to-fix cycle only.
- Canonical invalid detector fixtures were not mutated.
- No external replay has occurred.
- No final QA signoff has occurred.
- No R13 hard value gate is delivered yet.
- No production QA is claimed.
- No R14 or successor milestone is opened.
