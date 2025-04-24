import pandas as pd
import os
import logging
import pyodbc

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

try:
    # Log start of the script
    logging.info("Starting the script to load CSV data into Azure SQL.")

    # Replace with your actual connection details
    server = os.getenv('AZURE_SQL_SERVER')
    database = os.getenv('AZURE_SQL_DB')
    username = os.getenv('AZURE_SQL_USER')
    password = os.getenv('AZURE_SQL_PASSWORD')
    driver = '{ODBC Driver 17 for SQL Server}'

    # Log environment variable loading
    logging.info("Loaded environment variables for Azure SQL connection.")

    # Create connection string
    connection_string = f"DRIVER={driver};SERVER={server}.database.windows.net;PORT=1433;DATABASE={database};UID={username};PWD={password}"
    logging.info(f"Connection string created: {connection_string}")

    # Establish connection to Azure SQL
    connection = pyodbc.connect(connection_string)
    cursor = connection.cursor()
    logging.info("Connection to Azure SQL established successfully.")

    # Load first CSV
    csv_file_1 = 'sample_energy_usage_data.csv'
    logging.info(f"Attempting to load CSV file: {csv_file_1}")
    df1 = pd.read_csv(csv_file_1)
    logging.info(f"CSV file '{csv_file_1}' loaded successfully with {len(df1)} rows.")

    # Create first table
    table_name_1 = 'energy_data'
    columns_1 = df1.columns
    column_defs_1 = []

    type_mapping = {
        'int64': 'INT',
        'float64': 'FLOAT',
        'object': 'NVARCHAR(MAX)',
        'datetime64[ns]': 'DATETIME',
    }

    for col in columns_1:
        sql_type = type_mapping.get(str(df1[col].dtype), 'NVARCHAR(MAX)')
        column_defs_1.append(f"{col} {sql_type}")

    create_table_query_1 = f"CREATE TABLE {table_name_1} ({', '.join(column_defs_1)})"
    logging.info(f"Creating table with the query: {create_table_query_1}")

    cursor.execute(create_table_query_1)
    connection.commit()
    logging.info(f"Table '{table_name_1}' created successfully.")

    placeholders_1 = ', '.join(['?'] * len(df1.columns))
    insert_query_1 = f"INSERT INTO {table_name_1} ({', '.join(columns_1)}) VALUES ({placeholders_1})"

    logging.info(f"Uploading data to Azure SQL table: {table_name_1}")
    for _, row in df1.iterrows():
        cursor.execute(insert_query_1, tuple(row))
    connection.commit()
    logging.info(f"Data uploaded successfully to table '{table_name_1}'.")

    # Load second CSV
    csv_file_2 = 'sample_energy_usage_data_v2.csv'
    logging.info(f"Attempting to load second CSV file: {csv_file_2}")
    df2 = pd.read_csv(csv_file_2)
    logging.info(f"CSV file '{csv_file_2}' loaded successfully with {len(df2)} rows.")

    # Create second table
    table_name_2 = 'energy_data_v2'
    columns_2 = df2.columns
    column_defs_2 = []

    for col in columns_2:
        sql_type = type_mapping.get(str(df2[col].dtype), 'NVARCHAR(MAX)')
        column_defs_2.append(f"{col} {sql_type}")

    create_table_query_2 = f"CREATE TABLE {table_name_2} ({', '.join(column_defs_2)})"
    logging.info(f"Creating second table with the query: {create_table_query_2}")

    cursor.execute(create_table_query_2)
    connection.commit()
    logging.info(f"Table '{table_name_2}' created successfully.")

    placeholders_2 = ', '.join(['?'] * len(df2.columns))
    insert_query_2 = f"INSERT INTO {table_name_2} ({', '.join(columns_2)}) VALUES ({placeholders_2})"

    logging.info(f"Uploading data to Azure SQL table: {table_name_2}")
    for _, row in df2.iterrows():
        cursor.execute(insert_query_2, tuple(row))
    connection.commit()
    logging.info(f"Data uploaded successfully to table '{table_name_2}'.")

    logging.info("Script completed successfully. Both CSV files inserted into Azure SQL.")

except Exception as e:
    logging.error(f"An error occurred: {e}")

finally:
    if 'connection' in locals():
        connection.close()
        logging.info("Connection to Azure SQL closed.")
