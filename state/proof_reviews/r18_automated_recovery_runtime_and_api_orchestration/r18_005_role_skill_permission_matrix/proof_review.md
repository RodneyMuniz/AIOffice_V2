# R18-005 Role-to-Skill Permission Matrix Proof Review

## Scope
R18-005 creates a governance/control permission matrix only. It binds each R18 role from R18-002 agent cards to each governed skill from the R18-003 skill registry with allowed, denied, or approval-required status.

## Positive Claims
- r18_role_skill_permission_matrix_contract_created
- r18_role_skill_permission_matrix_created
- r18_role_skill_permission_matrix_validator_created
- r18_role_skill_permission_matrix_fixtures_created
- r18_role_skill_permission_matrix_proof_review_created

## Non-Claims
- Permission matrix is not runtime enforcement.
- No A2A messages were sent.
- No live agents were invoked.
- No live skills were executed.
- No A2A runtime, local runner runtime, or recovery runtime was implemented.
- No OpenAI API or Codex API invocation occurred.
- No automatic new-thread creation occurred.
- R18-006 through R18-028 remain planned only.
- Main is not merged.

## Validation Expectation
The focused validator and tests fail closed on unknown roles, unknown skills, wildcard or all-skills permissions, missing approval gates, missing evidence obligations, missing failure behavior, unsafe role escalation, API enablement, runtime claims, and R18-006 or later completion claims.
