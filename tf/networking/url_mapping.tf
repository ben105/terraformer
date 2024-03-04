resource "google_compute_url_map" "application-url-map" {
  project = var.project
  name    = "application-url-map"

  default_url_redirect {
    host_redirect = "example.com"
    strip_query   = true
  }

  dynamic "host_rule" {
    for_each = var.backends
    content {
      hosts        = [host_rule.value["host"]]
      path_matcher = host_rule.value["name"]
    }
  }

  dynamic "path_matcher" {
    for_each = var.backends
    content {
      name = path_matcher.value["name"]
      default_url_redirect {
        host_redirect = "example.com"
        strip_query   = true
      }

      path_rule {
        paths   = ["/${path_matcher.value["name"]}/api/*"]
        service = path_matcher.value["service"]
      }
    }
  }
}