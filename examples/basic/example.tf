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
  version     = "1.0.3"
  name        = "app"
  environment = "qa"
  label_order = ["environment", "name", "location"]
  location    = "canadacentral"
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "app"
  environment         = "qa"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnets
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = "app"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]
  enable_route_table = true
  route_tables = [
    {
      name = "pub"
      routes = [
        {
          name           = "rt-test"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
      ]
    }
  ]
}

##-----------------------------------------------------------------------------
## Load Balancer
##-----------------------------------------------------------------------------
module "load-balancer" {
  source = "../.."
  #   Labels
  name        = "app"
  environment = "qa"
  #   Common
  enabled             = true
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  # Load Balancer
  frontend_ip_configurations = [
    {
      name                          = "mypublicIP" # This is getting used in frontend_ip_configuration_name
      private_ip_address_allocation = "Dynamic"
      # subnet_id                     = module.subnet.subnet_ids["subnet1"] ## Use this for internal load balancer
      # private_ip_address = "10.0.1.6" ## Use this for static private IP
    }
  ]
  lb_sku = "Standard"

  #   Public IP
  ip_count          = 1
  allocation_method = "static"
  sku               = "Standard"
  nat_protocol      = "Tcp"
  public_ip_enabled = true ## Set to True for public load balancer
  ip_version        = "IPv4"

  # Backend Pool
  is_enable_backend_pool = false
  # network_interaface_id_association = ""

  remote_port = {
    ssh   = ["Tcp", "22"]
    https = ["Tcp", "80"]
  }

  lb_port = {
    http  = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }

  lb_probe = {
    http  = ["Tcp", "80", ""]
    http2 = ["Http", "1443", "/"]
  }

  depends_on = [module.resource_group]
}
