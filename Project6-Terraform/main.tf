# Resource Group
resource "azurerm_resource_group" "nba_rg" {
  name     = "nba-network-tf"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "nba_vnet" {
  name                = "NBA-VNET-tf"
  resource_group_name = azurerm_resource_group.nba_rg.name
  location            = azurerm_resource_group.nba_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Web Subnet
resource "azurerm_subnet" "web_subnet" {
  name                 = "WebSubnet"
  resource_group_name  = azurerm_resource_group.nba_rg.name
  virtual_network_name = azurerm_virtual_network.nba_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Bastion Subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.nba_rg.name
  virtual_network_name = azurerm_virtual_network.nba_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nba_nsg" {
  name                = "nba-nsg-tf"
  resource_group_name = azurerm_resource_group.nba_rg.name
  location            = azurerm_resource_group.nba_rg.location

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
  }
}

# Associate NSG to WebSubnet
resource "azurerm_subnet_network_security_group_association" "web_nsg" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.nba_nsg.id
}

# Availability Set
resource "azurerm_availability_set" "nba_avset" {
  name                         = "nba-availability-set-tf"
  resource_group_name          = azurerm_resource_group.nba_rg.name
  location                     = azurerm_resource_group.nba_rg.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}

# Network Interfaces
resource "azurerm_network_interface" "vm1_nic" {
  name                = "nbasports-vm1-nic"
  resource_group_name = azurerm_resource_group.nba_rg.name
  location            = azurerm_resource_group.nba_rg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "vm2_nic" {
  name                = "nbasports-vm2-nic"
  resource_group_name = azurerm_resource_group.nba_rg.name
  location            = azurerm_resource_group.nba_rg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "vm1" {
  name                  = "nbasports-vm1"
  resource_group_name   = azurerm_resource_group.nba_rg.name
  location              = azurerm_resource_group.nba_rg.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"
  availability_set_id   = azurerm_availability_set.nba_avset.id
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

resource "azurerm_linux_virtual_machine" "vm2" {
  name                  = "nbasports-vm2"
  resource_group_name   = azurerm_resource_group.nba_rg.name
  location              = azurerm_resource_group.nba_rg.location
  size                  = "Standard_D2s_v3"
  admin_username        = "azureuser"
  availability_set_id   = azurerm_availability_set.nba_avset.id
  network_interface_ids = [azurerm_network_interface.vm2_nic.id]

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

resource "azurerm_public_ip" "lb_pip" {
  name                = "nba-lb-pip-tf"
  resource_group_name = azurerm_resource_group.nba_rg.name
  location            = azurerm_resource_group.nba_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "nba_lb" {
  name                = "nba-load-balancer-tf"
  resource_group_name = azurerm_resource_group.nba_rg.name
  location            = azurerm_resource_group.nba_rg.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "nba-frontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "nba_backend" {
  name            = "nba-backend-pool"
  loadbalancer_id = azurerm_lb.nba_lb.id
}

resource "azurerm_lb_probe" "nba_probe" {
  name            = "nba-health-probe"
  loadbalancer_id = azurerm_lb.nba_lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "nba_lb_rule" {
  name                           = "nba-lb-rule"
  loadbalancer_id                = azurerm_lb.nba_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "nba-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.nba_backend.id]
  probe_id                       = azurerm_lb_probe.nba_probe.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm1_lb" {
  network_interface_id    = azurerm_network_interface.vm1_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.nba_backend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm2_lb" {
  network_interface_id    = azurerm_network_interface.vm2_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.nba_backend.id
}
