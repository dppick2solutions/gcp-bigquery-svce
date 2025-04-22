## ------
## Azure SQL
## ------
resource "azurerm_resource_group" "bq_demo" {
  name     = "pick2_bq_demo"
  location = "Central US"
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.bq_demo.name
  location                     = azurerm_resource_group.bq_demo.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "example" {
  name         = "BigQueryDemo"
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 50
  sku_name     = "S0"
  enclave_type = "VBS"
}