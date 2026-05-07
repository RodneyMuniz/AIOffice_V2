"use strict";

window.R17_KANBAN_SNAPSHOT = {
    "artifact_type":  "r17_kanban_mvp_snapshot",
    "contract_version":  "v1",
    "source_task":  "R17-006",
    "milestone":  "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle",
    "branch":  "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
    "active_through_task":  "R17-006",
    "generated_from_head":  "0d72b6b6338a35582f19a861f7ef88776d2064fc",
    "generated_from_tree":  "074de6e3dd8566a258796d14c3a68532faca26a4",
    "ui_boundary_label":  "Read-only Kanban MVP, not runtime",
    "local_open_path":  "scripts/operator_wall/r17_kanban_mvp/index.html",
    "source_artifacts":  {
                             "board_state":  "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
                             "seed_card":  "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json",
                             "seed_event_log":  "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl",
                             "replay_report":  "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json",
                             "r17_004_proof_review_package":  "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/",
                             "r17_005_proof_review_package":  "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/"
                         },
    "canonical_truth":  {
                            "repo_truth_is_canonical":  true,
                            "read_only_static_ui_only":  true,
                            "live_board_mutation_implemented":  false,
                            "product_runtime_implemented":  false,
                            "production_runtime_implemented":  false,
                            "kanban_product_runtime_implemented":  false,
                            "orchestrator_runtime_implemented":  false,
                            "a2a_runtime_implemented":  false,
                            "autonomous_agents_implemented":  false,
                            "dev_codex_executor_adapter_runtime_implemented":  false,
                            "qa_test_agent_adapter_runtime_implemented":  false,
                            "evidence_auditor_api_runtime_implemented":  false,
                            "executable_handoffs_implemented":  false,
                            "executable_transitions_implemented":  false,
                            "external_integrations_implemented":  false
                        },
    "lane_order":  [
                       "intake",
                       "define",
                       "ready_for_dev",
                       "in_dev",
                       "ready_for_qa",
                       "in_qa",
                       "fix_required",
                       "ready_for_audit",
                       "in_audit",
                       "ready_for_user_review",
                       "resolved",
                       "closed",
                       "blocked"
                   ],
    "lanes":  [
                  {
                      "id":  "intake",
                      "title":  "Intake",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "define",
                      "title":  "Define",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "ready_for_dev",
                      "title":  "Ready For Dev",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "in_dev",
                      "title":  "In Dev",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "ready_for_qa",
                      "title":  "Ready For Qa",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "in_qa",
                      "title":  "In Qa",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "fix_required",
                      "title":  "Fix Required",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "ready_for_audit",
                      "title":  "Ready For Audit",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "in_audit",
                      "title":  "In Audit",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "ready_for_user_review",
                      "title":  "Ready For User Review",
                      "card_count":  1,
                      "cards":  [
                                    "R17-005"
                                ]
                  },
                  {
                      "id":  "resolved",
                      "title":  "Resolved",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "closed",
                      "title":  "Closed",
                      "card_count":  0,
                      "cards":  [

                                ]
                  },
                  {
                      "id":  "blocked",
                      "title":  "Blocked",
                      "card_count":  0,
                      "cards":  [

                                ]
                  }
              ],
    "cards":  [
                  {
                      "card_id":  "R17-005",
                      "task_id":  "R17-005",
                      "title":  "Implement bounded repo-backed board state store and deterministic replay checks",
                      "current_lane":  "ready_for_user_review",
                      "owner_role":  "operator",
                      "current_agent":  "codex_local_repository_worker",
                      "status":  "ready_for_user_review",
                      "user_decision_required":  true,
                      "user_approval_required_for_closure":  true,
                      "evidence_ref_count":  12,
                      "memory_ref_count":  4,
                      "blocker_count":  0,
                      "evidence_refs":  [
                                            "contracts/board/r17_card.contract.json",
                                            "contracts/board/r17_board_state.contract.json",
                                            "contracts/board/r17_board_event.contract.json",
                                            "tools/R17BoardContracts.psm1",
                                            "tools/R17BoardStateStore.psm1",
                                            "tools/new_r17_board_state_store.ps1",
                                            "tools/validate_r17_board_state_store.ps1",
                                            "tests/test_r17_board_contracts.ps1",
                                            "tests/test_r17_board_state_store.ps1",
                                            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/proof_review.md",
                                            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/evidence_index.json",
                                            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/validation_manifest.md"
                                        ],
                      "memory_refs":  [
                                          "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
                                          "contracts/board/r17_card.contract.json",
                                          "contracts/board/r17_board_state.contract.json",
                                          "contracts/board/r17_board_event.contract.json"
                                      ],
                      "blocker_refs":  [

                                       ]
                  }
              ],
    "replay_summary":  {
                           "aggregate_verdict":  "generated_r17_board_state_store_candidate",
                           "input_card_count":  1,
                           "input_event_count":  5,
                           "replayed_event_count":  5,
                           "rejected_event_count":  0,
                           "final_lane_by_card":  {
                                                      "R17-005":  "ready_for_user_review"
                                                  },
                           "user_decisions_required":  [
                                                           {
                                                               "card_id":  "R17-005",
                                                               "task_id":  "R17-005",
                                                               "decision":  "user approval required before closure",
                                                               "requested_by_event_id":  "r17_005_event_004_ready_for_user_review"
                                                           }
                                                       ],
                           "unresolved_blockers":  [

                                                   ]
                       },
    "non_claims":  [
                       "no Kanban product runtime",
                       "no Orchestrator runtime",
                       "no A2A runtime",
                       "no autonomous agents",
                       "no Dev/Codex adapter runtime",
                       "no QA/Test Agent adapter runtime",
                       "no Evidence Auditor API runtime",
                       "no executable handoffs",
                       "no executable transitions",
                       "no external audit acceptance",
                       "no main merge",
                       "no product runtime"
                   ],
    "evidence_refs":  [
                          "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
                          "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json",
                          "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl",
                          "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json",
                          "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/",
                          "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/"
                      ]
};

