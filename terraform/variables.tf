variable "resource_group_name" {
  description = "Resource Group Azure existant"
  type        = string
  default     = "aelouadiRG"
}

variable "location" {
  description = "Region Azure"
  type        = string
  default     = "francecentral"
}

variable "vm_name" {
  description = "Nom de la VM du runner"
  type        = string
  default     = "vm-github-runner"
}

variable "admin_username" {
  description = "Utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "allowed_ssh_ip" {
  description = "Adresse IP publique autorisee a se connecter en SSH"
  type        = string
}