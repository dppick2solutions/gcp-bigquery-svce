# GCP BigQuery SVCE

This project automates the process of exporting data from an Azure SQL database to Google Cloud Storage (GCS) and subsequently loading it into Google BigQuery. It leverages Terraform for infrastructure provisioning and Google Cloud Functions for data processing.

---

## Features

- **Azure SQL to GCS**: Exports data from Azure SQL to a CSV file stored in a GCS bucket.
- **GCS to BigQuery**: Loads the CSV file from GCS into a BigQuery table.
- **Infrastructure as Code**: Uses Terraform to provision GCP resources, including Cloud Functions, GCS buckets, and BigQuery datasets.
- **CI/CD Integration**: Automates deployment using GitHub Actions.


