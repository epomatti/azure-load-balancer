output "lb_public_ip_address" {
  value = module.load_balancer.public_ip_address
}

output "vm_ssh_connect_command" {
  value = "ssh -i .keys/temp_rsa ${var.vm_admin_username}@${module.vm.public_ip_address}"
}