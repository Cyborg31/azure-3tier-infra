# Create a static, standard SKU Public IP for the Azure Bastion Host
resource "azurerm_public_ip" "bastion" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"   # Required for Bastion
  sku                 = "Standard" # Required for Bastion
  tags                = var.tags
}

# Create the Azure Bastion Host in the dedicated Bastion subnet
resource "azurerm_bastion_host" "main" {
  name                = "bastion-host"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id # Must be subnet with prefix /26 or larger
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}
