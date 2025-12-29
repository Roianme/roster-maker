param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,
    [Parameter(Mandatory = $true)]
    [string]$ServiceName,
    [Parameter(Mandatory = $true)]
    [string]$Region,
    [switch]$AllowUnauthenticated
)

Set-Location "$PSScriptRoot/.."
gcloud config set project $ProjectId
gcloud builds submit --tag "gcr.io/$ProjectId/$ServiceName" optimizer_service
$deployArgs = @(
  "run", "deploy", $ServiceName,
  "--image", "gcr.io/$ProjectId/$ServiceName",
  "--region", $Region,
  "--platform", "managed"
)
if ($AllowUnauthenticated) {
  $deployArgs += "--allow-unauthenticated"
}
gcloud @deployArgs
