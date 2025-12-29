param(
    [string]$Python = "python",
    [switch]$SkipInstall
)

Set-Location "$PSScriptRoot/../optimizer_service"
if (-not (Test-Path ".venv")) {
    & $Python -m venv .venv
}
if (-not $SkipInstall) {
    & ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt
}
& ".\.venv\Scripts\python.exe" -m uvicorn main:app --reload --port 8000
