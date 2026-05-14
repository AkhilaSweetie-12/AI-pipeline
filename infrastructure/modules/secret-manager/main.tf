# Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# Create Secrets
resource "google_secret_manager_secret" "secrets" {
  for_each = toset(["jwt-secret", "jwt-refresh-secret", "database-password", "openai-api-key", "playwright-test-password", "playwright-admin-password", "grafana-admin-password", "internal-api-key", "encryption-key", "session-secret"])

  project   = var.project_id
  secret_id = "${var.environment}-${each.value}"

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
    }
  }

  labels = {
    environment = var.environment
    project     = "ai-platform"
  }

  depends_on = [google_project_service.secretmanager]
}

# Create Secret Versions
resource "google_secret_manager_secret_version" "secret_versions" {
  for_each = toset(["jwt-secret", "jwt-refresh-secret", "database-password", "openai-api-key", "playwright-test-password", "playwright-admin-password", "grafana-admin-password", "internal-api-key", "encryption-key", "session-secret"])

  secret      = google_secret_manager_secret.secrets[each.value].id
  secret_data = var.secrets[each.value]

  # Secret versions are automatically handled as sensitive by Terraform
}

# IAM Policy for Service Account Access
resource "google_secret_manager_secret_iam_member" "service_account_access" {
  for_each = toset(["jwt-secret", "jwt-refresh-secret", "database-password", "openai-api-key", "playwright-test-password", "playwright-admin-password", "grafana-admin-password", "internal-api-key", "encryption-key", "session-secret"])

  project   = google_secret_manager_secret.secrets[each.value].project
  secret_id = google_secret_manager_secret.secrets[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}

# IAM Policy for External Secrets Operator
resource "google_secret_manager_secret_iam_member" "external_secrets_access" {
  for_each = toset(["jwt-secret", "jwt-refresh-secret", "database-password", "openai-api-key", "playwright-test-password", "playwright-admin-password", "grafana-admin-password", "internal-api-key", "encryption-key", "session-secret"])

  project   = google_secret_manager_secret.secrets[each.value].project
  secret_id = google_secret_manager_secret.secrets[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}
