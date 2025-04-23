# Start with a Python base image
FROM python:3.12-slim

# Install dependencies for ODBC
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Install required Python packages
RUN pip install --no-cache-dir pandas pyodbc google-cloud-storage

# Set environment variables (optional, can also be passed to Cloud Run as ENV Vars)
ENV AZURE_SQL_SERVER=your-server
ENV AZURE_SQL_DATABASE=your-database
ENV AZURE_SQL_USER=your-username
ENV AZURE_SQL_PASSWORD=your-password
ENV TARGET_BUCKET=your-bucket

# Copy your application code to the container
COPY functions/export_to_gcs /app

WORKDIR /app

# Define the entrypoint for the container
CMD ["python", "main.py"]