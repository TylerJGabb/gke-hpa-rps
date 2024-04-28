resource "google_compute_instance" "tf_spy_instance" {
  name         = "tf-spy-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.tf_network.name
    subnetwork = google_compute_subnetwork.tf_subnet.name
  }
}
