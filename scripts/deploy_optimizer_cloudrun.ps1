param(
    [string]$ProjectId = "your-gcp-project",
    [string]$ServiceName = "roster-optimizer",
    [string]$Region = "australia-southeast1"
)

Set-Location "$PSScriptRoot/.."
gcloud config set project $ProjectId
gcloud builds submit --tag "gcr.io/$ProjectId/$ServiceName" optimizer_service
gcloud run deploy $ServiceName `
  --image "gcr.io/$ProjectId/$ServiceName" `
  --region $Region `
  --platform managed `
  --allow-unauthenticated
