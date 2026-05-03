# R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations

**Milestone status:** Active in repo truth through `R15-004` only
**Opened from branch:** `release/r14-product-vision-pivot-and-governance-enforcement`
**Source R14 head:** `43653f3dd2e18b46c9e7b02f0c9c095848aee6fc`
**Source R14 tree observed locally:** `2af1a4aaa858af315e9b4d106d0643b5ce4ebfcc`
**R15 branch:** `release/r15-knowledge-base-agent-identity-memory-raci-foundations`
**Scope:** Foundation milestone only

R15 opens as the first post-pivot foundation milestone after the accepted-with-caveats R14 posture. R15 is not product runtime, productized UI, external board sync, true multi-agent execution, persistent memory implementation, or integration work.

`R15-001` through `R15-004` are complete. `R15-005` through `R15-009` are planned only.

## Purpose

R15 makes the knowledge base, artifact classification, agent identity, memory scope, RACI/state-transition, and card re-entry substrate explicit and machine-checkable.

R15 prepares AIOffice for future board-driven, role-separated execution without implementing the product board runtime, external board sync, real agent runtime, persistent memory engine, or multi-agent execution.

## Accepted Starting State From R14

R14 is accepted as a narrow documentation, governance, and reporting-enforcement milestone with caveats. R14 is not product runtime, productized UI, integration work, or R15 implementation.

The R14 source branch was verified locally before opening R15:

- Branch: `release/r14-product-vision-pivot-and-governance-enforcement`
- Head: `43653f3dd2e18b46c9e7b02f0c9c095848aee6fc`
- Tree observed locally: `2af1a4aaa858af315e9b4d106d0643b5ce4ebfcc`
- Worktree: clean before the R15 branch was created

R13 remains failed/partial, active through `R13-018` only, not closed, without final-head support, without a closeout package, and without a main merge.

R13 partial gates remain partial:

- API/custom-runner bypass.
- Current operator control room.
- Skill invocation evidence.
- Operator demo.

## Strict R15 Boundary

R15 is a foundation milestone only. It may define governance models, schemas, task-plan placeholders, and validation expectations for knowledge base, artifact classification, agent identity, memory scope, RACI/state transitions, and card re-entry.

R15 must not implement:

- no product runtime;
- no productized UI;
- no board engine or custom board runtime;
- no GitHub Projects integration;
- no Linear integration;
- no Symphony integration;
- no external board sync;
- no real agent runtime;
- no true multi-agent execution;
- no persistent memory engine;
- no Codex reliability or compaction solution claims.

## R15 Task List

### `R15-001` Open R15 in repo truth
- Status: done
- Purpose: open R15 from accepted R14 posture and record the R15 task plan, boundaries, and non-claims.
- Durable output: this authority document, status-surface updates, and the opening evidence package under `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/opening/`.

### `R15-002` Define artifact classification taxonomy
- Status: done
- Purpose: define a machine-checkable taxonomy for repo artifacts, including documents, contracts, tools, tests, reports, proof packages, state files, generated artifacts, operator artifacts, external evidence, deprecated material, cleanup candidates, and unknown items.
- Durable output:
  - `contracts/knowledge/artifact_classification_taxonomy.contract.json`
  - `tools/R15ArtifactClassificationTaxonomy.psm1`
  - `tools/validate_r15_artifact_classification_taxonomy.ps1`
  - `tests/test_r15_artifact_classification_taxonomy.ps1`
  - `state/fixtures/valid/knowledge/r15_artifact_classification_taxonomy.valid.json`
  - `state/fixtures/invalid/knowledge/r15_artifact_classification_taxonomy/`
  - `state/knowledge/r15_artifact_classification_taxonomy.json`
  - `state/knowledge/r15_artifact_classification_taxonomy_validation_manifest.md`
  - `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_002_artifact_classification_taxonomy/`

### `R15-003` Create repo knowledge index model
- Status: done
- Purpose: define a machine-readable index for important docs, contracts, tools, tests, reports, proof packages, state files, and their authority levels.
- Durable output:
  - `contracts/knowledge/repo_knowledge_index.contract.json`
  - `tools/R15RepoKnowledgeIndex.psm1`
  - `tools/validate_r15_repo_knowledge_index.ps1`
  - `tests/test_r15_repo_knowledge_index.ps1`
  - `state/fixtures/valid/knowledge/r15_repo_knowledge_index.valid.json`
  - `state/fixtures/invalid/knowledge/r15_repo_knowledge_index/`
  - `state/knowledge/r15_repo_knowledge_index.json`
  - `state/knowledge/r15_repo_knowledge_index_validation_manifest.md`
  - `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_003_repo_knowledge_index_model/`

