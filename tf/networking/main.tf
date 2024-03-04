resource "google_compute_global_address" "application-endpoint" {
  project      = var.project
  name         = "application-endpoint"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_ssl_policy" "api-restricted-ssl-policy" {
  project         = var.project
  name            = "api-restricted-ssl-policy"
  min_tls_version = "TLS_1_2"
  profile         = "MODERN"
}

resource "google_compute_target_https_proxy" "application-load-balancer-proxy" {
  name          = "application-load-balancer-proxy"
  project       = var.project
  proxy_bind    = "false"
  quic_override = "NONE"

  ssl_policy = google_compute_ssl_policy.api-restricted-ssl-policy.self_link
  url_map    = google_compute_url_map.application-url-map.self_link
}
