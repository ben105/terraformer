resource "google_cloud_run_service" "backend-service" {
  project  = var.project
  location = var.region
  name     = var.name

  template {
    spec {
      containers {
        image = "us-west1-docker.pkg.dev/terraformer-415819/terraformer-app-repo/${var.name}:${var.tag}"
        resources {
          limits = {
            "cpu"    = 1
            "memory" = "128Mi"
          }
        }

        startup_probe {
          failure_threshold     = 3
          initial_delay_seconds = 60
          period_seconds        = 10
          timeout_seconds       = 10
          http_get {
            path = "/healthz"
            port = 8080
          }
        }
      }
    }

    metadata {
      labels = {
        "run.googleapis.com/startupProbeType" = "Custom"
      }
      annotations = {
        "run.googleapis.com/client-name" = "terraform"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

data "google_compute_default_service_account" "appengine-default" {
  project = var.project
}

data "google_iam_policy" "invoker" {
  binding {
    role    = "roles/run.invoker"
    members = ["serviceAccount:${data.google_compute_default_service_account.appengine-default.email}"]
  }
}

resource "google_cloud_run_service_iam_policy" "invoker" {
  service     = google_cloud_run_service.backend-service.name
  project     = var.project
  location    = var.region
  policy_data = data.google_iam_policy.invoker.policy_data
}
