# R16-003 KPI Baseline and Target Scorecard Validation Manifest

**Milestone:** R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation
**Task:** R16-003
**Branch:** `release/r16-operational-memory-artifact-map-role-workflow-foundation`
**Generated from head:** `794088b584063953789dabb6a167c51714e23181`
**Generated from tree:** `8f99aaed5142f10402172054c710e3c254a52d2f`

## Scope

R16-003 adds the KPI baseline and target scorecard only. The scorecard uses the approved 10-domain KPI model, records achieved current maturity separately from R16 closeout targets, preserves evidence caps and confidence scoring, and makes the two priority target jumps explicit:

- Knowledge, Memory & Context Compression
- Agent Workforce & RACI

R16 active through R16-003 only. R16-004 through R16-026 remain planned only.

KPI targets are not achieved scores.

## Scorecard Summary

- Current weighted score: `41.6`
- Target weighted score: `64.8`
- Knowledge, Memory & Context Compression: current maturity `2`, target maturity `4`
- Agent Workforce & RACI: current maturity `2`, target maturity `4`

## Preserved Boundaries

- R13 remains failed/partial through `R13-018` only and is not closed.
- R13 partial gates remain partial: API/custom-runner bypass, current operator control room, skill invocation evidence, and operator demo.
- R14 remains accepted with caveats through `R14-006` only.
- R15 remains accepted with caveats through `R15-009` only.
- R15 audited head remains `d9685030a0556a528684d28367db83f4c72f7fc9`.
- R15 audited tree remains `7529230df0c1f5bec3625ba654b035a2af824e9b`.
- R15 post-audit support commit remains `3058bd6ed5067c97f744c92b9b9235004f0568b0`.
- The R15-009 stale `generated_from_head` and `generated_from_tree` caveat remains preserved.

## Commands To Record

| Command | Result |
| --- | --- |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_kpi_baseline_target_scorecard.ps1` | passed; valid passed: 5; invalid rejected: 23 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state\governance\r16_kpi_baseline_target_scorecard.json` | passed; 10 domains, weight sum 100, current weighted score 41.6, target weighted score 64.8, active through R16-003, planned range R16-004..R16-026 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1` | passed; valid passed: 4; invalid rejected: 15; live status accepted as R16 active through R16-003 only |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_planning_authority_reference.ps1 -PacketPath state\governance\r16_planning_authority_reference.json` | passed; R16-002 packet remains valid with 2 operator-approved planning artifacts and packet posture active_through R16-002 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1` | passed; valid passed: 1; invalid rejected: 70 |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1` | passed; status gate accepts R16 active through R16-003 with R16-004 through R16-026 planned and rejects target-as-achieved KPI scoring |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1` | passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1` | passed |
| `git diff --check` | passed; no whitespace errors |
| `git status --short` | passed; R16-003 scoped working-tree changes present before commit |
| `git rev-parse HEAD` | `794088b584063953789dabb6a167c51714e23181` |
| `git rev-parse "HEAD^{tree}"` | `8f99aaed5142f10402172054c710e3c254a52d2f` |
| `git branch --show-current` | `release/r16-operational-memory-artifact-map-role-workflow-foundation` |

## Non-Claims

No memory layers, artifact maps, audit maps, context-load planners, role-run envelopes, handoff packets, workflow drills, product runtime, agents, integrations, retrieval/vector runtime, solved Codex reliability, or solved Codex compaction are claimed.
