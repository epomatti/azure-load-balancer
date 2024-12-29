resource "azurerm_public_ip" "default" {
  name                 = "pip-lb-${var.workload}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  sku_tier             = "Regional"
  ip_version           = "IPv4"
  ddos_protection_mode = "Disabled"
}

resource "azurerm_lb" "default" {
  name                = "lb-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.default.id
  }
}

##############
### Pool 1 ###
##############

resource "azurerm_lb_backend_address_pool" "pool_001" {
  loadbalancer_id = azurerm_lb.default.id
  name            = "pool-001"

  # Setting both to "null" equals the Azure Portal default behavior
  # I'm not yet sure what it differs from "Automatic" and "Manual"
  virtual_network_id = null
  synchronous_mode   = null
}

resource "azurerm_network_interface_backend_address_pool_association" "vm001" {
  network_interface_id    = var.vm001_network_interface_id
  ip_configuration_name   = var.vm001_nic_ipconfig_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_001.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm002" {
  network_interface_id    = var.vm002_network_interface_id
  ip_configuration_name   = var.vm002_nic_ipconfig_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_001.id
}

##############
### Probes ###
##############

locals {
  http_port = 80
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.default.id
  name            = "http-probe"
  port            = local.http_port
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.default.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = local.http_port
  backend_port                   = local.http_port
  frontend_ip_configuration_name = azurerm_lb.default.frontend_ip_configuration[0].name
  disable_outbound_snat          = true
  probe_id                       = azurerm_lb_probe.http.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool_001.id]
}
