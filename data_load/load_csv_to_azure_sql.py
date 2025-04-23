import pandas as pd
import os
from sqlalchemy import create_engine

# Replace with your actual connection details
server   = os.getenv('AZURE_SQL_SERVER')
database = os.getenv('AZURE_SQL_DB')
username = os.getenv('AZURE_SQL_USER')
password = os.getenv('AZURE_SQL_PASSWORD')
driver = '{ODBC Driver 17 for SQL Server}'

# Create SQLAlchemy engine
connection_string = f"mssql+pyodbc://{username}:{password}@{server}.database.windows.net:1433/{database}?driver=ODBC+Driver+17+for+SQL+Server"
engine = create_engine(connection_string)

# Load CSV
df = pd.read_csv('sample_energy_usage_data.csv')

# Optional: Rename or format columns if needed
# df.columns = [col.replace(" ", "_") for col in df.columns]

# Upload to SQL (creates or replaces a table named 'energy_data')
df.to_sql('energy_data', engine, if_exists='replace', index=False)

print("Data inserted successfully!")
