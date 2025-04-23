resource "google_storage_bucket_object" "export_to_gcs_zip" {
  name   = "export_to_gcs.zip"
  bucket = google_storage_bucket.svce_rawfiles.name
  source = "functions/export_to_gcs.zip" # Path to local zip archive
}

# Deploy the export function that pulls from Azure SQL and writes to GCS
resource "google_cloudfunctions_function" "export_to_gcs" {
  name        = "export-sql-to-gcs"
  description = "Exports Azure SQL data to a GCS bucket"
  runtime     = "python310"
  region      = "us-central1"
  available_memory_mb = 512

  # Service account with GCS write permissions
  service_account_email = google_service_account.gcf_sa.email
  entry_point = "export_to_gcs"

  # Code source location (in GCS bucket)
  source_archive_bucket = google_storage_bucket.svce_rawfiles.name
  source_archive_object = google_storage_bucket_object.export_to_gcs_zip.name

  # Trigger via HTTP request
  trigger_http = true
}

resource "google_storage_bucket_object" "gcs_to_bigquery_zip" {
  name   = "gcs_to_bigquery.zip"
  bucket = google_storage_bucket.svce_rawfiles.name
  source = "functions/gcs_to_bigquery.zip" # Path to local zip archive
}

# Deploy the load function that loads data from GCS to BigQuery
resource "google_cloudfunctions_function" "gcs_to_bigquery" {
  name        = "load-gcs-to-bq"
  description = "Loads CSV from GCS into a BigQuery table"
  runtime     = "python310"
  region      = "us-central1"
  available_memory_mb = 512

  # Service account with GCS + BigQuery access
  service_account_email = google_service_account.gcf_sa.email

  # Function entry point (function name in main.py)
  entry_point = "gcs_to_bigquery"

  # Code source location (in GCS bucket)
  source_archive_bucket = google_storage_bucket.svce_rawfiles.name
  source_archive_object = google_storage_bucket_object.gcs_to_bigquery_zip.name

  # Trigger on new file finalized in GCS
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = "projects/_/buckets/svce-rawfiles"
  }
}
