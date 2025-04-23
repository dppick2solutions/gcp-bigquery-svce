resource "google_storage_bucket_object" "export_to_gcs_zip" {
  name   = "export_to_gcs.zip"
  bucket = google_storage_bucket.rawfiles.name
  source = "functions/export_to_gcs.zip" # Path to local zip archive
}

## TODO: Enable Cloud Functions API
## TODO: Enable Cloud Build API

# Deploy the export function that pulls from Azure SQL and writes to GCS

resource "google_cloudfunctions2_function" "export_to_gcs" {
  name = "export-sql-to-gcs"
  location = "us-central1"
  description = "Exports Azure SQL data to a GCS bucket"

  build_config {
    runtime = "python310"
    entry_point = "export_to_gcs"  # Set the entry point 
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
}
resource "google_storage_bucket_object" "gcs_to_bigquery_zip" {
  name   = "gcs_to_bigquery.zip"
  bucket = google_storage_bucket.rawfiles.name
  source = "functions/gcs_to_bigquery.zip" # Path to local zip archive
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
}
