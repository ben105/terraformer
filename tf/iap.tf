resource "google_iap_brand" "default" {
  project = data.google_project.project.project_id

  support_email     = "observer105@gmail.com"
  application_title = "Ben's personal sandbox app"
}

resource "google_iap_client" "iap_client" {
  display_name = "Ben's personal sandbox app"
  brand        = google_iap_brand.default.name
}

resource "google_iap_web_iam_binding" "default" {
  project = data.google_project.project.project_id

  role = "roles/iap.httpsResourceAccessor"
  members = [
    "user:observer105@gmail.com"
  ]
}
