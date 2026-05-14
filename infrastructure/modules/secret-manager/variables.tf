variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secrets" {
  description = "Map of secret names to values"
  type        = map(string)
  sensitive   = true
}

variable "service_account_email" {
  description = "Service account email for secret access"
  type        = string
}

variable "external_secrets_service_account" {
  description = "External Secrets Operator service account"
  type        = string
  default     = ""
}
