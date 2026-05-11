# AIOffice V2 R18 Automated Recovery Runtime and API Orchestration Plan v1

Status: planning recommendation only. R18 is not opened by this document.

## Recommended mission

Build a live automated recovery runtime that reduces manual retry burden after Codex compact failures, validation failures, stream interruptions, and stale context. Add API-level orchestration only after operator-approved secrets, cost, and runaway-loop controls exist.

## Required capabilities

- live local runner/CLI loop;
- automatic failure detection;
- automatic continuation packet creation;
- automatic new-context/new-thread prompt creation;
- execution state machine;
- max token/request budget controls, including a later cap such as 256k tokens per request;
- small work-order execution;
- automated stage/commit/push only after validation gates;
- operator approval gates for risky actions;
- optional API-backed Codex/OpenAI execution only after secrets and cost controls;
- measurable proof that manual retry burden is reduced.

## Acceptance posture

R18 should not be accepted on plans or prompt packets alone. It needs live recovery execution evidence, failed-case drills, cost/secret controls, bounded retry behavior, and proof that manual prompt transfer has been reduced rather than renamed.

## Non-claims

This brief does not open R18, invoke OpenAI APIs, invoke Codex APIs, create a new Codex thread automatically, implement live recovery runtime, merge to main, claim external audit acceptance, close R17, solve compaction, or solve reliability.
