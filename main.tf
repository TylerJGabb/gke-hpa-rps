terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.26.0"
    }
  }
  backend "gcs" {
    bucket = "gke-sandbox-tf-state-fcad"
  }
}

provider "google" {
  project = "gke-sandbox-421603"
  region  = "us-central1"
}
