output "id" {
  description = "Resource ID of the resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region of the resource group."
  value       = azurerm_resource_group.this.location
}

output "subscription_id" {
  description = "Subscription ID of the resource group."
  value       = data.azurerm_client_config.current.subscription_id
}
