# Artifact Retrieval Instructions

Run URL: `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25034566460`

Artifact name: `r10-external-proof-bundle-25034566460-1`

Artifact ID: `6676514702`

Artifact API URL: `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6676514702`

Artifact ZIP URL: `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6676514702/zip`

Download with an authenticated GitHub token:

```powershell
Invoke-WebRequest `
  -Uri "https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6676514702/zip" `
  -Headers @{ Authorization = "Bearer <token>"; Accept = "application/vnd.github+json" } `
  -OutFile "r10-external-proof-bundle-25034566460-1.zip"
```

A downloaded copy from this capture is committed under `downloaded_artifact/`.

The run conclusion is `failure`; this artifact is real external runner failure evidence, not successful R10 closeout proof.
