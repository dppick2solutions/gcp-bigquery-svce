# GCP BigQuery SVCE

This project automates the process of exporting data from an Azure SQL database to Google Cloud Storage (GCS) and subsequently loading it into Google BigQuery. It leverages Terraform for infrastructure provisioning and Google Cloud Run Jobs for data processing.

---

## Features

- **Azure SQL to GCS**: Exports data from Azure SQL to a CSV file stored in a GCS bucket.
- **GCS to BigQuery**: Loads the CSV file from GCS into a BigQuery table.
- **Infrastructure as Code**: Uses Terraform to provision GCP resources, including Cloud Run Jobs, GCS buckets, and BigQuery datasets.
- **CI/CD Integration**: Automates deployment using GitHub Actions.

---

## Directory Structure

### `azure_data_load`
Contains a Python script to load CSV data into an Azure SQL database. This script handles the transformation and insertion of data into the database.

### `cloud_run_containers/export_to_gcs`
Includes a Python script and Docker configuration to create a Cloud Run job. This job exports data from Azure SQL to a CSV file and uploads it to a GCS bucket.

### `cloud_run_containers/gcs_to_bigquery`
Contains a Python script and Docker configuration to create a Cloud Run job. This job loads the CSV file from GCS into a BigQuery table.

### `terraform`
gcp.tf - holds Terraform configuration files for provisioning GCP resources such as Cloud Run Jobs, GCS bucket, and BigQuery.

azure.tf - holds Terraform configuration files for provisioning Azure SQL DB.

### `ci_cd`
.github/workflows Includes configuration files for GitHub Actions to automate the deployment and testing of the project.

---

## Getting Started

1. **Set Up Azure SQL**: Ensure your Azure SQL database is configured and accessible.
2. **Provision GCP Resources**: Use the Terraform scripts in the `terraform` directory to set up the required GCP infrastructure.
3. **Build and Deploy Cloud Run Jobs**:
   - Navigate to `cloud_run_containers/export_to_gcs` and `cloud_run_containers/gcs_to_bigquery` to build and deploy the respective Docker images.
4. **Run Data Pipeline**:
   - Use the `azure_data_load` script to populate Azure SQL with data.
   - Trigger the Cloud Run jobs to export data to GCS and load it into BigQuery.

---

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any bugs or feature requests.

---