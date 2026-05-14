# Enable IAM API
resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

# Data source for existing Workload Identity Pool
data "google_iam_workload_identity_pool" "github" {
  provider = google-beta
  project  = var.project_id
  workload_identity_pool_id = "github-pool"
}

# Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github" {
  provider           = google-beta
  project            = var.project_id
  workload_identity_pool_id = data.google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider-asia"
  display_name       = "GitHub WI Pool Provider"
  description        = "Workload Identity Pool Provider for GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "attribute.repository == '${var.github_repo}'"
}

# Service Account for GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions CI/CD"
}

# IAM Binding for Workload Identity
resource "google_service_account_iam_binding" "github_actions_workload_identity" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${data.google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
  ]
}

# Grant permissions to GitHub Actions Service Account
resource "google_project_iam_member" "github_actions_permissions" {
  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/container.developer",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudsql.client"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant permissions to AI Platform Service Account
resource "google_project_iam_member" "ai_platform_permissions" {
  for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/iam.serviceAccountUser"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}

# GKE IAM Binding
# GKE IAM Binding
resource "google_project_iam_member" "cluster_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "cluster_admin_github" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:github-actions-sa@akhila-gcp-123-493309.iam.gserviceaccount.com"
}

# External Secrets Operator Service Account
resource "google_service_account" "external_secrets" {
  account_id   = "external-secrets-sa"
  display_name = "External Secrets Operator Service Account"
  description  = "Service account for External Secrets Operator"
}

# IAM Binding for External Secrets Operator
resource "google_project_iam_member" "external_secrets_permissions" {
  for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.viewer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.external_secrets.email}"
}
