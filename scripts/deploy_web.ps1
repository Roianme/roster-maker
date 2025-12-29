param(
    [string]$FirebaseProject = "your-project-id"
)

Set-Location "$PSScriptRoot/../admin_app"
flutter config --enable-web | Out-Null
flutter build web --release
Set-Location "$PSScriptRoot/.."
firebase deploy --project $FirebaseProject --only hosting
