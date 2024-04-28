resource "google_container_cluster" "tf_autopilot_cluster" {
  name             = "tf-autopilot-cluster"
  location         = "us-central1"
  enable_autopilot = true
  network          = google_compute_network.tf_network.name
  subnetwork       = google_compute_subnetwork.tf_subnet.name
  ip_allocation_policy {}
}
