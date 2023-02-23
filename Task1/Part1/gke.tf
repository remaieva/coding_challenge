# Define a private cluster
resource "google_container_cluster" "private_cluster" {
  name               = "private-cluster"
  location           = "us-central1"
  initial_node_count = 1

  network = google_compute_network.landing_zone_network.self_link

  subnetwork = google_compute_subnetwork.landing_zone_subnet.self_link

  master_authorized_networks_config {
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Enable private cluster
  private_cluster_config {
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  # Define node pool
  node_pool {
    name       = "private-pool"
    machine_type = "n1-standard-2"

    # Enable private nodes
    node_config {
      network = google_compute_network.landing_zone_network.self_link
      subnetwork = google_compute_subnetwork.landing_zone_subnet.self_link

      metadata = {
        disable-legacy-endpoints = "true"
      }

      # Define startup script for nodes
      boot_disk {
        initialize_params {
          image = "cos-stable-95-15470-1235-0"
        }
      }
    }
  }

  # Define private endpoint for GKE API server
  private_cluster_endpoint {
    enable_private_endpoint = true
  }

  # Define a Kubernetes provider to manage the cluster
  provider "kubernetes" {
    host                   = google_container_cluster.private_cluster.endpoint
    client_certificate     = base64decode(google_container_cluster.private_cluster.master_auth[0].client_certificate)
    client_key             = base64decode(google_container_cluster.private_cluster.master_auth[0].client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.private_cluster.master_auth[0].cluster_ca_certificate)
  }
}
