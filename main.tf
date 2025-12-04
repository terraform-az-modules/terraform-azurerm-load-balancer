##-----------------------------------------------------------------------------
## Tagging Module – Applies standard tags to all resources
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##----------------------------------------------------------------------------
## Public IP Address for Load Balancer
#-----------------------------------------------------------------------------
resource "azurerm_public_ip" "default" {
  count                   = var.enabled && var.public_ip_enabled ? var.ip_count : 0
  name                    = var.resource_position_prefix ? format("pip-%s-%s", local.name, count.index + 1) : format("%s-pip-%s", local.name, count.index + 1)
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku                     = var.sku
  allocation_method       = var.sku == "Standard" ? "Static" : var.allocation_method
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = var.domain_name_label
  reverse_fqdn            = var.reverse_fqdn
  public_ip_prefix_id     = var.public_ip_prefix_id
  zones                   = var.zones
  ddos_protection_mode    = var.ddos_protection_mode
  tags                    = module.labels.tags

  timeouts {
    create = var.create
    update = var.update
    read   = var.read
    delete = var.delete
  }
}


##----------------------------------------------------------------------------
## Load Balancer
##----------------------------------------------------------------------------
resource "azurerm_lb" "load-balancer" {
  count               = var.enabled ? 1 : 0
  location            = var.location
  name                = var.resource_position_prefix ? format("load-balancer-%s", local.name) : format("%s-load-balancer", local.name)
  resource_group_name = var.resource_group_name
  edge_zone           = var.edge_zone
  sku                 = var.lb_sku

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.value.name
      private_ip_address            = lookup(frontend_ip_configuration.value, "private_ip_address", null)
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address_version    = lookup(frontend_ip_configuration.value, "private_ip_address_version", null)
      public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.default[frontend_ip_configuration.key].id : null
      subnet_id                     = lookup(frontend_ip_configuration.value, "subnet_id", null)
    }
  }

  timeouts {
    create = var.create
    update = var.update
    read   = var.read
    delete = var.delete
  }
}

##----------------------------------------------------------------------------
## Backend Address Pool for Load Balancer
##----------------------------------------------------------------------------
resource "azurerm_lb_backend_address_pool" "load-balancer" {
  count           = var.enabled && var.is_enable_backend_pool ? 1 : 0
  loadbalancer_id = azurerm_lb.load-balancer[0].id
  name            = var.resource_position_prefix ? format("be-pool-%s", local.name) : format("%s-be-pool", local.name)
}

##----------------------------------------------------------------------------
## Network Interface Backend Address Pool Association
##----------------------------------------------------------------------------
resource "azurerm_network_interface_backend_address_pool_association" "default" {
  count                   = var.enabled && var.is_enable_backend_pool && var.enable_ni_association ? length(var.network_interface_id_association) : 0
  network_interface_id    = var.network_interface_id_association[count.index]
  ip_configuration_name   = var.ip_configuration_name_association[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.load-balancer[0].id
}

##----------------------------------------------------------------------------
## NAT Rules for Load Balancer
##----------------------------------------------------------------------------
resource "azurerm_lb_nat_rule" "load-balancer" {
  count                          = var.enabled && length(var.remote_port) > 0 ? length(var.remote_port) : 0
  backend_port                   = element(var.remote_port[element(keys(var.remote_port), count.index)], 1)
  frontend_ip_configuration_name = azurerm_lb.load-balancer[0].frontend_ip_configuration[0].name
  loadbalancer_id                = azurerm_lb.load-balancer[0].id
  name                           = "VM-lb-nat-rule${count.index}"
  protocol                       = var.nat_protocol
  resource_group_name            = var.resource_group_name
  frontend_port                  = "5000${count.index + 1}"
}

##----------------------------------------------------------------------------
## Load Balancer Health Probe
##----------------------------------------------------------------------------
resource "azurerm_lb_probe" "load-balancer" {
  count               = var.enabled && length(var.lb_probe) > 0 ? length(var.lb_probe) : 0
  loadbalancer_id     = azurerm_lb.load-balancer[0].id
  name                = element(keys(var.lb_probe), count.index)
  port                = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 1)
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  protocol            = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 0)
  request_path        = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 2)
}

##----------------------------------------------------------------------------
## Load Balancer Rule
##----------------------------------------------------------------------------
resource "azurerm_lb_rule" "load-balancer" {
  count                          = var.enabled && var.is_enable_backend_pool && length(var.lb_port) > 0 ? length(var.lb_port) : 0
  backend_port                   = element(var.lb_port[element(keys(var.lb_port), count.index)], 2)
  frontend_ip_configuration_name = azurerm_lb.load-balancer[0].frontend_ip_configuration[0].name
  frontend_port                  = element(var.lb_port[element(keys(var.lb_port), count.index)], 0)
  loadbalancer_id                = azurerm_lb.load-balancer[0].id
  name                           = element(keys(var.lb_port), count.index)
  protocol                       = element(var.lb_port[element(keys(var.lb_port), count.index)], 1)
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.load-balancer[0].id]
  floating_ip_enabled            = var.floating_ip_enabled
  idle_timeout_in_minutes        = var.idle_timeout_in_minutes
  probe_id                       = element(azurerm_lb_probe.load-balancer[*].id, count.index)
}