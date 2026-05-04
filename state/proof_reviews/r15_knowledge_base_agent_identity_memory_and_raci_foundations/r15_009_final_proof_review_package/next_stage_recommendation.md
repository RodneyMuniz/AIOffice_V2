# R15-009 Next-Stage Recommendation

This is a recommendation only. It does not open R16 or any successor milestone.

Recommended next-stage focus:

- Convert the R15 model-only foundations into a thin operator-facing board/control workflow prototype.
- Prefer an API-first execution path so evidence capture and state changes are inspectable before UI polish.
- Use card re-entry packets for bounded role handoff, restart, and compaction recovery controls.
- Capture externally verifiable evidence for any claimed execution path.
- Treat compaction/restart mitigation as operational controls, not solved Codex reliability.
- Avoid another governance-only loop unless it is tied to executable product behavior and measurable operator value.

The next stage should remain product-directed and evidence-bound: a minimal workflow that lets an operator see cards, role boundaries, handoff packets, validation state, and review evidence without claiming autonomous multi-agent runtime or external integrations before they exist.
