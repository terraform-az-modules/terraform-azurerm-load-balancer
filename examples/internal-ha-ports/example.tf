##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.4"
  name        = "nva"
  environment = "qa"
  label_order = ["name", "environment", "location"]
  location    = "westus3"
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.4"
  name                = "nva"
  environment         = "qa"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/22"]
}

##-----------------------------------------------------------------------------
## Subnet
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.3"
  environment          = "qa"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "trust"
      subnet_prefixes = ["10.0.0.64/27"]
    }
  ]
}

##-----------------------------------------------------------------------------
## Internal, zone redundant Load Balancer with an HA ports rule: the next hop
## in front of a pair of network virtual appliances. Add the appliances' NICs
## with enable_ni_association, network_interface_id_association and
## ip_configuration_name_association.
##-----------------------------------------------------------------------------
module "load-balancer" {
  source              = "../.."
  name                = "nva"
  environment         = "qa"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  lb_sku            = "Standard"
  public_ip_enabled = false
  frontend_ip_configurations = [
    {
      name                          = "frontend"
      subnet_id                     = module.subnet.subnet_ids["trust"]
      private_ip_address_allocation = "Static"
      private_ip_address            = "10.0.0.68"
      zones                         = ["1", "2", "3"]
    }
  ]

  is_enable_backend_pool = true
  # [protocol, port]; request_path is only needed for Http and Https probes.
  lb_probe = {
    health = ["Tcp", "443"]
  }
  # HA ports: [frontend_port, protocol, backend_port] = 0, All, 0.
  lb_port = {
    ha-ports = ["0", "All", "0"]
  }
}
