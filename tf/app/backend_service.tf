resource "google_compute_region_network_endpoint_group" "api-serverless-group" {
  project               = var.project
  name                  = "api-${var.name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = var.name
  }
}

resource "google_compute_backend_service" "api-service" {
  project = var.project
  name    = "${var.name}-api-service"

  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_region_network_endpoint_group.api-serverless-group.self_link
  }

  enable_cdn = false

      dynamic "iap" {
      for_each = var.iap ? [null] : []
      content {
        oauth2_client_id     = var.iap.client-id
        oauth2_client_secret = var.iap.client-secret
      }
    }

  log_config {
    enable      = "true"
    sample_rate = "1.0"
  }

  port_name        = "http"
  protocol         = "HTTPS"
  session_affinity = "NONE"
}