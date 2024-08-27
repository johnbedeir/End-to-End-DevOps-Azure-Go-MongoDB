variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the name of resources"
  type        = string
  default     = "cluster-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
}

variable "client_id" {
  description = "The Azure Client Id"
  type        = string
}

variable "client_secret" {
  description = "The Azure Client Secret"
  type        = string
}