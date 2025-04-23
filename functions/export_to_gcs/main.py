import pandas as pd
from sqlalchemy import create_engine
from google.cloud import storage
import os
import tempfile

def export_to_gcs(request):
    server   = os.getenv('AZURE_SQL_SERVER')
    database = os.getenv('AZURE_SQL_DB')
    username = os.getenv('AZURE_SQL_USER')
    password = os.getenv('AZURE_SQL_PASSWORD')
    bucket_name = os.getenv('TARGET_BUCKET')
    driver = '{ODBC Driver 17 for SQL Server}'

    engine = create_engine(
        f"mssql+pyodbc://{username}:{password}@{server}:1433/{database}?driver=ODBC+Driver+17+for+SQL+Server"
    )

    df = pd.read_sql("SELECT * FROM energy_data", engine)

    destination_blob_name = "energy_data_export.csv"

    with tempfile.NamedTemporaryFile(mode='w+', suffix='.csv', delete=False) as temp_file:
        df.to_csv(temp_file.name, index=False)

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(temp_file.name)

    return f"Uploaded {destination_blob_name} to bucket {bucket_name}"
