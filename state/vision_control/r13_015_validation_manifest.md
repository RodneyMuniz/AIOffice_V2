# R13-015 Vision Control Scoring Validation Manifest

Generated from R13-014 committed repo evidence at head `74135c3937cff33fa86d07e16d495822e1918799` and tree `b363732a430b555ed89d9efe379e3c54676fb2b2`.

## Artifacts

- Contract: `contracts/vision_control/r13_vision_control_scorecard.contract.json`
- Validator module: `tools/R13VisionControlScorecard.psm1`
- Validator wrapper: `tools/validate_r13_vision_control_scorecard.ps1`
- Focused test: `tests/test_r13_vision_control_scorecard.ps1`
- Scorecard: `state/vision_control/r13_015_vision_control_scorecard.json`

## Validation Intent

This manifest supports R13-015 only. It records that Vision Control scoring is now calculable from sub-scores, penalties, segment KPIs, aggregate weights, and committed evidence refs.

The manifest is operator-readable support only. The scorecard JSON and validator are the machine-readable evidence surfaces.

## Checks

- The R12/R13 planning report is treated as scoring methodology and prior context only, not product proof.
- Generated Markdown is treated as operator-readable artifact only, not proof by itself.
- Item scores recompute from six sub-scores and approved penalty values.
- Segment KPIs recompute from item scores.
- Weighted aggregate recomputes from Product `30%`, Workflow `30%`, Architecture `25%`, and Governance / Proof `15%`.
- R12 prior reported aggregate `48.2` is preserved as prior report context, while the item-row recomputed R12 aggregate is `46.2`.
- R13-015 aggregate is `51.9`, with uplift `3.7` from the prior reported R12 aggregate and `5.7` from the recomputed R12 item-row aggregate.
- R13-015 does not claim 10 to 15 percent progress under either baseline.
- Positive item uplift requires committed implemented-code, machine-evidence, or external-replay evidence refs.
- R13 remains open after R13-015, R13-016 through R13-018 remain planned only, and no R14 or successor milestone is open.

## Validation Command

`powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_vision_control_scorecard.ps1`

## Non-Claims

- no R13 closeout
- no R14 or successor opening
- no production runtime
- no production QA
- no full product QA coverage
- no productized UI
- no productized control-room behavior
- no broad autonomy
- no solved Codex reliability
- no solved Codex context compaction
- no 10 to 15 percent progress claim from R13-015 scorecard
