# Resource Group
resource "azurerm_resource_group" "nbateams" {
  name     = "nbateams"
  location = "East US"
}

# Hub VNet
resource "azurerm_virtual_network" "atlantahawks" {
  name                = "atlantahawks"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location
  address_space       = ["10.0.0.0/16"]
}

# Lab VNet (Air-Gapped)
resource "azurerm_virtual_network" "brooklynnets" {
  name                = "brooklynnets"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location
  address_space       = ["10.1.0.0/16"]
}

# Subnets - Hub
resource "azurerm_subnet" "management" {
  name                 = "ManagementSubnet"
  resource_group_name  = azurerm_resource_group.nbateams.name
  virtual_network_name = azurerm_virtual_network.atlantahawks.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.nbateams.name
  virtual_network_name = azurerm_virtual_network.atlantahawks.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Subnet - Lab
resource "azurerm_subnet" "lab" {
  name                 = "LabSubnet"
  resource_group_name  = azurerm_resource_group.nbateams.name
  virtual_network_name = azurerm_virtual_network.brooklynnets.name
  address_prefixes     = ["10.1.1.0/24"]
}

# VNet Peering Bidirectional
resource "azurerm_virtual_network_peering" "hub_to_lab" {
  name                      = "hub-to-lab"
  resource_group_name       = azurerm_resource_group.nbateams.name
  virtual_network_name      = azurerm_virtual_network.atlantahawks.name
  remote_virtual_network_id = azurerm_virtual_network.brooklynnets.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "lab_to_hub" {
  name                      = "lab-to-hub"
  resource_group_name       = azurerm_resource_group.nbateams.name
  virtual_network_name      = azurerm_virtual_network.brooklynnets.name
  remote_virtual_network_id = azurerm_virtual_network.atlantahawks.id
  allow_virtual_network_access = true
}


# Air-Gap NSG
resource "azurerm_network_security_group" "airgap_nsg" {
  name                = "airgap-nsg"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location

  security_rule {
    name                       = "AllowLabInternal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.0.0/16"
    destination_address_prefix = "10.1.0.0/16"
  }

  security_rule {
    name                       = "AllowAzureMonitor"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"
  }

  security_rule {
    name                       = "DenyInternetOutbound"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Associate NSG to Lab Subnet
resource "azurerm_subnet_network_security_group_association" "lab_nsg" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.airgap_nsg.id
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "clevelandcavs" {
  name                = "clevelandcavs"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Microsoft Sentinel
resource "azurerm_log_analytics_solution" "sentinel" {
  solution_name         = "SecurityInsights"
  resource_group_name   = azurerm_resource_group.nbateams.name
  location              = azurerm_resource_group.nbateams.location
  workspace_resource_id = azurerm_log_analytics_workspace.clevelandcavs.id
  workspace_name        = azurerm_log_analytics_workspace.clevelandcavs.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}


# Public IP for Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "houstonrockets-pip"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Bastion
resource "azurerm_bastion_host" "houstonrockets" {
  name                = "houstonrockets"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location
  sku                 = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

# NIC for chicagobulls
resource "azurerm_network_interface" "chicagobulls_nic" {
  name                = "chicagobulls-nic"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NIC for detroitpistons-vm1
resource "azurerm_network_interface" "vm1_nic" {
  name                = "detroitpistons-vm1-nic"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NIC for detroitpistons-vm2
resource "azurerm_network_interface" "vm2_nic" {
  name                = "detroitpistons-vm2-nic"
  resource_group_name = azurerm_resource_group.nbateams.name
  location            = azurerm_resource_group.nbateams.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Nessus Scanner VM (Ubuntu)
resource "azurerm_linux_virtual_machine" "chicagobulls" {
  name                  = "chicagobulls"
  resource_group_name   = azurerm_resource_group.nbateams.name
  location              = azurerm_resource_group.nbateams.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.chicagobulls_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Linux Target VM
resource "azurerm_linux_virtual_machine" "detroitpistons_vm1" {
  name                  = "detroitpistons-vm1"
  resource_group_name   = azurerm_resource_group.nbateams.name
  location              = azurerm_resource_group.nbateams.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm1_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Windows Target VM
resource "azurerm_windows_virtual_machine" "detroitpistons_vm2" {
  name                  = "detroitpistons-vm2"
  computer_name         = "pistons-vm2"
  resource_group_name   = azurerm_resource_group.nbateams.name
  location              = azurerm_resource_group.nbateams.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"
  admin_password        = "REMOVED_PASSWORD_PLACEHOLDER"
  network_interface_ids = [azurerm_network_interface.vm2_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
