resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "${var.resource_group_name}-web-vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.vm_size
  instances           = var.web_instance_count
  admin_username      = var.admin_username
  tags                = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = azurerm_key_vault_secret.ssh_public_key.value
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
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
      name                                    = "internal"
      primary                                 = true
      subnet_id                               = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids  = [azurerm_lb_backend_address_pool.web.id]
    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "${var.resource_group_name}-app-vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.vm_size
  instances           = var.app_instance_count
  admin_username      = var.admin_username
  tags                = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = azurerm_key_vault_secret.ssh_public_key.value
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
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
      name                                    = "internal"
      primary                                 = true
      subnet_id                               = azurerm_subnet.app.id
      load_balancer_backend_address_pool_ids  = [azurerm_lb_backend_address_pool.app.id]
    }
  }
}

resource "azurerm_network_interface" "db" {
  name                = "${var.resource_group_name}-db-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db" {
  name                = "${var.resource_group_name}-db-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.db.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = azurerm_key_vault_secret.ssh_public_key.value
  }

  disable_password_authentication = true

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

  tags = var.tags
}