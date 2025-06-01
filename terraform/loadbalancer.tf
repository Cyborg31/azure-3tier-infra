# Public IP for the Web Load Balancer
resource "azurerm_public_ip" "web" {
  name                = "${var.resource_group_name}-web-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Public Load Balancer for Web Tier
resource "azurerm_lb" "web" {
  name                = var.public_lb_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.web.id
  }
  depends_on = [
    azurerm_public_ip.web
  ]
}

# Backend Address Pool for Web Load Balancer
resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "WebBackendPool"
}

# Health Probe for Web Load Balancer (HTTP on port 80)
resource "azurerm_lb_probe" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "HTTP-Probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# Load Balancer Rule for Web Traffic (port 80)
resource "azurerm_lb_rule" "web" {
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.web.id
}

# Internal Load Balancer for App Tier
resource "azurerm_lb" "app" {
  name                = var.internal_lb_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "InternalIPAddress"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Backend Address Pool for App Load Balancer
resource "azurerm_lb_backend_address_pool" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "AppBackendPool"
}

# Health Probe for App Load Balancer (TCP on port 8080)
resource "azurerm_lb_probe" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "TCP-Probe"
  protocol        = "Tcp"
  port            = 8080
}

# Load Balancer Rule for App Traffic (port 8080)
resource "azurerm_lb_rule" "app" {
  loadbalancer_id                = azurerm_lb.app.id
  name                           = "AppPort"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "InternalIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}
