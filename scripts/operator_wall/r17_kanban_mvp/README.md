# R17 Read-Only Kanban MVP

Open `index.html` directly in a browser to view the local/static R17 Kanban MVP.

This surface is generated from committed R17-005 board state and replay artifacts. It uses only local `html`, `css`, and `js` files, with the generated board snapshot embedded in `kanban.js`.

R17-007 adds a read-only selected-card detail evidence drawer/panel for the R17-005 seed card. The drawer is backed by `state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json` and surfaces evidence refs, memory refs, task packet refs, event history, validation/proof refs, user-decision state, non-claims, rejected claims, and `not_implemented_in_r17_007` placeholders for Dev output, QA result, and audit verdict.

R17-008 adds a read-only board event detail and evidence summary surface for the same R17-005 seed card. The summary is backed by `state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json` and surfaces replay summary, the five-event seed timeline, event-level evidence refs, validation refs, transition decisions, grouped evidence refs, missing/stale evidence summaries, user-decision state, non-claims, rejected claims, and `not_implemented_in_r17_008` placeholders for Dev output, QA result, and audit verdict.

R17-011 adds a bounded operator intake preview panel. The panel shows the seed/raw operator request, generates a governed intake packet preview and a non-executable Orchestrator intake proposal preview in the browser, and labels the surface as `local/static preview only` with `copy/save generated JSON manually until future runtime task`. The panel does not write files, call APIs, persist to localStorage, mutate board state, create cards, or invoke Orchestrator runtime.

R17-012 adds a read-only agent workforce panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json` and shows the planned agent registry, role identity boundaries, allowed/forbidden action summaries, memory/evidence/tool boundaries, and explicit labels for `identity/registry only`, `no runtime agent invocation`, `no A2A runtime`, `no autonomous agents`, and `future adapter use requires later tasks`. The panel does not invoke agents, send A2A messages, call APIs, persist state, mutate board state, or create runtime cards.

R17-013 adds a read-only memory/artifact loader panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_memory_loader_snapshot.json` and shows the bounded exact-ref loader report, loaded-ref log, future-use agent memory packet refs, R16 context budget and guard summary, missing/blocked ref counts, and non-claims. The panel does not implement runtime memory, vector retrieval, live agent runtime, A2A runtime, adapters, API calls, live board mutation, runtime card creation, product runtime, or production runtime.

R17-014 adds a read-only agent invocation log panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_agent_invocation_log_snapshot.json` and shows the repo-backed invocation log contract, seed JSONL log, check report, known R17-012 agent ids, R17-013 memory packet refs, and required false runtime flags including `actual_agent_invoked: false`, `runtime_dispatch_performed: false`, `adapter_call_performed: false`, `external_api_call_performed: false`, `a2a_message_sent: false`, and `product_runtime_executed: false`. The panel shows seed/foundation invocation records only and does not invoke agents, dispatch runtime work, call adapters, call external APIs, send A2A messages, mutate the board live, create runtime cards, implement product runtime, or implement production runtime.

R17-015 adds a read-only tool adapter contract panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_tool_adapter_contract_snapshot.json` and shows the common tool adapter contract, disabled seed adapter profiles for the future Developer/Codex executor, QA/Test Agent, and Evidence Auditor API adapters, and required false runtime flags including `adapter_runtime_implemented: false`, `actual_tool_call_performed: false`, and `external_api_call_performed: false`. The panel does not implement adapter runtime, execute tool calls, call APIs, invoke Codex, invoke QA/Test Agent, invoke Evidence Auditor API, send A2A messages, mutate the board live, or create runtime cards.

R17-016 adds a read-only Developer/Codex executor adapter panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json` and shows the disabled packet-only adapter foundation, request packet, result packet, check report, and required false runtime flags including `codex_executor_invoked: false`, `adapter_runtime_implemented: false`, `actual_tool_call_performed: false`, and `external_api_call_performed: false`. The panel does not invoke Codex, implement adapter runtime, execute tool calls, call APIs, send A2A messages, mutate the board live, create runtime cards, or claim real Dev output.

R17-017 adds a read-only QA/Test Agent adapter panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_qa_test_agent_adapter_snapshot.json` and shows the disabled seed adapter foundation, request packet, result packet, defect packet, check report, and required false runtime flags including `qa_test_agent_invoked: false`, `adapter_runtime_implemented: false`, `actual_tool_call_performed: false`, and `external_api_call_performed: false`. The panel does not invoke QA/Test Agent, implement adapter runtime, execute tests through a live adapter, execute tool calls, call APIs, send A2A messages, mutate the board live, create runtime cards, or claim a real QA result.

R17-018 adds a read-only Evidence Auditor API adapter panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json` and shows the disabled seed adapter foundation, request packet, response placeholder packet, verdict placeholder packet, check report, and required false runtime flags including `adapter_enabled: false`, `evidence_auditor_api_invoked: false`, `external_api_call_performed: false`, `audit_verdict_claimed: false`, `real_audit_verdict: false`, `external_audit_acceptance_claimed: false`, and `runtime_execution_performed: false`. The panel does not invoke Evidence Auditor API, perform external API calls, implement adapter runtime, execute tool calls, send A2A messages, mutate the board live, create runtime cards, claim external audit acceptance, or claim a real audit verdict.

Boundary:
- read-only surface over repo-backed artifacts
- no server
- no package manager
- no network calls
- no browser persistence
- no live board mutation
- no runtime card creation
- no runtime agent execution
- no live agent runtime
- no runtime memory engine
- no vector retrieval runtime
- no live agent invocation
- no Orchestrator runtime
- no A2A runtime
- no A2A messages sent
- no Dev/Codex executor adapter runtime
- no QA/Test Agent adapter runtime
- no Evidence Auditor API runtime
- no adapter runtime
- no Codex invocation
- no external API calls
- no product runtime
- no production runtime
