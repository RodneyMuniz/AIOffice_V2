# Candidate Closeout Head Reference

The Phase 1 R12 candidate closeout commit SHA is intentionally not asserted inside the same candidate commit that creates this package.

After the Phase 1 candidate commit is created and pushed to `origin/release/r12-external-api-runner-actionable-qa-control-room-pilot`, Phase 2 must verify that the remote branch head equals that candidate commit SHA and record the exact SHA in `final_remote_head_support_packet.json`.

This file prevents a self-referential final-head proof claim.
