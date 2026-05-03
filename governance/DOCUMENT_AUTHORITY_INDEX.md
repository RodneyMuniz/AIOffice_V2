# AIOffice Document Authority Index

**Status:** Current R15 governance index
**Milestone:** R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations
**Purpose:** Classify current governance documents by authority class and proof treatment.

Generated Markdown and reports are operator artifacts unless backed by committed machine evidence. A report may explain evidence, but it is not proof by itself.

## Authority Classes

| Class | Name | Treatment |
| --- | --- | --- |
| Class A | Constitutional / product truth | Highest product doctrine for current repo truth. |
| Class B | Operating model / governance | Governs roles, process, state, release, safety, and cost controls. |
| Class C | Domain model / contract guidance | Defines domain concepts and target contracts; implementation still requires proof. |
| Class D | Reporting / templates | Standardizes reports and operator artifacts; not proof by itself. |
| Class E | Status / operational truth | Current status surfaces; must preserve milestone boundaries and non-claims. |
| Class F | Evidence / proof packages | Machine evidence and proof-review packages; strongest repo-local proof class. |
| Class G | Historical / report archive | Historical operator reports and pivot inputs; context only unless backed by evidence. |
| Class H | Candidate / future adapter references | Direction for future adapters/integrations; not implementation proof. |

## Current Major Documents

