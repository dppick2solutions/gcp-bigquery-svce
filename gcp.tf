provider "google" {
  project = "pick2-svce-demo"
  region  = "us-central1"
}

resource "google_project" "project" {
  name            = var.gcp_project_id
  project_id      = var.gcp_project_id
  org_id          = var.org_id
  billing_account = var.billing_id
}

resource "google_project_service" "bigquery_api" {
  project = google_project.project.project_id
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "storage_api" {
  project = google_project.project.project_id
  service = "storage.googleapis.com"
}

resource "google_project_service" "cloudrun_api" {
  project = google_project.project.project_id
  service = "run.googleapis.com"
}

## ------
## BigQuery
## ------
module "bigquery" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.1"

  dataset_id                  = "svce_demo"
  dataset_name                = "svce_demo"
  description                 = "Sample SVCE dataset"
  project_id                  = google_project.project.project_id
  location                    = "US"
  default_table_expiration_ms = 3600000
}

## ------
## Cloud Storage - Files on GCP Side
## ------
resource "google_storage_bucket" "rawfiles" {
  name     = "svce-rawfiles"
  location = "US"
  project  = google_project.project.project_id
}


## ------
## CloudRun Import Job
## ------
# resource "google_cloud_run_service" "data_pipeline" {
#   name     = "my-cloudrun-service"
#   location = "us-central1"
#   project  = google_project.project.project_id

#   template {
#     spec {
#       containers {
#         image = "gcr.io/my-project/my-container-image:latest"
#       }
#     }
#   }
# }

resource "google_project_iam_member" "storage_admin" {
  project = google_project.project.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_cloud_run_service.data_pipeline.name}@${google_project.project.project_id}.iam.gserviceaccount.com"
}


## ------
## IAM
## ------
resource "google_project_iam_member" "bigquery_admin" {
  project = google_project.project.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_cloud_run_service.data_pipeline.name}@${google_project.project.project_id}.iam.gserviceaccount.com"
}
