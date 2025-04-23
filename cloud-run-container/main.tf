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
    immutable_tags = true
  }
}