# R18-006 Validation Manifest

Required validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_orchestrator_control_intake.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_orchestrator_control_intake.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_orchestrator_control_intake.ps1
- Prior R18 validators and status-doc gate remain required by the release worker prompt.

Expected posture:

- R18 active through R18-006 only.
- R18-007 through R18-028 planned only.
- Intake artifacts are contract and seed packets only.
- Runtime/API/live-routing flags remain false.
