##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "azurerm_lb_backend_address_pool_id" {
  description = "the id for the azurerm_lb_backend_address_pool resource"
  value       = var.is_enable_backend_pool ? azurerm_lb_backend_address_pool.load-balancer[0].id : null
}

output "azurerm_lb_frontend_ip_configuration" {
  description = "the frontend_ip_configuration for the azurerm_lb resource"
  value       = azurerm_lb.load-balancer[0].frontend_ip_configuration
}

output "azurerm_lb_id" {
  description = "the id for the azurerm_lb resource"
  value       = azurerm_lb.load-balancer[0].id
}

output "azurerm_lb_nat_rule_ids" {
  description = "the ids for the azurerm_lb_nat_rule resources"
  value       = try(azurerm_lb_nat_rule.load-balancer[*].id, null)
}

output "azurerm_lb_probe_ids" {
  description = "the ids for the azurerm_lb_probe resources"
  value       = try(azurerm_lb_probe.load-balancer[*].id, null)
}

output "azurerm_lb_ip_address" {
  description = "The Public IP address for the Load Balancer"
  value       = var.public_ip_enabled ? azurerm_public_ip.default[0].id : null
}

output "azurerm_public_ip_id" {
  description = "the id for the azurerm_lb_public_ip resource"
  value       = var.public_ip_enabled ? azurerm_public_ip.default[0].id : null
}
