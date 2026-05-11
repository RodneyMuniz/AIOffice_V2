# R18-002 Agent Card Schema Proof Review

Status: R18-002 creates the agent card contract, seven seed cards, validator, invalid fixtures, check report, operator-surface snapshot state artifact, and this proof-review package only.

Evidence reviewed:

- contracts/agents/r18_agent_card.contract.json
- state/agents/r18_agent_cards/
- state/agents/r18_agent_card_check_report.json
- state/ui/r18_operator_surface/r18_agent_card_snapshot.json
- 	ools/R18AgentCardSchema.psm1
- 	ools/new_r18_agent_card_schema.ps1
- 	ools/validate_r18_agent_card_schema.ps1
- 	ests/test_r18_agent_card_schema.ps1
- 	ests/fixtures/r18_agent_card_schema/

Boundary:

- Agent cards are governance/runtime contracts only, not live agents.
- Allowed skills are planned identifiers only; no skill contracts or executable skills are implemented.
- No live A2A runtime, live recovery runtime, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, automatic new-thread creation, product runtime, main merge, solved Codex compaction, solved Codex reliability, or no-manual-prompt-transfer success is claimed.
- R18 remains active through R18-002 only; R18-003 through R18-028 remain planned only.
