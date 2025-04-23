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
  name = "export-sql-to-gcs"
  location = "us-central1"
  description = "Exports Azure SQL data to a GCS bucket"

  build_config {
    runtime = "python310"
    entry_point = "export_to_gcs"
    source {
      storage_source {
        bucket = google_storage_bucket.rawfiles.name
        object = google_storage_bucket_object.export_to_gcs_zip.name
      }
    }
  }

  service_config {
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
  }
  depends_on = [ google_storage_bucket_object.export_to_gcs_zip ]
}

resource "google_cloudfunctions2_function" "gcs_to_bigquery" {
  name = "export-sql-to-gcs"
  location = "us-central1"
  description = "Loads CSV from GCS into a BigQuery table"

  build_config {
    runtime = "python310"
    entry_point = "gcs_to_bigquery" 
    source {
      storage_source {
        bucket = google_storage_bucket.rawfiles.name
        object = google_storage_bucket_object.gcs_to_bigquery_zip.name
      }
    }
  }

  service_config {
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
  }
  event_trigger {
    event_type = "google.cloud.storage.object.v1.finalized"
    event_filters {
      attribute = "bucket"
      value = google_storage_bucket.rawfiles.name
    }
  }
  depends_on = [ google_storage_bucket_iam_member.eventarc_bucket_permissions, google_storage_bucket_object.gcs_to_bigquery_zip ]
}

# Define the storage bucket and the service account for Eventarc
resource "google_storage_bucket_iam_member" "eventarc_bucket_permissions" {
  bucket = google_storage_bucket.rawfiles.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@eventarc.iam.gserviceaccount.com"
}
