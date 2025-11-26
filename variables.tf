
##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "vnet-core-dev".
- If false, the keyword is appended: "core-dev-vnet".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
## Labels
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = null
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "location" {
  type        = string
  default     = null
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "environment" {
  type        = string
  default     = null
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "label_order" {
  type        = list(string)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-vnet"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

##-----------------------------------------------------------------------------
## Global Variables
##-----------------------------------------------------------------------------
variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "A container that holds related resources for an Azure solution"
}

##-----------------------------------------------------------------------------
## Public IP Variables
##-----------------------------------------------------------------------------
variable "ip_count" {
  type        = number
  default     = 0
  description = "Number of Public IP Addresses to create."
}

variable "public_ip_enabled" {
  type        = bool
  default     = false
  description = "Whether public IP is enabled."
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
}

variable "allocation_method" {
  type        = string
  default     = ""
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
}

variable "ip_version" {
  type        = string
  default     = ""
  description = "The IP Version to use, IPv6 or IPv4."
}

variable "domain_name_label" {
  type        = string
  default     = null
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
}

variable "reverse_fqdn" {
  type        = string
  default     = ""
  description = "A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN."
}

variable "public_ip_prefix_id" {
  type        = string
  default     = null
  description = "If specified then public IP address allocated will be provided from the public IP prefix resource."
}

variable "zones" {
  type        = list(any)
  default     = null
  description = "A collection containing the availability zone to allocate the Public IP in."
}

variable "ddos_protection_mode" {
  type        = string
  default     = "VirtualNetworkInherited"
  description = "(Optional) The DDoS protection mode of the public IP. Possible values are `Disabled`, `Enabled`, and `VirtualNetworkInherited`. Defaults to `VirtualNetworkInherited`."
}

variable "create" {
  type        = string
  default     = "60m"
  description = "Used when creating the Resource Group."
}

variable "update" {
  type        = string
  default     = "60m"
  description = "Used when updating the Resource Group."
}

variable "read" {
  type        = string
  default     = "5m"
  description = "Used when retrieving the Resource Group."
}

variable "delete" {
  type        = string
  default     = "60m"
  description = "Used when deleting the Resource Group."
}

##-----------------------------------------------------------------------------
## Load Balancer Variables
##-----------------------------------------------------------------------------
variable "edge_zone" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Public IP and Load Balancer should exist. Changing this forces new resources to be created."
}

variable "lb_sku" {
  type        = string
  default     = "Standard"
  description = "(Optional) The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
}

variable "frontend_ip_configurations" {
  type = list(object({
    name                          = string
    private_ip_address            = optional(string)
    private_ip_address_allocation = string
    private_ip_address_version    = optional(string)
    subnet_id                     = optional(string)
  }))
  default = [
    {
      name                          = "mypublicIP"
      private_ip_address_allocation = "Dynamic"
      public_ip_enabled             = true
      # Only set one of private_ip_address or subnet_id depending on your setup
      # private_ip_address          = null # For static private IP
      subnet_id = null
    }
  ]
  description = "Configuration for frontend IPs of the Load Balancer."
}

##-----------------------------------------------------------------------------
## Load Balancer Health Probe Variables
##-----------------------------------------------------------------------------
variable "lb_probe" {
  type        = map(any)
  default     = {}
  description = "(Optional) Protocols to be used for lb health probes. Format as [protocol, port, request_path]"
}

variable "lb_probe_interval" {
  type        = number
  default     = 5
  description = "Interval in seconds the load balancer health probe rule does a check"
}

variable "lb_probe_unhealthy_threshold" {
  type        = number
  default     = 2
  description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
}

##-----------------------------------------------------------------------------
## Load Balancer NAT Rule Variables
## -----------------------------------------------------------------------------
variable "remote_port" {
  type        = map(any)
  default     = {}
  description = "Protocols to be used for remote vm access. [protocol, backend_port].  Frontend port will be automatically generated starting at 50000 and in the output."
}

variable "nat_protocol" {
  type        = string
  default     = "Tcp"
  description = "(Required) The protocol of Load Balancer's NAT rule."
}

##-----------------------------------------------------------------------------
## Backend Pool and NI Association Variables
##-----------------------------------------------------------------------------
variable "is_enable_backend_pool" {
  type        = bool
  default     = false
  description = "Backend Pool Configuration for the Load Balancer."
}

variable "enable_ni_association" {
  type        = bool
  default     = false
  description = "Enable or disable Network Interface Association with Load Balancer Backend Pool"
}

variable "network_interaface_id_association" {
  type        = list(string)
  default     = [""]
  description = "(Required) Network Interaface id for Network Interface Association with Load Balancer."
}

variable "ip_configuration_name_association" {
  type        = list(string)
  default     = [""]
  description = "(Required) Ip Configuration name for Network Interaface Association with Load Balancer."
}

##-----------------------------------------------------------------------------
## Load Balancer Rule Variables
##-----------------------------------------------------------------------------
variable "lb_port" {
  type        = map(any)
  default     = {}
  description = "Protocols to be used for lb rules. Format as [frontend_port, protocol, backend_port]"
}

variable "floating_ip_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable floating IP for load balancer to preserve original destination IP address"
}

variable "idle_timeout_in_minutes" {
  type        = number
  default     = 10
  description = "Specifies the timeout for the TCP idle connection. The value can be set between 4 and 60 minutes."
}
