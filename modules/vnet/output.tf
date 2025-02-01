output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "subnet_vms_id" {
  value = azurerm_subnet.vms.id
}

output "subnet_nat_id" {
  value = azurerm_subnet.nat.id
}

output "subnet_private_load_balancer_id" {
  value = azurerm_subnet.private_load_balancer.id
}
