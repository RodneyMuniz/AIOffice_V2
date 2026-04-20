# Post-R3 Audit Index

## Purpose
This index maps the completed bounded R3 state to the exact governing docs, implementation modules, focused tests, milestone commits, and exclusions that an independent GPT Pro audit should preserve. It is an audit-readiness surface only and not a next-phase planning record.

## Milestone-To-Commit Mapping
- `R3-001` repo-truth closeout and milestone open: `6ba1d03ddfb413cd71bc4bb23269a6636530cca2`
- `R3-002` governed work object contracts: `fd575d886aa7440003861396aecb108805a7b1d8`
- `R3-003` planning-record storage and validation: `83808b4d10ba1eaf68ecf67485a5a5c5c1a36fa5`
- `R3-004` Request Brief / Task Packet / Execution Bundle / QA Report / External Audit Pack / Baton contracts: `0a19832dd40933c7118d865bee1bbc110a2ec670`
- `R3-005` bounded Request Brief -> Task Packet flow: `d0693bea9b133831748741fcf8d85abc10571df2`
- `R3-006` bounded QA gate with remediation tracking and External Audit Pack assembly: `47f164c56f6941b31410ee0b4577f8b1963c1540`
- `R3-007` minimal Baton persistence and load foundation: `6da95e1fc171a9334b6f68c9b581ddbe20399374`
- `R3-008` replayable bounded R3 planning proof: `63f8d81dd16f730dd01cbd70d0c04ec70cd21d77`

## Governing Docs Supporting R3 Truth
- `README.md`
- `governance/VISION.md`
- `governance/V1_PRD.md`
- `governance/OPERATING_MODEL.md`
- `governance/ACTIVE_STATE.md`
- `execution/KANBAN.md`
- `governance/R3_GOVERNED_WORK_OBJECTS_AND_DOUBLE_AUDIT_FOUNDATIONS.md`
- `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md`

## Implementation Modules By Bounded Capability
- governed work object contracts and invariants:
  - `contracts/governed_work_objects/foundation.contract.json`
  - `contracts/governed_work_objects/project.contract.json`
  - `contracts/governed_work_objects/milestone.contract.json`
  - `contracts/governed_work_objects/task.contract.json`
  - `contracts/governed_work_objects/bug.contract.json`
  - `tools/GovernedWorkObjectValidation.psm1`
- planning-record storage and validation:
  - `contracts/planning_records/foundation.contract.json`
  - `contracts/planning_records/planning_record.contract.json`
  - `tools/PlanningRecordStorage.psm1`
- work artifact contracts and validation:
  - `contracts/work_artifacts/foundation.contract.json`
  - `contracts/work_artifacts/request_brief.contract.json`
  - `contracts/work_artifacts/task_packet.contract.json`
  - `contracts/work_artifacts/execution_bundle.contract.json`
  - `contracts/work_artifacts/qa_report.contract.json`
  - `contracts/work_artifacts/external_audit_pack.contract.json`
  - `contracts/work_artifacts/baton.contract.json`
  - `tools/WorkArtifactValidation.psm1`
- bounded planning flow:
  - `tools/RequestBriefTaskPacketPlanningFlow.psm1`
- bounded QA gate and audit packaging:
  - `tools/ExecutionBundleQaGate.psm1`
- bounded Baton foundation:
  - `tools/BatonPersistence.psm1`
- bounded replay proof:
  - `tools/R3PlanningReplayProof.psm1`

## Focused Tests By Bounded Capability
- governed work object contracts: `tests/test_governed_work_object_contracts.ps1`
- planning-record storage and validation: `tests/test_planning_record_storage.ps1`
- work artifact contracts: `tests/test_work_artifact_contracts.ps1`
- bounded Request Brief -> Task Packet flow: `tests/test_request_brief_task_packet_flow.ps1`
- bounded QA gate with remediation tracking and External Audit Pack assembly: `tests/test_execution_bundle_qa_gate.ps1`
- bounded Baton persistence and load foundation: `tests/test_baton_persistence.ps1`
- bounded replay proof: `tests/test_r3_planning_replay.ps1`

## Replay Proof Surface
The direct replay proof surface is:
- runner: `tools/R3PlanningReplayProof.psm1`
- focused proof command: `powershell -ExecutionPolicy Bypass -File tests\test_r3_planning_replay.ps1`
- committed request input fixture: `state/fixtures/valid/request_brief_task_packet_flow.request_brief.valid.json`
- committed QA observation fixture: `state/fixtures/valid/qa_gate.observation.fail.json`
- generated proof chain:
  - Task Packet
  - prepared Execution Bundle
  - QA gate result
  - QA Report
  - remediation record
  - External Audit Pack
  - Baton
  - replay summary record

## Limits And Exclusions The Auditor Must Preserve
- Preserve the bounded claim only. R3 proves one direct replayable planning slice and does not prove broader workflow orchestration.
- Preserve the no-auto-resume boundary. Baton support is foundation-only and not an automatic resume engine.
- Preserve the no-recovery boundary. R3 does not prove rollback or broader recovery productization.
- Preserve the no-broad-UI boundary. R3 does not prove control-room or broad UI productization.
- Preserve the no-Standard-pipeline boundary. R3 does not prove Standard or subproject pipeline productization.
- Preserve the reference-only boundary for `governance/Product Vision V1 baseline/`. That tracked folder is not milestone evidence for bounded R3.
