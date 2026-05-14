# AI Platform Infrastructure

## Overview
Complete GCP infrastructure for AI application deployment using Terraform and Kubernetes.

## Architecture
- **Region**: asia-south1
- **Zone**: asia-south1-a
- **GKE Cluster**: ai-platform-cluster
- **Database**: CloudSQL PostgreSQL
- **Secrets**: Google Secret Manager + External Secrets Operator
- **Registry**: Artifact Registry

## Prerequisites
- gcloud CLI installed
- kubectl installed
- helm installed
- Appropriate GCP permissions

## Deployment Steps

### 1. Infrastructure Deployment
```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### 2. Kubernetes Setup
```bash
# Get cluster credentials
gcloud container clusters get-credentials ai-platform-cluster --project=akhila-gcp-123-493309 --region=asia-south1

# Create namespace
kubectl create namespace external-secrets

# Add Helm repo
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install External Secrets Operator
helm install external-secrets external-secrets/external-secrets --namespace external-secrets --set installCRDs=true
```

### 3. Configure Secret Synchronization
```bash
# Apply SecretStore
kubectl apply -f ../kubernetes/secretstore.yaml

# Apply ExternalSecrets
kubectl apply -f ../kubernetes/externalsecrets.yaml

# Verify secrets
kubectl get secrets -n external-secrets
```

## Variables
- `project_id`: GCP Project ID
- `region`: Deployment region (asia-south1)
- `zone`: Deployment zone (asia-south1-a)
- `environment`: Environment (dev/qa/staging/prod)
- `openai_api_key`: OpenAI API key (stored in terraform.tfvars)

## Modules
- **vpc**: Virtual Private Cloud
- **gke**: Google Kubernetes Engine
- **cloudsql**: Cloud SQL Database
- **secret-manager**: Secret Manager
- **iam**: Identity and Access Management

## Outputs
- `cluster_name`: GKE Cluster name
- `cluster_endpoint`: GKE Cluster endpoint
- `database_instance_connection_name`: Cloud SQL connection string
- `service_account_email`: Service account email
- `workload_identity_pool_provider`: Workload Identity provider

## Security
- All secrets stored in Google Secret Manager
- Service accounts with least privilege
- Workload Identity for GKE authentication
- Network firewall rules

## Monitoring
- GKE monitoring enabled
- Cloud SQL monitoring enabled
- Secret Manager access logging

## Troubleshooting
1. If kubectl fails to connect, ensure gke-gcloud-auth-plugin is installed
2. If External Secrets Operator fails, check Workload Identity configuration
3. If database connection fails, verify network connectivity

## Cleanup
```bash
cd infrastructure/terraform
terraform destroy
```
