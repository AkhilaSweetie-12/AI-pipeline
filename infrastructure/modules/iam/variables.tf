variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_number" {
  description = "GCP Project Number"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_account_email" {
  description = "AI Platform Service Account email"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}
