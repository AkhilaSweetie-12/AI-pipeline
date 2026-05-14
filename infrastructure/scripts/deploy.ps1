# AI Platform Deployment Script (PowerShell)
$ErrorActionPreference = "Stop"

$PROJECT_ID = "akhila-gcp-123-493309"
$REGION = "asia-south1"
$ZONE = "asia-south1-a"
$CLUSTER_NAME = "ai-platform-cluster"

Write-Host "🚀 Starting AI Platform Deployment..." -ForegroundColor Green

# Step 1: Deploy Infrastructure
Write-Host "📦 Deploying Terraform infrastructure..." -ForegroundColor Blue
Set-Location "infrastructure/terraform"
terraform init
terraform plan
terraform apply -auto-approve

# Step 2: Configure kubectl
Write-Host "🔧 Configuring kubectl..." -ForegroundColor Blue
gcloud container clusters get-credentials $CLUSTER_NAME --project=$PROJECT_ID --region=$REGION

# Step 3: Create namespace
Write-Host "📋 Creating external-secrets namespace..." -ForegroundColor Blue
kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Add Helm repo
Write-Host "📚 Adding External Secrets Helm repository..." -ForegroundColor Blue
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Step 5: Install External Secrets Operator
Write-Host "🔐 Installing External Secrets Operator..." -ForegroundColor Blue
helm upgrade --install external-secrets external-secrets/external-secrets `
  --namespace external-secrets `
  --set installCRDs=true `
  --wait

# Step 6: Deploy SecretStore
Write-Host "🔑 Deploying SecretStore..." -ForegroundColor Blue
kubectl apply -f ../kubernetes/secretstore.yaml

# Step 7: Deploy ExternalSecrets
Write-Host "🔄 Deploying ExternalSecrets..." -ForegroundColor Blue
kubectl apply -f ../kubernetes/externalsecrets.yaml

# Step 8: Verify deployment
Write-Host "✅ Verifying deployment..." -ForegroundColor Blue
kubectl get nodes
kubectl get pods -n external-secrets
kubectl get secrets -n external-secrets

Write-Host "🎉 AI Platform deployment completed successfully!" -ForegroundColor Green
Write-Host "🔗 Cluster: $CLUSTER_NAME" -ForegroundColor Cyan
Write-Host "🌐 Region: $REGION" -ForegroundColor Cyan
Write-Host "📊 Dashboard: https://console.cloud.google.com/kubernetes/workload_/gcloud/$REGION/$CLUSTER_NAME?project=$PROJECT_ID" -ForegroundColor Cyan
