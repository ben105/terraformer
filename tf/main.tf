terraform {
  required_version = ">= 1.3.0"
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.10.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.10.0"
    }
  }
}

data "google_project" "project" {
  project_id = var.project
}

resource "google_compute_network" "vpc_network" {
  project = var.project
  name    = "vpc-network"
}