terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

resource "random_integer" "affix" {
  min = 1000
  max = 9999
}

locals {
  affix    = random_integer.affix.result
  workload = "contoso${local.affix}"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source                          = "./modules/vnet"
  resource_group_name             = azurerm_resource_group.default.name
  location                        = azurerm_resource_group.default.location
  workload                        = local.workload
  allowed_source_address_prefixes = var.allowed_source_address_prefixes
}

module "nat_gateway" {
  source              = "./modules/nat"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  workload            = local.workload
  nat_subnet_id       = module.vnet.subnet_nat_id
  vms_subnet_id       = module.vnet.subnet_vms_id
}

module "vm001" {
  source              = "./modules/vm"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  vm_number           = "001"
  vm_zone             = "1"
  subnet_id           = module.vnet.subnet_vms_id
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  public_key_path     = var.vm_public_key_path
  image_publisher     = var.vm_image_publisher
  image_offer         = var.vm_image_offer
  image_sku           = var.vm_image_sku
  image_version       = var.vm_image_version
}

module "vm002" {
  source              = "./modules/vm"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  vm_number           = "002"
  vm_zone             = "2"
  subnet_id           = module.vnet.subnet_vms_id
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  public_key_path     = var.vm_public_key_path
  image_publisher     = var.vm_image_publisher
  image_offer         = var.vm_image_offer
  image_sku           = var.vm_image_sku
  image_version       = var.vm_image_version
}

module "load_balancer" {
  source              = "./modules/load-balancer"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  workload            = local.workload
  vnet_id             = module.vnet.vnet_id

  # VM001
  vm001_nic_ipconfig_name    = module.vm001.nic_ipconfig_name
  vm001_network_interface_id = module.vm001.network_interface_id

  # VM002
  vm002_nic_ipconfig_name    = module.vm002.nic_ipconfig_name
  vm002_network_interface_id = module.vm002.network_interface_id
}

module "private_load_balancer" {
  source                          = "./modules/priv-lb"
  resource_group_name             = azurerm_resource_group.default.name
  location                        = azurerm_resource_group.default.location
  workload                        = local.workload
  vnet_id                         = module.vnet.vnet_id
  subnet_private_load_balancer_id = module.vnet.subnet_private_load_balancer_id

  # VM001
  vm001_nic_ipconfig_name    = module.vm001.nic_ipconfig_name
  vm001_network_interface_id = module.vm001.network_interface_id

  # VM002
  vm002_nic_ipconfig_name    = module.vm002.nic_ipconfig_name
  vm002_network_interface_id = module.vm002.network_interface_id
}
