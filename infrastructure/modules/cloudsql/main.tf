# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier = var.database_tier

    ip_configuration {
      ipv4_enabled = true
      
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }

    backup_configuration {
      enabled            = true
      location           = var.region
      start_time         = "02:00"
    }

    maintenance_window {
      day          = 7  # Sunday
      hour         = 3
      update_track = "stable"
    }

    user_labels = {
      environment = var.environment
      project     = "ai-platform"
    }
  }

  deletion_protection = false

  depends_on = [
    google_project_service.sqladmin
  ]
}

# Database
resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Database User
resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.main.name
  password = var.database_password
  project  = var.project_id
}

# Private VPC Connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network       = var.network_self_link
  service       = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  depends_on = [
    google_project_service.servicenetworking
  ]
}

# Reserved IP Range for Private VPC
resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.instance_name}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_self_link
  project       = var.project_id
}

# Enable required APIs
resource "google_project_service" "sqladmin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "sql-component" {
  project = var.project_id
  service = "sql-component.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"

  disable_on_destroy = false
}
