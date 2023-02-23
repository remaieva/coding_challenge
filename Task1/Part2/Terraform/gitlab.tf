resource "google_compute_network" "gitlab-network" {
  name = "gitlab-network"
}

resource "google_compute_subnetwork" "gitlab-subnetwork" {
  name          = "gitlab-subnetwork"
  network       = google_compute_network.gitlab-network.self_link
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_firewall" "gitlab-firewall" {
  name    = "gitlab-firewall"
  network = google_compute_network.gitlab-network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "gitlab-address" {
  name = "gitlab-address"
}

resource "google_compute_instance" "gitlab-instance" {
  name         = "gitlab-instance"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"
  tags         = ["gitlab-server"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network = google_compute_network.gitlab-network.self_link
    subnetwork = google_compute_subnetwork.gitlab-subnetwork.self_link
    access_config {
      nat_ip = google_compute_address.gitlab-address.address
    }
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "null_resource" "wait-for-ip" {
  provisioner "local-exec" {
    command = "until [ \"$(gcloud compute instances describe gitlab-instance --format='get(networkInterfaces[0].accessConfigs[0].natIP)')\" != \"\" ]; do sleep 1; done"
  }
}

resource "null_resource" "wait-for-ssh" {
  depends_on = [null_resource.wait-for-ip]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = google_compute_instance.gitlab-instance.network_interface.0.access_config.0.nat_ip
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl openssh-server ca-certificates",
      "sudo apt-get install -y postfix",
      "curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash",
      "sudo apt-get install -y gitlab-ce",
      "sudo gitlab-ctl reconfigure"
    ]
  }
}

output "gitlab-url" {
  value = "https://${google_compute_instance.gitlab-instance.network_interface.0.access_config.0.nat_ip}"
}
