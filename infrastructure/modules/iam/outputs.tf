output "github_actions_service_account_email" {
  description = "GitHub Actions Service Account email"
  value       = google_service_account.github_actions.email
}

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = data.google_iam_workload_identity_pool.github.workload_identity_pool_id
}

output "workload_identity_provider_id" {
  description = "Workload Identity Pool Provider ID"
  value       = google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id
}

output "external_secrets_service_account_email" {
  description = "External Secrets Operator Service Account email"
  value       = google_service_account.external_secrets.email
}
