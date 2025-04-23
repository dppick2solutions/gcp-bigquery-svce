data "google_project" "project" {
  project_id = var.gcp_project_id
}

resource "google_service_account" "gcf_sa" {
  account_id   = "bigquery-pipeline-demo"
  display_name = "BigQuery Pipeline Demo Account"
}

resource "google_project_service" "bigquery_api" {
  project = data.google_project.project.project_id
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "storage_api" {
  project = data.google_project.project.project_id
  service = "storage.googleapis.com"
}

resource "google_project_service" "cloudrun_api" {
  project = data.google_project.project.project_id
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
  project_id                  = data.google_project.project.project_id
  location                    = "US"
  default_table_expiration_ms = 3600000
}

## ------
## Cloud Storage - Files on GCP Side
## ------
resource "google_storage_bucket" "rawfiles" {
  name     = "pick2-svce-rawfiles"
  location = "us-central1"
  project  = data.google_project.project.project_id
}
