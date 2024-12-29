output "lb_public_ip_address" {
  value = module.load_balancer.public_ip_address
}

output "vm001_ssh_connect_command" {
  value = "ssh -i .keys/temp_rsa ${var.vm_admin_username}@${module.vm001.public_ip_address}"
}

output "vm002_ssh_connect_command" {
  value = "ssh -i .keys/temp_rsa ${var.vm_admin_username}@${module.vm002.public_ip_address}"
}
