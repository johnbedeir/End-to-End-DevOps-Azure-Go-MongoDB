# output "sql_server_name" {
#   value       = azurerm_sql_server.sql_server.name
#   description = "The name of the Azure SQL Server instance"
# }

# output "sql_server_public_ip" {
#   value       = azurerm_public_ip.external_ip.ip_address
#   description = "The public IP address of the Azure SQL Server"
# }

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "The acr name"
}

output "aks_cluster_location" {
  value       = azurerm_kubernetes_cluster.aks.location
  description = "The location of the AKS cluster"
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "client_id" {
  value = data.azuread_service_principal.aks.object_id
}

output "principal_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
