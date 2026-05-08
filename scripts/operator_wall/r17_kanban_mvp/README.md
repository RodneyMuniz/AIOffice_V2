# R17 Read-Only Kanban MVP

Open `index.html` directly in a browser to view the local/static R17 Kanban MVP.

This surface is generated from committed R17-005 board state and replay artifacts. It uses only local `html`, `css`, and `js` files, with the generated board snapshot embedded in `kanban.js`.

R17-007 adds a read-only selected-card detail evidence drawer/panel for the R17-005 seed card. The drawer is backed by `state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json` and surfaces evidence refs, memory refs, task packet refs, event history, validation/proof refs, user-decision state, non-claims, rejected claims, and `not_implemented_in_r17_007` placeholders for Dev output, QA result, and audit verdict.

R17-008 adds a read-only board event detail and evidence summary surface for the same R17-005 seed card. The summary is backed by `state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json` and surfaces replay summary, the five-event seed timeline, event-level evidence refs, validation refs, transition decisions, grouped evidence refs, missing/stale evidence summaries, user-decision state, non-claims, rejected claims, and `not_implemented_in_r17_008` placeholders for Dev output, QA result, and audit verdict.

R17-011 adds a bounded operator intake preview panel. The panel shows the seed/raw operator request, generates a governed intake packet preview and a non-executable Orchestrator intake proposal preview in the browser, and labels the surface as `local/static preview only` with `copy/save generated JSON manually until future runtime task`. The panel does not write files, call APIs, persist to localStorage, mutate board state, create cards, or invoke Orchestrator runtime.

Boundary:
- read-only surface over repo-backed artifacts
- no server
- no package manager
- no network calls
- no browser persistence
- no live board mutation
- no runtime card creation
- no runtime agent execution
- no Orchestrator runtime
- no A2A runtime
- no Dev/Codex executor adapter runtime
- no QA/Test Agent adapter runtime
- no Evidence Auditor API runtime
- no product runtime
