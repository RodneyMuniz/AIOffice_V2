# Artifact Retrieval Instructions

Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25040949422`

Artifact name: `r10-external-proof-bundle-25040949422-1`

Artifact ID: `6679018430`

Artifact API URL: `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430`

Artifact ZIP URL: `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430/zip`

Download with an authenticated GitHub token:

```powershell
Invoke-WebRequest `
  -Uri "https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430/zip" `
  -Headers @{ Authorization = "Bearer <token>"; Accept = "application/vnd.github+json" } `
  -OutFile "r10-external-proof-bundle-25040949422-1.zip"
```

A downloaded copy from this capture is committed under `downloaded_artifact/`.

The run conclusion is `success`; this artifact is one bounded external runner proof run only, not external QA proof, not final-head clean replay, and not R10 closeout.
