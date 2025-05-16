resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "web-vmss"
  resource_group_name  = azurerm_resource_group.main.name
  location            = var.location
  sku                 = var.vm_size
  instances           = var.web_instance_count
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  upgrade_mode       = "Automatic"
  overprovision      = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "web-nic"
    primary = true

    ip_configuration {
      name                                   = "web-ipconfig"
      subnet_id                              = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_backend_pool.id]
      primary                               = true
      # Removed public_ip_address_configuration block here
    }
  }

  tags = {
    environment = "production"
    tier        = "web"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "app-vmss"
  resource_group_name  = azurerm_resource_group.main.name
  location            = var.location
  sku                 = var.vm_size
  instances           = var.app_instance_count
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  upgrade_mode       = "Automatic"
  overprovision      = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "app-nic"
    primary = true

    ip_configuration {
      name                                   = "app-ipconfig"
      subnet_id                              = azurerm_subnet.app.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app_backend_pool.id]
      primary                               = true
    }
  }

  tags = {
    environment = "production"
    tier        = "app"
  }
}

resource "azurerm_network_interface" "db_nic" {
  name                = "db-nic"
  location            = var.location
  resource_group_name  = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "db-ipconfig"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = "db-vm"
  resource_group_name  = azurerm_resource_group.main.name
  location            = var.location
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.db_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "production"
    tier        = "db"
  }
}
