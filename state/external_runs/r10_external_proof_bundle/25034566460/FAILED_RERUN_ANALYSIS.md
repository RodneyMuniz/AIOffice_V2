# R10-005B Failed Rerun Analysis

Run `25034566460` was a real GitHub Actions run for `R10 External Proof Bundle` on branch `release/r10-real-external-runner-proof-foundation`.

Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25034566460`

Artifact: `r10-external-proof-bundle-25034566460-1`

Artifact API URL: `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6676514702`

Artifact ZIP URL: `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6676514702/zip`

The run completed with conclusion `failure`, but it did upload a retrievable artifact and the artifact was downloaded into this evidence folder.

The downloaded `external_proof_artifact_bundle.json` records:
- remote head SHA `0973f1159431fc6bfd0163c3975aaa91bd7ea127`
- tested head SHA `0973f1159431fc6bfd0163c3975aaa91bd7ea127`
- tested tree SHA `74afeb0730779ae32679c7f31a18ec04c89e14d9`
- `head_match: true`
- aggregate verdict `failed`
- refusal reasons for `external-proof-artifact-bundle` and `external-runner-closeout-identity`

Local validation of the downloaded bundle accepted it as a completed non-passing bundle shape. The external runner command logs show the Linux/pwsh proof tests still failed before accepting their valid fixtures:
- `downloaded_artifact/artifacts/external-proof-artifact-bundle.stdout.log`: `FAIL external proof artifact bundle harness: External proof artifact bundle is missing required field 'contract_version'.`
- `downloaded_artifact/artifacts/external-runner-closeout-identity.stdout.log`: `FAIL external runner closeout identity harness: External runner closeout identity contract_version must be a non-empty string.`
- `downloaded_artifact/artifacts/bundle_validation.stderr.log`: `External proof artifact bundle is missing required field 'contract_version'.`

This is new diagnostic value after R10-005A: the runner now reaches artifact creation and upload with exact head evidence, but the Linux/pwsh proof-test fixture path still fails inside the external runner.

This run is not successful external proof. It does not implement R10-006, does not provide external QA proof, does not provide final-head clean replay, does not close R10, and does not prove broad CI/product coverage.
