# Define provider configuration for Google Cloud Platform
provider "google" {
  credentials = file("path/to/credentials.json")
  project     = "test-task"
  region      = "us-central1"
}

# Create a VPC network
resource "google_compute_network" "landing_zone_network" {
  name = "landing-zone-network"
}

# Create a subnet within the network
resource "google_compute_subnetwork" "landing_zone_subnet" {
  name          = "landing-zone-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.landing_zone_network.self_link
  region        = "us-central1"
}

# Create a firewall rule to allow ingress traffic to the cluster
resource "google_compute_firewall" "allow_ingress_to_cluster" {
  name    = "allow-ingress-to-cluster"
  network = google_compute_network.landing_zone_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_tags = ["gke-cluster"]
}

# Create a project
resource "google_project" "project_1" {
  name = "project-1"
}

# Link the project to the VPC network
resource "google_compute_shared_vpc_host_project" "project_1_host" {
  host_project = "test-task"
  service_project = google_project.project_1.project_id
}

# Attach the subnet to the project
resource "google_compute_shared_vpc_subnetwork" "project_1_subnet" {
  name          = "project-1-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  shared_vpc    = google_compute_shared_vpc_host_project.project_1_host.name
}

# Create another project
resource "google_project" "project_2" {
  name = "project-2"
}

# Link the project to the VPC network
resource "google_compute_shared_vpc_host_project" "project_2_host" {
  host_project = "test-task"
  service_project = google_project.project_2.project_id
}

# Attach the subnet to the project
resource "google_compute_shared_vpc_subnetwork" "project_2_subnet" {
  name          = "project-2-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  shared_vpc    = google_compute_shared_vpc_host_project.project_2_host.name
}
