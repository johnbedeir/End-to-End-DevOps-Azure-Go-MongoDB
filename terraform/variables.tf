variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the name of resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
  default     = "East US"
}

variable "cloudsql_name" {
  description = "The name of the Azure SQL instance"
  type        = string
}

variable "service_principal_object_id" {
  description = "The object ID of the service principal"
  type        = string
}

variable "db_username" {
  description = "The database username"
  type        = string
}
