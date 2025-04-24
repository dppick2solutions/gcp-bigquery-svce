# Start with a Python base image
FROM python:3.12-slim

# Install dependencies for ODBC
# update data from apt-get repositories
RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get -y install curl && \
    apt-get -y install gnupg && \
    apt-get -y install wget

# sql server drivers and bcp
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    apt-get install -y unixodbc-dev && \
    apt-get install -y libgssapi-krb5-2

# Install required Python packages
RUN pip install --no-cache-dir pandas pyodbc google-cloud-storage google-cloud-logging

# Copy your application code to the container
COPY export_to_gcs/ /app

WORKDIR /app

# Define the entrypoint for the container
CMD ["python", "main.py"]