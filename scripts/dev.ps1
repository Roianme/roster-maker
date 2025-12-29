Write-Host "Starting optimizer (port 8000) and Flutter web (Chrome)." -ForegroundColor Cyan
Start-Process -NoNewWindow powershell -ArgumentList "-NoExit", "-Command", ". '$PSScriptRoot/run_optimizer_local.ps1'"
Set-Location "$PSScriptRoot/../admin_app"
flutter config --enable-web | Out-Null
flutter run -d chrome
