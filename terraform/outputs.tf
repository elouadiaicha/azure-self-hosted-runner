output "runner_public_ip" {
  description = "Adresse IP publique de la VM runner"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "runner_vm_name" {
  description = "Nom de la VM runner"
  value       = azurerm_linux_virtual_machine.runner.name
}

output "runner_username" {
  description = "Utilisateur SSH de la VM"
  value       = var.admin_username
}