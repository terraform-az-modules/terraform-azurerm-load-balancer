## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allocation\_method | Defines the allocation method for this IP address. Possible values are Static or Dynamic. | `string` | `""` | no |
| create | Used when creating the Resource Group. | `string` | `"60m"` | no |
| custom\_name | Override default naming convention | `string` | `null` | no |
| ddos\_protection\_mode | (Optional) The DDoS protection mode of the public IP. Possible values are `Disabled`, `Enabled`, and `VirtualNetworkInherited`. Defaults to `VirtualNetworkInherited`. | `string` | `"VirtualNetworkInherited"` | no |
| delete | Used when deleting the Resource Group. | `string` | `"60m"` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| domain\_name\_label | Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system. | `string` | `null` | no |
| edge\_zone | (Optional) Specifies the Edge Zone within the Azure Region where this Public IP and Load Balancer should exist. Changing this forces new resources to be created. | `string` | `null` | no |
| enable\_ni\_association | Enable or disable Network Interface Association with Load Balancer Backend Pool | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `null` | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| floating\_ip\_enabled | Enable or disable floating IP for load balancer to preserve original destination IP address | `bool` | `false` | no |
| frontend\_ip\_configurations | Configuration for frontend IPs of the Load Balancer. | <pre>list(object({<br>    name                          = string<br>    private_ip_address            = optional(string)<br>    private_ip_address_allocation = string<br>    private_ip_address_version    = optional(string)<br>    subnet_id                     = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "name": "mypublicIP",<br>    "private_ip_address_allocation": "Dynamic",<br>    "subnet_id": null<br>  }<br>]</pre> | no |
| idle\_timeout\_in\_minutes | Specifies the timeout for the TCP idle connection. The value can be set between 4 and 60 minutes. | `number` | `10` | no |
| ip\_configuration\_name\_association | (Required) Ip Configuration name for Network Interface Association with Load Balancer. | `list(string)` | `[]` | no |
| ip\_count | Number of Public IP Addresses to create. | `number` | `0` | no |
| ip\_version | The IP Version to use, IPv6 or IPv4. | `string` | `""` | no |
| is\_enable\_backend\_pool | Backend Pool Configuration for the Load Balancer. | `bool` | `false` | no |
| label\_order | The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']. | `list(string)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| lb\_port | Protocols to be used for lb rules. Format as [frontend\_port, protocol, backend\_port] | `map(any)` | `{}` | no |
| lb\_probe | (Optional) Protocols to be used for lb health probes. Format as [protocol, port, request\_path] | `map(any)` | `{}` | no |
| lb\_probe\_interval | Interval in seconds the load balancer health probe rule does a check | `number` | `5` | no |
| lb\_probe\_unhealthy\_threshold | Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy. | `number` | `2` | no |
| lb\_sku | (Optional) The SKU of the Azure Load Balancer. Accepted values are Basic and Standard. | `string` | `"Standard"` | no |
| location | The location/region where the virtual network is created. Changing this forces a new resource to be created. | `string` | `null` | no |
| managedby | ManagedBy, eg 'terraform-az-modules'. | `string` | `"terraform-az-modules"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `null` | no |
| nat\_protocol | (Required) The protocol of Load Balancer's NAT rule. | `string` | `"Tcp"` | no |
| network\_interface\_id\_association | (Required) Network Interface id for Network Interface Association with Load Balancer. | `list(string)` | `[]` | no |
| public\_ip\_enabled | Whether public IP is enabled. | `bool` | `false` | no |
| public\_ip\_prefix\_id | If specified then public IP address allocated will be provided from the public IP prefix resource. | `string` | `null` | no |
| read | Used when retrieving the Resource Group. | `string` | `"5m"` | no |
| remote\_port | Protocols to be used for remote vm access. [protocol, backend\_port].  Frontend port will be automatically generated starting at 50000 and in the output. | `map(any)` | `{}` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azure-vnet"` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| resource\_position\_prefix | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>- If true, the keyword is prepended: "vnet-core-dev".<br>- If false, the keyword is appended: "core-dev-vnet".<br><br>This helps maintain naming consistency based on organizational preferences. | `bool` | `true` | no |
| reverse\_fqdn | A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN. | `string` | `""` | no |
| sku | The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. | `string` | `"Standard"` | no |
| update | Used when updating the Resource Group. | `string` | `"60m"` | no |
| zones | A collection containing the availability zone to allocate the Public IP in. | `list(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_lb\_backend\_address\_pool\_id | the id for the azurerm\_lb\_backend\_address\_pool resource |
| azurerm\_lb\_frontend\_ip\_configuration | the frontend\_ip\_configuration for the azurerm\_lb resource |
| azurerm\_lb\_id | the id for the azurerm\_lb resource |
| azurerm\_lb\_ip\_address | The Public IP address for the Load Balancer |
| azurerm\_lb\_nat\_rule\_ids | the ids for the azurerm\_lb\_nat\_rule resources |
| azurerm\_lb\_probe\_ids | the ids for the azurerm\_lb\_probe resources |
| azurerm\_public\_ip\_id | the id for the azurerm\_lb\_public\_ip resource |

