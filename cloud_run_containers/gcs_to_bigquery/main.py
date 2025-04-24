from google.cloud import bigquery
from google.cloud import storage
import pandas as pd
import os
import tempfile

def gcs_to_bigquery(bucket_name, files_and_tables):
    # Initialize clients
    storage_client = storage.Client()
    bq_client = bigquery.Client(project="pick2-bigquery-demo")

    for file_name, table_id in files_and_tables:
        # Download the file from GCS
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)

        with tempfile.NamedTemporaryFile() as temp_file:
            blob.download_to_filename(temp_file.name)
            df = pd.read_csv(temp_file.name)

        # Load into BigQuery
        job = bq_client.load_table_from_dataframe(df, table_id)
        job.result()

        print(f"{file_name} successfully loaded into {table_id}")

def main():
    bucket_name = "pick2-svce-rawfiles"
    files_and_tables = [
        ("energy_data_export.csv", "pick2-bigquery-demo.svce_demo.energy_data"),
        ("energy_data_export2.csv", "pick2-bigquery-demo.svce_demo.energy_data_v2")
    ]

    if not bucket_name or not files_and_tables:
        raise ValueError("Both BUCKET_NAME and file-table mappings must be set")

    gcs_to_bigquery(bucket_name, files_and_tables)

if __name__ == "__main__":
    main()