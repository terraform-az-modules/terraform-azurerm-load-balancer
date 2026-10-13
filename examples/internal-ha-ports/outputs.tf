##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "lb_id" {
  value       = module.load-balancer.azurerm_lb_id
  description = "The ID of the Load Balancer."
}

output "backend_address_pool_id" {
  value       = module.load-balancer.azurerm_lb_backend_address_pool_id
  description = "The ID of the backend address pool."
}
