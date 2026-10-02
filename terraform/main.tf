data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# -------------------------
# Virtual Network
# -------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-runner"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    managed_by = "terraform"
    project    = "self-hosted-runner"
  }
}

# -------------------------
# Subnet
# -------------------------

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-runner"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -------------------------
# Network Security Group
# -------------------------

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-runner"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    managed_by = "terraform"
    project    = "self-hosted-runner"
  }
}

# -------------------------
# NSG <-> Subnet
# -------------------------

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# -------------------------
# Public IP
# -------------------------

resource "azurerm_public_ip" "public_ip" {
  name                = "pip-runner"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    managed_by = "terraform"
    project    = "self-hosted-runner"
  }
}

# -------------------------
# Network Interface
# -------------------------

resource "azurerm_network_interface" "nic" {
  name                = "nic-runner"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    managed_by = "terraform"
    project    = "self-hosted-runner"
  }
}

# -------------------------
# Linux VM
# -------------------------

resource "azurerm_linux_virtual_machine" "runner" {
  name                = var.vm_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  size           = "Standard_D2s_v3"
  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    managed_by = "terraform"
    project    = "self-hosted-runner"
  }
}

# -------------------------
# SSH depuis l'IP du candidat uniquement
# -------------------------

resource "azurerm_network_security_rule" "ssh_candidate" {
  name                       = "Allow-SSH-Candidate"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "${var.allowed_ssh_ip}/32"
  destination_address_prefix = "*"

  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}