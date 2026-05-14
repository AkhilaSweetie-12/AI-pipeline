# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone  # Use zone instead of region for zonal cluster
  project  = var.project_id

  # Use zonal cluster
  initial_node_count = 1

  network    = var.network_self_link
  subnetwork = var.subnet_self_link

  # Use smaller machine type to avoid resource issues
  remove_default_node_pool = true
  
  # Create a smaller node pool
  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
  }

  # Basic configuration only
  resource_labels = {
    environment = var.environment
    project     = "ai-platform"
  }

  depends_on = [
    google_project_service.container
  ]
}

# Simple Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name        = "default-pool"
  location    = var.zone  # Use zone instead of region
  cluster     = google_container_cluster.primary.name
  project     = var.project_id
  node_count  = 1
  version     = "1.35.3-gke.1389000"  # Fixed version to avoid issues

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    service_account = var.service_account
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Enable required APIs
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}
