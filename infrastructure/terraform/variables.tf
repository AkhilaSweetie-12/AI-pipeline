variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "akhila-gcp-123-493309"
}

variable "project_number" {
  description = "GCP Project Number"
  type        = string
  default     = "828956650755"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-south1-a"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, staging, prod."
  }
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
  default     = "ai-platform-cluster"
}

variable "database_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "ai-platform-db"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "aiplatform"
}

variable "database_version" {
  description = "Database version"
  type        = string
  default     = "POSTGRES_15"
}

variable "database_tier" {
  description = "Database tier"
  type        = string
  default     = "db-custom-4-16384"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "ai-platform-vpc"
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
  default     = "AkhilaSweetie-12/AI-pipeline"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "aiplatform.example.com"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "secrets" {
  description = "Map of secret names to values"
  type        = map(string)
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}
