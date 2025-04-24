import pandas as pd
import os
import logging
import pyodbc
import sys
from google.cloud import storage
import tempfile
import google.cloud.logging

def export_to_gcs():
    # Set up logging configuration
    client = google.cloud.logging.Client()
    client.setup_logging()

    try:
        # Log start of the function
        logging.info("Starting the data export to GCS.")

        # Fetch Azure SQL connection details from environment variables
        server   = os.getenv('AZURE_SQL_SERVER')
        database = os.getenv('AZURE_SQL_DATABASE')
        username = os.getenv('AZURE_SQL_USER')
        password = os.getenv('AZURE_SQL_PASSWORD')
        bucket_name = os.getenv('TARGET_BUCKET')

        driver = '{ODBC Driver 17 for SQL Server}'

        # Create the connection string for Azure SQL
        connection_string = f"DRIVER={driver};SERVER={server};PORT=1433;DATABASE={database};UID={username};PWD={password}"

        # Establish connection to Azure SQL
        connection = pyodbc.connect(connection_string)
        cursor = connection.cursor()

        # Log successful connection
        logging.info("Connected to Azure SQL successfully.")

        # Define queries and corresponding file names
        exports = [
            ("SELECT * FROM dbo.energy_data", "energy_data_export.csv"),
            ("SELECT * FROM dbo.energy_data_v2", "energy_data_export2.csv")
        ]

        # Google Cloud Storage client
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)

        for query, filename in exports:
            logging.info(f"Running query: {query}")
            df = pd.read_sql(query, connection)

            # Create a temporary CSV file to store data
            with tempfile.NamedTemporaryFile(mode='w+', suffix='.csv', delete=False) as temp_file:
                df.to_csv(temp_file.name, index=False)
                temp_file_path = temp_file.name

            # Upload the CSV file to Google Cloud Storage
            blob = bucket.blob(filename)
            blob.upload_from_filename(temp_file_path)

            # Clean up the temporary file
            os.remove(temp_file_path)

            logging.info(f"Uploaded {filename} to bucket {bucket_name}")

        # Close the database connection
        connection.close()
        logging.info("Connection to Azure SQL closed.")

        sys.stdout.flush()
        return f"Uploaded all tables to bucket {bucket_name}"

    except Exception as e:
        logging.error(f"An error occurred: {e}")

        sys.stdout.flush()
        raise  # Optionally re-raise the exception to propagate the error

def main():
    # Explicitly call the export_to_gcs function
    export_to_gcs()

if __name__ == '__main__':
    main()