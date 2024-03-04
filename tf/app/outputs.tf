output "host" {
  value = replace(google_cloud_run_service.backend-service.status[0].url, "/^https:\\/\\//", "")
}

output "name" {
  value = google_cloud_run_service.backend-service.name
}

output "service" {
  value = google_compute_backend_service.api-service.self_link
}