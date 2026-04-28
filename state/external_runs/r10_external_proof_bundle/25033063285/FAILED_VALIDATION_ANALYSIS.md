# R10-005A Failed Validation Analysis

Run `25033063285` was a real GitHub Actions run:

- Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25033063285`
- Artifact: `r10-external-proof-bundle-25033063285-1`
- Artifact ID: `6675983991`
- Conclusion: `failure`

The run checked out `release/r10-real-external-runner-proof-foundation`, uploaded the artifact, and the artifact was downloaded into this evidence folder.

The proof command failed on the external runner. The captured stdout records:

`External proof artifact bundle contract_version must be a non-empty string.`

The parent runner step also stopped while converting local output paths into relative artifact refs on Linux because the prior relative-ref helper treated Linux local paths as bare URIs.

R10-005A is a corrective support slice only. It fixes Linux/pwsh validation and artifact-ref handling for a future external proof run.

Run `25033063285` is not successful external proof. This note does not claim external QA proof, final-head clean replay, R10 closeout, broad CI/product coverage, or broad autonomous milestone execution.
