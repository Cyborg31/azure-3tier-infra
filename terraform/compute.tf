# VM Scale Set for Web Tier
resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "${var.resource_group_name}-web-vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.vm_size
  instances           = var.web_instance_count # This variable now serves as the 'default_capacity'
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
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }
  depends_on = [
    azurerm_key_vault_secret.ssh_public_key,
    azurerm_lb_backend_address_pool.web,
  ]
}

# Auto-scale settings for Web Tier VM Scale Set
resource "azurerm_monitor_autoscale_setting" "web" {
  name                = "${var.resource_group_name}-web-vmss-autoscaler"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web.id
  enabled             = true
  tags                = var.tags

  profile {
    name = "default" # Standard profile name

    capacity {
      minimum = var.web_min_instances    # Minimum instances
      maximum = var.web_max_instances    # Maximum instances
      default = var.web_instance_count   # Default (initial) instances
    }

    # Scale out rule
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web.id
        time_grain         = "PT1M"         # Aggregation time grain (1 minute)
        statistic          = "Average"
        time_window        = "PT5M"         # Lookback time window (5 minutes)
        operator           = "GreaterThanOrEqual"
        threshold          = var.scale_out_cpu_threshold_percent # CPU threshold for scaling out
        time_aggregation   = "Average"
      }
      scale_action {
        type      = "ChangeCount"
        value     = 1 # Increase instance count by 1
        cooldown  = "PT${var.scale_out_cooldown_minutes}M" # Cooldown period
        direction = "Increase" # Specifies the direction of scaling
      }
    }

    # Scale in rule
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "LessThanOrEqual"
        threshold          = var.scale_in_cpu_threshold_percent
        time_aggregation   = "Average"
      }
      scale_action {
        type      = "ChangeCount"
        value     = 1 # Decrease instance count by 1
        cooldown  = "PT${var.scale_in_cooldown_minutes}M" # Cooldown period
        direction = "Decrease" # Specifies the direction of scaling
      }
    }
  }
}


# VM Scale Set for App Tier
resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "${var.resource_group_name}-app-vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.vm_size
  instances           = var.app_instance_count # This variable now serves as the 'default_capacity'
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
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.app.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app.id]
    }
  }
  depends_on = [
    azurerm_key_vault_secret.ssh_public_key,
    azurerm_lb_backend_address_pool.app,
  ]
}

# Auto-scale settings for App Tier VM Scale Set
resource "azurerm_monitor_autoscale_setting" "app" {
  name                = "${var.resource_group_name}-app-vmss-autoscaler"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app.id
  enabled             = true
  tags                = var.tags

  profile {
    name = "default"

    capacity {
      minimum = var.app_min_instances
      maximum = var.app_max_instances
      default = var.app_instance_count
    }

    # Scale out rule
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "GreaterThanOrEqual"
        threshold          = var.scale_out_cpu_threshold_percent
        time_aggregation   = "Average"
      }
      scale_action {
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT${var.scale_out_cooldown_minutes}M"
        direction = "Increase" # Specifies the direction of scaling
      }
    }

    # Scale in rule
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "LessThanOrEqual"
        threshold          = var.scale_in_cpu_threshold_percent
        time_aggregation   = "Average"
      }
      scale_action {
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT${var.scale_in_cooldown_minutes}M"
        direction = "Decrease" # Specifies the direction of scaling
      }
    }
  }
}

# Network Interface for Database VM
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

# Single Linux VM for Database Tier
resource "azurerm_linux_virtual_machine" "db" {
  name                  = "${var.resource_group_name}-db-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
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
  depends_on = [
    azurerm_key_vault_secret.ssh_public_key,
    azurerm_subnet.db,
  ]
}