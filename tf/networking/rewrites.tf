resource "google_compute_url_map" "url-map" {
  project     = var.project
  name        = "application-https-redirect-url-map"
  description = "HTTP to HTTPS redirect for the application-https-redirect forwarding rule"

  default_url_redirect {
    https_redirect         = "true"
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = "false"
  }
}

resource "google_compute_target_http_proxy" "https-redirect" {
  name       = "application-https-redirect-target-proxy"
  project    = var.project
  proxy_bind = "false"
  url_map    = google_compute_url_map.url-map.self_link
}

resource "google_compute_global_forwarding_rule" "application-https-redirect" {
  project               = var.project
  name                  = "application-https-redirect"
  ip_address            = google_compute_global_address.application-endpoint.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80-80"
  target                = google_compute_target_http_proxy.https-redirect.self_link
}


resource "google_compute_global_forwarding_rule" "application-fe-config" {
  project               = var.project
  ip_address            = google_compute_global_address.application-endpoint.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "application-fe-config"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.application-load-balancer-proxy.self_link
}
