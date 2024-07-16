output "sql_server_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The name of the Azure SQL Server instance"
}

output "sql_server_public_ip" {
  value       = azurerm_public_ip.external_ip.ip_address
  description = "The public IP address of the Azure SQL Server"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}

output "subscription_id" {
  value       = var.subscription_id
  description = "The Azure Subscription ID"
}

output "db_username" {
  value       = var.db_username
  description = "The database username"
}

output "aks_cluster_location" {
  value       = azurerm_kubernetes_cluster.aks.location
  description = "The location of the AKS cluster"
}