(function () {
  const snapshot = window.R17_KANBAN_SNAPSHOT;

  function text(value) {
    if (value === true) return "yes";
    if (value === false) return "no";
    if (value === null || value === undefined || value === "") return "none";
    return String(value);
  }

  function pretty(value) {
    return text(value).replace(/_/g, " ");
  }

  function byId(id) {
    return document.getElementById(id);
  }

  function create(tag, className, content) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (content !== undefined) node.textContent = content;
    return node;
  }

  function addMetric(parent, label, value) {
    const item = create("div", "metric");
    item.append(create("span", "metric-label", label));
    item.append(create("strong", "", text(value)));
    parent.append(item);
  }

  function renderHeader() {
    byId("milestone").textContent = snapshot.milestone;
    byId("boundary-label").textContent = snapshot.ui_boundary_label;
    const meta = byId("meta-grid");
    meta.innerHTML = "";
    addMetric(meta, "Branch", snapshot.branch);
    addMetric(meta, "Active through", snapshot.active_through_task);
    addMetric(meta, "Generated from head", snapshot.generated_from_head);
    addMetric(meta, "Generated from tree", snapshot.generated_from_tree);
  }

  function cardById(cardId) {
    return snapshot.cards.find((card) => card.card_id === cardId);
  }

  function renderCard(card) {
    const article = create("article", "kanban-card");
    const title = create("div", "card-title");
    title.append(create("span", "card-id", card.card_id));
    title.append(create("strong", "", card.title));
    article.append(title);

    const fields = [
      ["Task", card.task_id],
      ["Lane", pretty(card.current_lane)],
      ["Owner", pretty(card.owner_role)],
      ["Agent", pretty(card.current_agent)],
      ["Status", pretty(card.status)],
      ["User decision", card.user_decision_required],
      ["Closure approval", card.user_approval_required_for_closure],
      ["Evidence refs", card.evidence_ref_count],
      ["Memory refs", card.memory_ref_count],
      ["Blockers", card.blocker_count]
    ];

    const dl = create("dl", "card-fields");
    fields.forEach(([label, value]) => {
      dl.append(create("dt", "", label));
      dl.append(create("dd", "", text(value)));
    });
    article.append(dl);
    return article;
  }

  function renderBoard() {
    const board = byId("lane-board");
    board.innerHTML = "";

    snapshot.lanes.forEach((lane) => {
      const section = create("section", "lane");
      const header = create("header", "lane-header");
      header.append(create("h2", "", lane.title));
      header.append(create("span", "lane-count", lane.card_count));
      section.append(header);

      const cards = create("div", "lane-cards");
      if (lane.cards.length === 0) {
        cards.append(create("p", "empty-lane", "No cards"));
      } else {
        lane.cards.forEach((cardId) => cards.append(renderCard(cardById(cardId))));
      }
      section.append(cards);
      board.append(section);
    });
  }

  function renderReplay() {
    const replay = byId("replay-summary");
    replay.innerHTML = "";
    const summary = snapshot.replay_summary;
    const metrics = create("div", "summary-grid");
    addMetric(metrics, "Aggregate verdict", summary.aggregate_verdict);
    addMetric(metrics, "Input cards", summary.input_card_count);
    addMetric(metrics, "Input events", summary.input_event_count);
    addMetric(metrics, "Replayed events", summary.replayed_event_count);
    addMetric(metrics, "Rejected events", summary.rejected_event_count);
    addMetric(metrics, "User decisions", summary.user_decisions_required.length);
    addMetric(metrics, "Unresolved blockers", summary.unresolved_blockers.length);
    replay.append(metrics);

    const finalLaneList = create("ul", "plain-list");
    Object.entries(summary.final_lane_by_card).forEach(([cardId, lane]) => {
      finalLaneList.append(create("li", "", cardId + " -> " + pretty(lane)));
    });
    replay.append(create("h3", "", "Final lane by card"));
    replay.append(finalLaneList);

    const decisionList = create("ul", "plain-list");
    summary.user_decisions_required.forEach((decision) => {
      decisionList.append(create("li", "", decision.card_id + ": " + decision.decision));
    });
    if (summary.user_decisions_required.length === 0) decisionList.append(create("li", "", "none"));
    replay.append(create("h3", "", "User decisions required"));
    replay.append(decisionList);
  }

  function renderList(id, values) {
    const list = byId(id);
    list.innerHTML = "";
    values.forEach((value) => list.append(create("li", "", value)));
  }

  function renderEvidence() {
    const values = Object.entries(snapshot.source_artifacts).map(([label, path]) => {
      return pretty(label) + ": " + path;
    });
    renderList("evidence-refs", values);
  }

  renderHeader();
  renderBoard();
  renderReplay();
  renderList("non-claims", snapshot.non_claims);
  renderEvidence();
})();
