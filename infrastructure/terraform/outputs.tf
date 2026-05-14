output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "cluster_name" {
  description = "GKE Cluster name"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE Cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "database_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = module.cloudsql.instance_connection_name
}

output "database_ip" {
  description = "Cloud SQL instance IP"
  value       = module.cloudsql.public_ip_address
  sensitive   = true
}

output "vpc_name" {
  description = "VPC name"
  value       = module.vpc.network_name
}

output "vpc_self_link" {
  description = "VPC self link"
  value       = module.vpc.network_self_link
}

# output "artifact_registry_repository" {
#   description = "Artifact Registry repository URL"
#   value       = google_artifact_registry.repository.name
# }

output "service_account_email" {
  description = "Service account email"
  value       = google_service_account.ai_platform.email
}

output "workload_identity_pool_provider" {
  description = "Workload Identity Pool Provider"
  value       = module.iam.workload_identity_provider_id
}

# External Secrets Operator will be deployed manually
# output "external_secrets_operator_namespace" {
#   description = "External Secrets Operator namespace"
#   value       = "external-secrets"
# }
