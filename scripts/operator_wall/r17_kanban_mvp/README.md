# R17 Read-Only Kanban MVP

Open `index.html` directly in a browser to view the local/static R17 Kanban MVP.

This surface is generated from committed R17-005 board state and replay artifacts. It uses only local `html`, `css`, and `js` files, with the generated board snapshot embedded in `kanban.js`.

R17-007 adds a read-only selected-card detail evidence drawer/panel for the R17-005 seed card. The drawer is backed by `state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json` and surfaces evidence refs, memory refs, task packet refs, event history, validation/proof refs, user-decision state, non-claims, rejected claims, and `not_implemented_in_r17_007` placeholders for Dev output, QA result, and audit verdict.

R17-008 adds a read-only board event detail and evidence summary surface for the same R17-005 seed card. The summary is backed by `state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json` and surfaces replay summary, the five-event seed timeline, event-level evidence refs, validation refs, transition decisions, grouped evidence refs, missing/stale evidence summaries, user-decision state, non-claims, rejected claims, and `not_implemented_in_r17_008` placeholders for Dev output, QA result, and audit verdict.

R17-011 adds a bounded operator intake preview panel. The panel shows the seed/raw operator request, generates a governed intake packet preview and a non-executable Orchestrator intake proposal preview in the browser, and labels the surface as `local/static preview only` with `copy/save generated JSON manually until future runtime task`. The panel does not write files, call APIs, persist to localStorage, mutate board state, create cards, or invoke Orchestrator runtime.

R17-012 adds a read-only agent workforce panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json` and shows the planned agent registry, role identity boundaries, allowed/forbidden action summaries, memory/evidence/tool boundaries, and explicit labels for `identity/registry only`, `no runtime agent invocation`, `no A2A runtime`, `no autonomous agents`, and `future adapter use requires later tasks`. The panel does not invoke agents, send A2A messages, call APIs, persist state, mutate board state, or create runtime cards.

R17-013 adds a read-only memory/artifact loader panel. The panel is backed by `state/ui/r17_kanban_mvp/r17_memory_loader_snapshot.json` and shows the bounded exact-ref loader report, loaded-ref log, future-use agent memory packet refs, R16 context budget and guard summary, missing/blocked ref counts, and non-claims. The panel does not implement runtime memory, vector retrieval, live agent runtime, A2A runtime, adapters, API calls, live board mutation, runtime card creation, product runtime, or production runtime.

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
- no Orchestrator runtime
- no A2A runtime
- no Dev/Codex executor adapter runtime
- no QA/Test Agent adapter runtime
- no Evidence Auditor API runtime
- no product runtime
