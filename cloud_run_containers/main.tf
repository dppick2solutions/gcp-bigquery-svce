data "google_project" "project" {
  project_id = var.gcp_project_id
}

resource "google_artifact_registry_repository" "repo" {
  location      = "us-central1"
  repository_id = "pick2-bq-demo"
  description   = "Docker Repository"
  format        = "DOCKER"
  project       = data.google_project.project.project_id

  docker_config {
    immutable_tags = false
  }
}

resource "google_artifact_registry_repository_iam_binding" "binding" {
  project = google_artifact_registry_repository.repo.project
  location = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name
  role = "roles/artifactregistry.repoAdmin"
  members = [
    "serviceAccount:bigquery-pipeline-demo@pick2-bigquery-demo.iam.gserviceaccount.com", #parameter later.
  ]
}