from google.cloud import bigquery
from google.cloud import storage
import pandas as pd
import os
import tempfile

def gcs_to_bigquery(bucket_name, file_name):
    # Download the file from GCS
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    with tempfile.NamedTemporaryFile() as temp_file:
        blob.download_to_filename(temp_file.name)
        df = pd.read_csv(temp_file.name)

    # Load into BigQuery
    bq_client = bigquery.Client(project="pick2-bigquery-demo")
    table_id = "pick2-svce-demo.svce_demo.energy_data"

    job = bq_client.load_table_from_dataframe(df, table_id)
    job.result()

    print(f"{file_name} successfully loaded into {table_id}")


def main():
    bucket_name = "pick2-svce-rawfiles"
    file_name = "energy_data_export.csv"

    if not bucket_name or not file_name:
        raise ValueError("Both BUCKET_NAME and FILE_NAME environment variables must be set")

    gcs_to_bigquery(bucket_name, file_name)


if __name__ == "__main__":
    main()
