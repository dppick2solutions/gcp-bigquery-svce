## TODO: Enable Cloud Functions API
## TODO: Enable Cloud Build API
## TODO: Enable EventArc API

# Deploy the export function that pulls from Azure SQL and writes to GCS
resource "google_cloud_run_v2_job" "azure_to_gcs" {
  name     = "azure-to-gcs"
  location = "us-central1"
  deletion_protection = false
  template {
    template{
      containers {
      image = "us-central1-docker.pkg.dev/${data.google_project.project.project_id}/pick2-bq-demo/azure-to-gcs"
      env {
        name = "AZURE_SQL_SERVER"   
        value = "${var.sql_server_name}.database.windows.net"
      }
      env {
        name = "AZURE_SQL_DATABASE"
        value = var.sql_db_name
      }
      env {
        name = "AZURE_SQL_USER"
        value = var.sql_admin_username
      }
      env {
        name = "AZURE_SQL_PASSWORD"
        value = var.sql_admin_password
      }
      env {
        name = "TARGET_BUCKET"
        value = var.gcp_bucket_name
      }
    }
    }
  }
}

resource "google_cloud_run_v2_job" "gcs_to_bq" {
  name     = "gcs-to-bq"
  location = "us-central1"
  deletion_protection = false

  template {
    template {
      containers {
        image = "us-central1-docker.pkg.dev/${data.google_project.project.project_id}/pick2-bq-demo/gcs-to-bq"
      }
    }
  }
}

# todo: compute storage account needs BQ access.

# Define the storage bucket and the service account for Eventarc
resource "google_storage_bucket_iam_member" "eventarc_bucket_permissions" {
  bucket = google_storage_bucket.rawfiles.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "gcs_pubsub_publisher_role" {
  project = data.google_project.project.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}
