# Data sources
data "google_client_config" "default" {}

# Enable required Google APIs
resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# Random resources for secure secret generation
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "random_password" "jwt_refresh_secret" {
  length  = 64
  special = true
}

resource "random_password" "database_password" {
  length  = 32
  special = true
}

resource "random_password" "playwright_test_password" {
  length  = 16
  special = true
}

resource "random_password" "playwright_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "grafana_admin_password" {
  length  = 32
  special = true
}

resource "random_password" "internal_api_key" {
  length  = 64
  special = true
}

resource "random_password" "encryption_key" {
  length  = 64
  special = true
}

resource "random_password" "session_secret" {
  length  = 64
  special = true
}

# Service Account
resource "google_service_account" "ai_platform" {
  account_id   = "ai-application"
  display_name = "AI Platform Service Account"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "container.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com"
    # "sourcerepo.googleapis.com"  # Removed due to permission issues
  ])

  project    = var.project_id
  service    = each.value

  disable_on_destroy = false
}

# VPC Module Call
module "vpc" {
  source = "../modules/vpc"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  vpc_name      = var.vpc_name
}

# GKE Module Call - Now enabled in asia-south1
module "gke" {
  source = "../modules/gke"

  project_id         = var.project_id
  region             = var.region
  zone               = var.zone
  environment        = var.environment
  cluster_name       = var.cluster_name
  network_name       = module.vpc.network_name
  subnet_name        = module.vpc.subnet_name
  network_self_link  = module.vpc.network_self_link
  subnet_self_link   = module.vpc.subnet_self_link
  service_account    = google_service_account.ai_platform.email
}

# Cloud SQL Module Call
module "cloudsql" {
  source = "../modules/cloudsql"

  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  instance_name      = var.database_instance_name
  database_name      = var.database_name
  database_version   = var.database_version
  database_tier      = var.database_tier
  network_name       = module.vpc.network_name
  network_self_link  = module.vpc.network_self_link
  database_password  = random_password.database_password.result
}

# Secret Manager Module Call
module "secret_manager" {
  source = "../modules/secret-manager"

  project_id            = var.project_id
  environment           = var.environment
  service_account_email = google_service_account.ai_platform.email
  secrets               = merge(var.secrets, {
    "openai-api-key" = var.openai_api_key
  })

  depends_on = [google_project_service.secretmanager]
}

# IAM Module Call
module "iam" {
  source = "../modules/iam"

  project_id              = var.project_id
  project_number          = var.project_number
  environment             = var.environment
  service_account_email   = google_service_account.ai_platform.email
  github_repo             = var.github_repo
  cluster_name            = var.cluster_name
  region                  = var.region
}

# Artifact Registry
resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = "ai-platform"
  description   = "AI Platform Docker Repository"
  format        = "DOCKER"

  labels = {
    environment = var.environment
    project     = "ai-platform"
  }
}

# Kubernetes resources will be deployed manually using kubectl/helm
# This avoids provider configuration issues
# 
# To deploy External Secrets Operator manually:
# 1. Install gke-gcloud-auth-plugin
# 2. Get cluster credentials: gcloud container clusters get-credentials ai-platform-cluster --project=akhila-gcp-123-493309 --region=asia-south1
# 3. Create namespace: kubectl create namespace external-secrets
# 4. Install operator: helm repo add external-secrets https://charts.external-secrets.io && helm install external-secrets external-secrets/external-secrets --namespace external-secrets