### `R15-004` Define agent identity packet model
- Status: done
- Purpose: define a contract/model for each agent identity, including role, responsibility, authority, memory scope, allowed tools, forbidden actions, input contracts, and output artifacts.
- Durable output:
  - `contracts/agents/agent_identity_packet.contract.json`
  - `tools/R15AgentIdentityPacket.psm1`
  - `tools/validate_r15_agent_identity_packet.ps1`
  - `tests/test_r15_agent_identity_packet.ps1`
  - `state/fixtures/valid/agents/r15_agent_identity_packet.valid.json`
  - `state/fixtures/invalid/agents/r15_agent_identity_packet/`
  - `state/agents/r15_agent_identity_packet.json`
  - `state/agents/r15_agent_identity_packet_validation_manifest.md`
  - updated bounded knowledge index `state/knowledge/r15_repo_knowledge_index.json`
  - `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_004_agent_identity_packet_model/`

### `R15-005` Define agent memory scope model
- Status: planned
- Purpose: define global, role, card, run, evidence, knowledge, and historical memory scopes, including what each agent may load and must not load.

### `R15-006` Define RACI and state-transition matrix
- Status: planned
- Purpose: define who is Responsible, Accountable, Consulted, and Informed for card states and transitions.

### `R15-007` Define card re-entry packet model
- Status: planned
- Purpose: define how a card tells a role-specific agent exactly what to load, what evidence to inspect, what constraints apply, and what not to scan.

### `R15-008` Run one classification and re-entry dry run
- Status: planned
- Purpose: apply the R15 models to one bounded existing R13/R14 evidence slice to prove that classification and re-entry reduce full-repo scanning.

### `R15-009` Produce R15 proof/review package
- Status: planned
- Purpose: consolidate R15 evidence, validation, non-claims, and next-stage recommendation without opening R16.

## Explicit Non-Claims

R15-001 claims only:

- R15 opened explicitly after accepted R14 audit/posture.
- R15 authority doc exists.
- R15 task plan exists.
- R15 opening evidence packet exists.
- Status surfaces were updated.
- Validation was run and recorded.

R15-001 does not claim:

- no artifact taxonomy implemented;
- no knowledge index implemented;
- no agent identity packets implemented;
- no memory scopes implemented;
- no RACI matrix implemented;
- no card re-entry packet implemented;
- no dry run executed;
- no proof package complete;
- no product runtime;
- no board runtime;
- no multi-agent runtime;
- no external board sync;
- no Symphony integration;
- no Linear integration;
- no GitHub Projects integration;
- no custom board implementation;
- no persistent memory engine implementation;
- no solved Codex compaction;
- no solved Codex reliability;
- no R16 opening.

R15-002 claims only:

- artifact classification taxonomy contract exists;
- validator module exists;
- CLI wrapper exists;
- valid and invalid fixtures exist;
- focused tests exist;
- committed taxonomy artifact exists;
- validation manifest exists;
- R15-002 evidence folder exists;
- status surfaces were updated;
- validation passed.

R15-002 does not claim:

- no full repo artifacts classified;
- no repo knowledge index implemented;
- no artifact registry engine implemented;
- no knowledge base implemented;
- no deprecated files cleaned;
- no cleanup decisions approved;
- no agent identity packets implemented;
- no memory scopes implemented;
- no RACI matrix implemented;
- no card re-entry packets implemented;
- no classification or re-entry dry run executed;
- no final R15 proof package complete;
- no product runtime;
- no board runtime;
- no external board sync;
- no Linear implementation;
- no Symphony implementation;
- no GitHub Projects implementation;
- no custom board implementation;
- no true multi-agent execution;
- no persistent memory engine;
- no solved Codex compaction;
- no solved Codex reliability;
- no R16 opening.

R15-003 claims only:

- repo knowledge index contract exists;
- validator module exists;
- CLI wrapper exists;
- valid and invalid fixtures exist;
- focused tests exist;
- bounded seed knowledge index artifact exists;
- validation manifest exists;
- R15-003 evidence folder exists;
- status surfaces were updated;
- validation passed.

R15-003 does not claim:

- no full repo index implemented by R15-003;
- no full repo artifacts classified by R15-003;
- no knowledge-base engine implemented by R15-003;
- no artifact registry engine implemented by R15-003;
- no retrieval engine implemented by R15-003;
- no vector search implemented by R15-003;
- no Obsidian integration by R15-003;
- no GitHub Projects integration;
- no Linear implementation;
- no Symphony implementation;
- no custom board implementation;
- no agent identity packets implemented;
- no memory scopes implemented;
- no RACI matrix implemented;
- no card re-entry packets implemented;
- no classification or re-entry dry run executed;
- no final R15 proof package complete;
- no product runtime;
- no board runtime;
- no external board sync;
- no true multi-agent execution;
- no persistent memory engine;
- no R16 opening;
- no solved Codex compaction;
- no solved Codex reliability.

