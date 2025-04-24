# Start with a Python base image
FROM python:3.12-slim

# Install required Python packages
RUN pip install --no-cache-dir pandas google-cloud-storage google-cloud-bigquery pyarrow

# Copy your application code to the container
COPY gcs_to_bigquery/ /app

WORKDIR /app

# Define the entrypoint for the container
CMD ["python", "main.py"]