| Path | Class | Purpose | Owner role | Current authority | Proof by itself | Dependency references | Replacement/deprecation notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `governance/VISION.md` | Class A | Constitutional product vision after R13 failed/partial posture. | User / Operator | Yes | No | R13-018 report, R14 source pack inventory | Approved R14 replacement for prior vision. |
| `governance/R14_PRODUCT_VISION_PIVOT_AND_GOVERNANCE_ENFORCEMENT.md` | Class E | R14 opening, boundary, task plan, and non-claims. | Operator | Yes | No | R13-018, approved source pack | R14 accepted narrowly through R14-006; does not close R13. |
| `governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md` | Class E | R15 opening, boundary, task plan, R15-002 taxonomy slice, R15-003 repo knowledge index model slice, and non-claims. | Operator / Auditor | Yes | No | R14 closeout and planning brief, R14 proof package, R14 source head/tree | Current R15 milestone authority; R15 active through R15-003 only. |
| `governance/PRODUCT_OPERATING_MODEL.md` | Class B | Double Diamond, board/card operating loop, and delivery posture. | Operator / PM | Yes | No | `governance/VISION.md` | New R14 authority. |
| `governance/ROLE_RACI_AND_AGENT_AUTHORITY_MODEL.md` | Class B | Role boundaries, authority, and RACI rules. | Operator / Auditor | Yes | No | `governance/VISION.md`, `governance/PRODUCT_OPERATING_MODEL.md` | New R14 authority. |
| `governance/AGENT_IDENTITY_AND_MEMORY_MODEL.md` | Class B | Agent identity, memory scope, authority, and output boundaries. | Operator / Auditor | Yes | No | RACI model, context model | New R14 authority; target-state agent roles are not proof. |
| `governance/CONTEXT_AND_COMPACTION_CONTROL_MODEL.md` | Class B | Context, compaction, re-entry, baton, and recovery direction. | Operator / Auditor | Yes | No | Agent identity model, knowledge model | New R14 authority; does not solve Codex compaction. |
| `governance/RELEASE_AND_ENVIRONMENT_STRATEGY.md` | Class B | Branch, environment, promotion, rollback, and release direction. | Release/Closeout Agent | Yes | No | Existing release branches and proof packages | New R14 authority; not release automation. |
| `governance/SECURITY_SAFETY_AND_COST_CONTROL_MODEL.md` | Class B | Safety, stop controls, permissions, cost posture, and risk controls. | Operator / Auditor | Yes | No | Release model, architecture direction | New R14 authority; not runtime enforcement. |
| `governance/KPI_DOMAIN_MODEL.md` | Class C | Ten-domain maturity, confidence, and score guidance. | Operator / Auditor | Yes | No | Milestone reporting standard | New R14 authority. |
| `governance/BOARD_AND_WORK_ITEM_MODEL.md` | Class C | Board/card taxonomy, state model, and external mirror rules. | PM | Yes | No | Vision, product operating model, RACI model | New R14 authority; not a board implementation. |
| `governance/KNOWLEDGE_BASE_AND_ARTIFACT_REGISTRY_MODEL.md` | Class C | Knowledge layers, artifact registry, and classification direction. | Knowledge Curator | Yes | No | Vision, context model | New R14 authority; not a populated KB engine. |
| `governance/MILESTONE_REPORTING_STANDARD.md` | Class D | Required milestone report structure and evidence treatment. | Auditor / Release/Closeout Agent | Yes | No | KPI domain model, report template | New R14 authority. |
| `governance/templates/AIOffice_Milestone_Report_Template_v2.md` | Class D | Reusable milestone report template. | Auditor / Release/Closeout Agent | Yes | No | Milestone reporting standard | New R14 template. |
| `governance/ARCHITECTURE_AND_INTEGRATION_DIRECTION.md` | Class H | Candidate direction for GitHub, Linear, custom board, Symphony-inspired runners, and Codex/OpenAI surfaces. | Architect | Yes, direction only | No | Vision, board model, release model | Future adapter reference only; no integration is implemented by R14. |
| `README.md` | Class E | Human entrypoint and current repo-truth summary. | Operator | Yes | No | Active state, milestone authorities, reports | Updated for R15 active posture. |
| `governance/ACTIVE_STATE.md` | Class E | Current operational truth, active milestone, guardrails, and next step. | Operator | Yes | No | KANBAN, decision log, milestone authorities | Updated for R15 active posture. |
| `execution/KANBAN.md` | Class E | Task board for current and historical milestone task states. | PM / Operator | Yes | No | Active state, decision log | Updated with R15-001 through R15-003 done and R15-004 through R15-009 planned only. |
| `governance/DECISION_LOG.md` | Class E | Accepted governance decisions. | Operator | Yes | No | Milestone authorities, task evidence | Appended R15-003 repo knowledge index model decision. |
| `contracts/knowledge/artifact_classification_taxonomy.contract.json` | Class C | R15-002 machine-checkable artifact classification taxonomy. | Knowledge Curator / Auditor | Yes | No | Knowledge model, document authority index, R15 authority | Defines taxonomy only; does not classify the whole repo. |
| `state/knowledge/r15_artifact_classification_taxonomy.json` | Class F | Committed R15-002 taxonomy artifact matching the validated taxonomy. | Knowledge Curator / Auditor | Yes | Mixed; taxonomy structure is machine evidence for R15-002 only | Taxonomy contract, validator, tests | Does not implement the repo knowledge index or artifact registry engine. |
| `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_002_artifact_classification_taxonomy/` | Class F | R15-002 evidence folder with summary, manifest, and non-claims. | Auditor | Yes | Mixed; JSON summaries and manifests are evidence for R15-002 only | R15-002 validator/test commands | R15-003 has separate evidence; R15-004 through R15-009 remain planned only. |
| `contracts/knowledge/repo_knowledge_index.contract.json` | Class C | R15-003 machine-checkable repo knowledge index contract. | Knowledge Curator / Auditor | Yes | No | R15-002 taxonomy, knowledge model, document authority index, R15 authority | Defines the index model only; does not implement a full repo index or knowledge-base engine. |
| `state/knowledge/r15_repo_knowledge_index.json` | Class F | Committed R15-003 bounded seed repo knowledge index artifact. | Knowledge Curator / Auditor | Yes | Mixed; machine evidence for bounded R15-003 seed only | Repo knowledge index contract, taxonomy artifact, validator, tests | Bounded seed over current authority documents only; not full repo classification. |
| `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_003_repo_knowledge_index_model/` | Class F | R15-003 evidence folder with summary, manifest, and non-claims. | Auditor | Yes | Mixed; JSON summaries and manifests are evidence for R15-003 only | R15-003 validator/test commands | R15-004 through R15-009 remain planned only. |
| `governance/BRANCHING_CONVENTION.md` | Class B | Release branch naming and branch-truth rules. | Operator | Yes | No | Active state, release strategy | Existing authority; R14 follows release branch pattern. |
| `governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md` | Class G | R13 authority and task record. | Operator | Historical/current R13 boundary | No | R13 evidence and reports | R13 remains failed/partial and not closed. |
| `governance/reports/AIOffice_V2_R13_Final_Failed_Partial_Report_and_Conditional_Successor_Recommendation_v1.md` | Class G | R13 failed/partial operator report and conditional successor recommendation. | Operator | Historical report authority | No | R13-017 decision, R13 scorecard | Does not open R14 by itself. |
| `governance/reports/pivot_inputs/AIOffice_Document_Update_Plan_v1.md` | Class G | Approved pivot input plan installed from source pack. | Operator | Context for R14 | No | Source pack inventory | Root source-pack file installed under pivot inputs. |
| `governance/reports/AIOffice_V2_R14_Pivot_Closeout_and_R15_Planning_Brief_v1.md` | Class G | R14 operator closeout and R15 planning brief. | Operator | Current R14 operator artifact | No | R14 proof package, installed docs | Planning-only; does not open R15. |
| `state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/` | Class F | R14 inventory, validation package, non-claims, and command results. | Auditor | Yes | Mixed; machine inventories are evidence, reports are not proof alone | R14 installed docs and validation commands | New R14 proof-review package. |
| `state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/opening/` | Class F | R15 opening evidence package. | Auditor | Yes | Mixed; JSON packets and manifests are evidence for opening only | R15 authority doc and status gate validation | R15-001 opening proof only; later R15 tasks require their own evidence folders. |
| `governance/_operator_inbox/aioffice_vision_update/` | Class F | Preserved approved local source pack. | Operator | Source pack authority for R14 install only | Source files prove source content/hash, not implementation | R14 source inventory | Preserved in place; not deleted. |

## Dependency Rule

Class A and B documents define product and governance truth, but target-state capabilities inside them remain non-claims until Class F evidence proves implementation or execution.
