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

    # Load CSV
    csv_file = 'sample_energy_usage_data.csv'
    logging.info(f"Attempting to load CSV file: {csv_file}")
    df = pd.read_csv(csv_file)
    logging.info(f"CSV file '{csv_file}' loaded successfully with {len(df)} rows.")

    # Prepare to create the table
    table_name = 'energy_data'
    columns = df.columns
    column_defs = []

    # Mapping Pandas dtype to SQL data types
    type_mapping = {
        'int64': 'INT',
        'float64': 'FLOAT',
        'object': 'NVARCHAR(MAX)',
        'datetime64[ns]': 'DATETIME',
    }

    for col in columns:
        # Map the pandas dtype to SQL Server type
        sql_type = type_mapping.get(str(df[col].dtype), 'NVARCHAR(MAX)')
        column_defs.append(f"{col} {sql_type}")

    # Create table query
    create_table_query = f"CREATE TABLE {table_name} ({', '.join(column_defs)})"
    logging.info(f"Creating table with the query: {create_table_query}")

    # Execute the CREATE TABLE query
    cursor.execute(create_table_query)
    connection.commit()
    logging.info(f"Table '{table_name}' created successfully.")

    # Prepare SQL statement to insert data into the table
    placeholders = ', '.join(['?'] * len(df.columns))
    insert_query = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"

    # Upload data to SQL (insert each row into the table)
    logging.info(f"Uploading data to Azure SQL table: {table_name}")
    for _, row in df.iterrows():
        cursor.execute(insert_query, tuple(row))
    connection.commit()  # Commit the transaction to the database
    logging.info(f"Data uploaded successfully to table '{table_name}'.")

    # Log end of the script
    logging.info("Script completed successfully. Data inserted into Azure SQL.")

except Exception as e:
    logging.error(f"An error occurred: {e}")
finally:
    if connection:
        connection.close()
        logging.info("Connection to Azure SQL closed.")
