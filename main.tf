terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}
provider "azurerm"  {
    features {}
}
resource "azurerm_resource_group" "rg1" {
    name     = "ERP-ResourceGroup"
    location = "East US"
}
resource "azurerm_virtual_network" "vnet1" {
    name                = "vnet1"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name
}
resource "azurerm_subnet" "vnet1subnet1" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.rg1.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_interface" "vm1nic" {
    name                = "vm1-nic"
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.vnet1subnet1.id
        private_ip_address_allocation = "Dynamic"
    }
}
resource "azurerm_virtual_machine" "vm1" {
    name                  = "vm1"
    location              = azurerm_resource_group.rg1.location
    resource_group_name   = azurerm_resource_group.rg1.name
    network_interface_ids = [azurerm_network_interface.vm1nic.id]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "osdisk-vm1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "vm1"
        admin_username = "adminuser"
        admin_password = "P@ssw0rd1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
  
}
