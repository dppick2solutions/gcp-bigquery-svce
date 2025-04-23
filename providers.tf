provider "azurerm" {
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  tenant_id       = var.azure_tenant_id
  use_oidc        = true
  features {}
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}