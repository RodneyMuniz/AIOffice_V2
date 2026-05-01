# Candidate Closeout Tree Reference

The Phase 1 R12 candidate closeout tree SHA is intentionally not asserted inside the same candidate commit that creates this package.

After the Phase 1 candidate commit is created and pushed, Phase 2 must record the candidate commit tree SHA in `final_remote_head_support_packet.json` together with evidence that the remote branch head equals the candidate closeout commit.

This file prevents a same-commit final-head proof claim.
