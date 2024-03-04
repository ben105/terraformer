locals {
  backend-releases-content = [for file-name in fileset("../releases", "**/backend.release") : trimspace(file("../releases/${file-name}"))]
  backend-releases = [for content in local.backend-releases-content : {
    name = split(":", content)[0]
    tag  = split(":", content)[1]
  }]

  frontend-releases-content = [for file-name in fileset("../releases", "**/frontend.release") : trimspace(file("../releases/${file-name}"))]
  frontend-releases = [for content in local.backend-releases-content : {
    name = split(":", content)[0]
    tag  = split(":", content)[1]
  }]
}

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

module "backends" {
  source = "./app"

  for_each = { for release in local.backend-releases : "${release.name}-be" => release.tag }

  project = var.project
  region  = var.region

  name = each.key
  tag  = each.value
}

module "frontends" {
  source = "./app"

  for_each = { for release in local.frontend-releases : "${release.name}-fe" => release.tag }

  project = var.project
  region  = var.region

  name = each.key
  tag  = each.value

  iap = {
    id     = google_iap_client.iap_client.client_id
    secret = google_iap_client.iap_client.secret
  }
}

}