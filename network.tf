
resource "google_compute_network" "tf_network" {
  name                    = "tf-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "tf_subnet" {
  network       = google_compute_network.tf_network.id
  name          = "tf-subnet"
  ip_cidr_range = "10.1.0.0/24"
}

resource "google_compute_subnetwork" "proxy_only_subnet" {
  network       = google_compute_network.tf_network.id
  name          = "proxy-only-subnet"
  ip_cidr_range = "172.16.0.0/24"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.tf_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

// allow all internal traffic
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.tf_network.name

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}