R15-004 claims only:

- agent identity packet contract exists;
- validator module exists;
- CLI wrapper exists;
- valid and invalid fixtures exist;
- focused tests exist;
- committed baseline identity packet set exists;
- validation manifest exists;
- bounded knowledge index was updated with R15-004 entries;
- R15-004 evidence folder exists;
- status surfaces were updated;
- validation passed.

R15-004 does not claim:

- no actual agents implemented by R15-004;
- no direct agent access runtime implemented;
- no true multi-agent execution implemented;
- no persistent memory engine implemented;
- no memory scopes implemented beyond identity packet refs by R15-004;
- no RACI matrix implemented;
- no card re-entry packet implemented;
- no board routing implemented;
- no PM automation implemented;
- no Developer/QA/Auditor runtime separation implemented;
- no final R15 proof package complete;
- no product runtime;
- no board runtime;
- no external board sync;
- no integrations implemented;
- no GitHub Projects implementation;
- no Linear implementation;
- no Symphony implementation;
- no custom board implementation;
- no R16 opening;
- no solved Codex compaction;
- no solved Codex reliability.

## Exit Criteria

R15 may exit only when:

- `R15-001` through `R15-009` have committed evidence matching their planned boundary.
- R15 models are explicit enough to support machine validation.
- The dry run is bounded to one existing R13/R14 evidence slice and does not become broad repo scanning.
- The proof/review package preserves R13 failed/partial status and R14 narrow acceptance.
- The proof/review package records validation commands, results, non-claims, rejected claims, and next-stage recommendation without opening R16.

## Dependencies

R15 depends on:

- `governance/VISION.md`
- `governance/PRODUCT_OPERATING_MODEL.md`
- `governance/ROLE_RACI_AND_AGENT_AUTHORITY_MODEL.md`
- `governance/AGENT_IDENTITY_AND_MEMORY_MODEL.md`
- `governance/BOARD_AND_WORK_ITEM_MODEL.md`
- `governance/KNOWLEDGE_BASE_AND_ARTIFACT_REGISTRY_MODEL.md`
- `governance/CONTEXT_AND_COMPACTION_CONTROL_MODEL.md`
- `governance/KPI_DOMAIN_MODEL.md`
- `governance/MILESTONE_REPORTING_STANDARD.md`
- `governance/DOCUMENT_AUTHORITY_INDEX.md`
- `governance/reports/AIOffice_V2_R14_Pivot_Closeout_and_R15_Planning_Brief_v1.md`
- `state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/r14_validation_summary.json`
- `state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/validation_manifest.md`

## Risks

- R15 could accidentally imply implemented runtime capability when it only defines foundation models.
- R15 could accidentally convert R13 partial gates into passed gates.
- R15 could blur R14 accepted-with-caveats documentation posture into product proof.
- R15 could create broad scanning pressure instead of reducing context burn.
- R15 must not imply solved Codex reliability or solved Codex compaction.
- R15 could open R16 by recommendation language rather than explicit future authority.

## Validation Requirements

The R15-004 slice must run and record:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_agent_identity_packet.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_agent_identity_packet.ps1 -PacketPath state\agents\r15_agent_identity_packet.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_repo_knowledge_index.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_repo_knowledge_index.ps1 -IndexPath state\knowledge\r15_repo_knowledge_index.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r15_artifact_classification_taxonomy.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r15_artifact_classification_taxonomy.ps1 -TaxonomyPath state\knowledge\r15_artifact_classification_taxonomy.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1`
- `git diff --check`
- `git status --short`
- `git rev-parse HEAD`
- `git rev-parse HEAD^{tree}`
- `git branch --show-current`

The status gate must accept only this R15 posture:

- R13 failed/partial through `R13-018` only.
- R14 accepted/narrowly complete through `R14-006`.
- R15 active through `R15-004` only.
- `R15-005` through `R15-009` planned only.
- No R16 or successor opening.
- No product/runtime/integration/agent-execution overclaims.

## R15-004 Slice Status

After this slice, `R15-001` through `R15-004` are complete.

`R15-005` through `R15-009` are planned only. R15-004 defines the identity packet model only; it does not implement actual agents, direct agent access runtime, true multi-agent execution, persistent memory, memory scopes beyond identity packet refs, the RACI matrix, card re-entry packets, board routing, the classification/re-entry dry run, the final R15 proof package, or R16.
