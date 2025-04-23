data "archive_file" "export_to_gcs" {
  type        = "zip"
  output_path = "export-to-gcs.zip"
  source_dir  = "functions/export_to_gcs/"
}
resource "google_storage_bucket_object" "export_to_gcs_zip" {
  name   = "export_to_gcs.zip"
  bucket = google_storage_bucket.rawfiles.name
  source = data.archive_file.export_to_gcs.output_path
}

data "archive_file" "gcs_to_bigquery" {
  type        = "zip"
  output_path = "gcs-to-bigquery.zip"
  source_dir  = "functions/gcs_to_bigquery/"
}
resource "google_storage_bucket_object" "gcs_to_bigquery_zip" {
  name   = "gcs_to_bigquery.zip"
  bucket = google_storage_bucket.rawfiles.name
  source = data.archive_file.gcs_to_bigquery.output_path
}

## TODO: Enable Cloud Functions API
## TODO: Enable Cloud Build API
## TODO: Enable EventArc API

# Deploy the export function that pulls from Azure SQL and writes to GCS


resource "google_cloudfunctions2_function" "export_to_gcs" {
  name        = "export-sql-to-gcs"
  location    = "us-central1"
  description = "Exports Azure SQL data to a GCS bucket"

  build_config {
    runtime     = "python310"
    entry_point = "export_to_gcs"
    environment_variables = {
      AZURE_SQL_SERVER   = "${var.sql_server_name}.database.windows.net"
      AZURE_SQL_DATABASE = var.sql_db_name
      AZURE_SQL_USER     = var.sql_admin_username
      AZURE_SQL_PASSWORD = var.sql_admin_password
      TARGET_BUCKET      = var.gcp_bucket_name
    }
    source {
      storage_source {
        bucket = google_storage_bucket.rawfiles.name
        object = google_storage_bucket_object.export_to_gcs_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
  depends_on = [google_storage_bucket_object.export_to_gcs_zip]
}

resource "google_cloudfunctions2_function" "gcs_to_bigquery" {
  name        = "export-to-bigquery"
  location    = "us-central1"
  description = "Loads CSV from GCS into a BigQuery table"

  build_config {
    runtime     = "python310"
    entry_point = "gcs_to_bigquery"
    source {

      storage_source {
        bucket = google_storage_bucket.rawfiles.name
        object = google_storage_bucket_object.gcs_to_bigquery_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
  event_trigger {
    event_type = "google.cloud.storage.object.v1.finalized"
    retry_policy = "RETRY_POLICY_DO_NOT_RETRY"
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.rawfiles.name
    }
  }
  depends_on = [google_storage_bucket_iam_member.eventarc_bucket_permissions, google_storage_bucket_object.gcs_to_bigquery_zip]
}

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
