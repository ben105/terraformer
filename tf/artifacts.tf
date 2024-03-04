resource "google_artifact_registry_repository" "terraformer-app-repo" {
  project       = var.project
  location      = var.region
  repository_id = "terraformer-app-repo"
  description   = "Artifact registry repository for application Docker images"
  format        = "DOCKER"
}
