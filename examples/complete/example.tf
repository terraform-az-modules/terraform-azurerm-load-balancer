provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

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
## Network Security Group
##-----------------------------------------------------------------------------
module "security_group" {
  source              = "terraform-az-modules/nsg/azurerm"
  version             = "1.0.1"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "10.0.0.0/16"
      source_port_range          = "*"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "SSH from VNet to internet"
    }
  ]
}

##------------------------------------------------------------------------------
## Key Vault
##------------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "1.0.1"
  name                          = "app"
  environment                   = "qa"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  enable_private_endpoint       = false
  public_network_access_enabled = true
  sku_name                      = "premium"
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = []
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  diagnostic_setting_enable = false
}

##-----------------------------------------------------------------------------
## Log Analytics
##-----------------------------------------------------------------------------
module "log-analytics" {
  source              = "terraform-az-modules/log-analytics/azurerm"
  version             = "1.0.2"
  name                = "core"
  environment         = "qa"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
}

##-----------------------------------------------------------------------------
## Linux Virtual Machine
##-----------------------------------------------------------------------------
module "virtual-machine" {
  depends_on          = [module.vault]
  source              = "github.com/terraform-az-modules/terraform-azurerm-virtual-machine"
  name                = "app"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  is_vm_linux         = true
  user_object_id = {
    "user1" = {
      role_definition_name = "Virtual Machine Administrator Login"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  ## NSG
  network_interface_sg_enabled = true
  network_security_group_id    = module.security_group.id
  ## Network Interface
  private_ip_addresses = ["10.0.1.8"]
  subnet_id            = module.subnet.subnet_ids.subnet1

  public_ip_enabled = false # Will use Load Balancer Public IP
  ## Virtual Machine
  vm_size                    = "Standard_B1s"
  admin_username             = "ubuntu"
  public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSFojkyDOwQ0UTrgX/32dp/xedfzBOFk3cZoPuVtQlnxNOzIkiTg8e1R0L+EbB0/7ObZRKlcz9UQ2AvGWP3d59u89BT/sykeM99E0Y+c4pDWGkfZerrBRvlCxgnhAhWhsF38Dggti7ZtwDwTZdeUXWFGBwzKczBrCwROhuksniyp6QrVQmp2yIrzQyBLBQ6TiWHl7cG9HB8ADn1sz6g92vgKwDIPXAusCZAz7r05ESg4f0e4izyBMczzxfFgs0wYVWdbMLrhHEx3Rh75jrtGb4sUcUK3pKAlSdeZOMRILckQb9wwjY2paEm7yPtXeT6zTTB+xAP23AY2AGghmxyoK2WSd5PC8gzaW9zUlJEdTaKa0qouRS7KI283C8hnZtO0rH0pPnpx1bBgfQclQkxS5IqjyIb4OMWlPiBx2Dly/f1shsOKBZQG7rv6BlhOp52aQLC8YEh8h+8PjFkrCBzXUE72vqg4r/1WqW3SssA/G9Dj0ryAovmEAR7vJ0YuKdos8A/fKJtWcnVRaBjY+voQgW1O8SJAhLJA1UB/qEeYepzqXOhYG32TLXl1zsRlspxf9Le0RYJPpA5odOnn0ZmOirwko89WLZJtLQhrK86FNeG42WUgbVFDMqDn/PyzlhJ8vJKSnqydC5lleKZdc3jtc20Nh7TUDUdsU1vTN8NKORDQ== azure-vm-key"
  caching                    = "ReadWrite"
  disk_size_gb               = 30
  image_publisher            = "Canonical"
  image_offer                = "0001-com-ubuntu-server-jammy"
  image_sku                  = "22_04-lts-gen2"
  image_version              = "latest"
  enable_disk_encryption_set = true
  key_vault_id               = module.vault.id
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 60
      storage_account_type = "StandardSSD_LRS"
    }
  ]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## Load Balancer
##-----------------------------------------------------------------------------
module "load-balancer" {
  source = "../.."

  #   Labels
  name        = "core"
  environment = "qa"

  #   Common
  enabled             = true
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  lb_sku              = "Standard"

  # Load Balancer
  frontend_ip_configurations = [
    {
      name                          = "publicIP" # This is getting used in frontend_ip_configuration_name
      private_ip_address_allocation = "Dynamic"
      # subnet_id                     = module.subnet.subnet_ids["subnet1"] ## Use this for internal load balancer
      # private_ip_address = "10.0.1.6" # Use this for static private IP
    }
  ]

  ip_count          = 1
  allocation_method = "static"
  sku               = "Standard"
  nat_protocol      = "Tcp"
  public_ip_enabled = true ## Set to True for public load balancer
  ip_version        = "IPv4"

  # Backend Pool
  is_enable_backend_pool            = true
  enable_ni_association             = true
  network_interface_id_association  = [module.virtual-machine.network_interface_id]
  ip_configuration_name_association = ["app-test-ip-config-1"]
  # ip_configuration_name_association = [module.virtual-machine.ip_configuration_name] # Needs to define output in VM for this

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
}
