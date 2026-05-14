variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_version" {
  description = "Database version"
  type        = string
}

variable "database_tier" {
  description = "Database tier"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "network_self_link" {
  description = "VPC network self link"
  type        = string
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
