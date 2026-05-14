# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id

  description = "VPC for AI Platform ${var.environment}"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vpc_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id

  private_ip_google_access = true

  description = "Subnet for AI Platform ${var.environment}"
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name      = "${var.vpc_name}-allow-internal"
  network   = google_compute_network.vpc.name
  project   = var.project_id
  priority  = 1000

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_tags = ["allow-internal"]
  target_tags = ["allow-internal"]

  description = "Allow internal traffic"
}

resource "google_compute_firewall" "allow_ssh" {
  name      = "${var.vpc_name}-allow-ssh"
  network   = google_compute_network.vpc.name
  project   = var.project_id
  priority  = 1001

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]

  description = "Allow SSH access"
}

resource "google_compute_firewall" "allow_https" {
  name      = "${var.vpc_name}-allow-https"
  network   = google_compute_network.vpc.name
  project   = var.project_id
  priority  = 1002

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]

  description = "Allow HTTPS traffic"
}

resource "google_compute_firewall" "allow_http" {
  name      = "${var.vpc_name}-allow-http"
  network   = google_compute_network.vpc.name
  project   = var.project_id
  priority  = 1003

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]

  description = "Allow HTTP traffic"
}

# Cloud Router for Private Google Access
resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.name
  project = var.project_id

  bgp {
    asn = 64514
  }
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}
