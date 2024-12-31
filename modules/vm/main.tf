locals {
  nic_ipconfig_name = "ipconfig${var.vm_number}"
  resource_suffix   = "${var.workload}-${var.vm_number}"
}

resource "azurerm_public_ip" "default" {
  name                = "pip-${local.resource_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "default" {
  name                = "nic-${local.resource_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = local.nic_ipconfig_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "default" {
  name                  = "vm-${local.resource_suffix}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.default.id]
  zone                  = var.vm_zone

  secure_boot_enabled               = true
  vtpm_enabled                      = true
  vm_agent_platform_updates_enabled = false # Seems like Linux will always be false

  custom_data = filebase64("${path.module}/custom_data/ubuntu.sh")

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "osdisk-linux-${local.resource_suffix}"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  lifecycle {
    ignore_changes = [custom_data]
  }
}

resource "azurerm_virtual_machine_extension" "health_extension_tcp" {
  name                       = "HealthExtension"
  virtual_machine_id         = azurerm_linux_virtual_machine.default.id
  publisher                  = "Microsoft.ManagedServices"
  type                       = "ApplicationHealthLinux"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  type_handler_version       = "2.0"

  settings = jsonencode({
    "protocol" : "tcp",
    "port" : 80,
    "intervalInSeconds" : 5,
    "numberOfProbes" : 1
  })
}

# TODO: This request a custom response body
# resource "azurerm_virtual_machine_extension" "health_extension_http" {
#   name                       = "HealthExtension"
#   virtual_machine_id         = azurerm_linux_virtual_machine.default.id
#   publisher                  = "Microsoft.ManagedServices"
#   type                       = "ApplicationHealthLinux"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = true
#   type_handler_version       = "2.0"

#   settings = jsonencode({
#     "protocol" : "http",
#     "port" : 80,
#     "requestPath" : "/",
#     "intervalInSeconds" : 5,
#     "numberOfProbes" : 1
#   })
# }
