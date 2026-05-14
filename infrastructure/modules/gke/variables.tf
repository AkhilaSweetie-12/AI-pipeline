variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "network_self_link" {
  description = "VPC network self link"
  type        = string
}

variable "subnet_self_link" {
  description = "Subnet self link"
  type        = string
}

variable "service_account" {
  description = "Service account email"
  type        = string
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum node count"
  type        = number
  default     = 5
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}
