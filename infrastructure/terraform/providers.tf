terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.32.0"  # Fixed version
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
  
  backend "local" {
    path = "./terraform-state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Kubernetes and Helm providers will be configured manually
# Use kubectl and helm directly for Kubernetes resources
