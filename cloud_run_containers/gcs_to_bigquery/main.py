from google.cloud import bigquery
import pandas as pd
import os
import tempfile
from google.cloud import storage

def gcs_to_bigquery(event, context):
    bucket_name = event['bucket']
    file_name = event['name']

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    with tempfile.NamedTemporaryFile() as temp_file:
        blob.download_to_filename(temp_file.name)
        df = pd.read_csv(temp_file.name)

    bq_client = bigquery.Client(project="pick2-bigquery-demo")
    table_id = "pick2-bigquery-demo.svce_demo.energy_data"

    job = bq_client.load_table_from_dataframe(df, table_id)
    job.result()

    return f"{file_name} successfully loaded into {table_id}"
