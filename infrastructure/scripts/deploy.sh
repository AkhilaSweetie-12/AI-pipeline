#!/bin/bash

# AI Platform Deployment Script
set -e

PROJECT_ID="akhila-gcp-123-493309"
REGION="asia-south1"
ZONE="asia-south1-a"
CLUSTER_NAME="ai-platform-cluster"

echo "🚀 Starting AI Platform Deployment..."

# Step 1: Deploy Infrastructure
echo "📦 Deploying Terraform infrastructure..."
cd infrastructure/terraform
terraform init
terraform plan
terraform apply -auto-approve

# Step 2: Configure kubectl
echo "🔧 Configuring kubectl..."
gcloud container clusters get-credentials $CLUSTER_NAME --project=$PROJECT_ID --region=$REGION

# Step 3: Create namespace
echo "📋 Creating external-secrets namespace..."
kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Add Helm repo
echo "📚 Adding External Secrets Helm repository..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Step 5: Install External Secrets Operator
echo "🔐 Installing External Secrets Operator..."
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --set installCRDs=true \
  --wait

# Step 6: Deploy SecretStore
echo "🔑 Deploying SecretStore..."
kubectl apply -f ../kubernetes/secretstore.yaml

# Step 7: Deploy ExternalSecrets
echo "🔄 Deploying ExternalSecrets..."
kubectl apply -f ../kubernetes/externalsecrets.yaml

# Step 8: Verify deployment
echo "✅ Verifying deployment..."
kubectl get nodes
kubectl get pods -n external-secrets
kubectl get secrets -n external-secrets

echo "🎉 AI Platform deployment completed successfully!"
echo "🔗 Cluster: $CLUSTER_NAME"
echo "🌐 Region: $REGION"
echo "📊 Dashboard: https://console.cloud.google.com/kubernetes/workload_/gcloud/$REGION/$CLUSTER_NAME?project=$PROJECT_ID"
