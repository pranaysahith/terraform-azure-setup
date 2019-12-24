resource "azurerm_virtual_network" "vnet" {
  address_space = ["10.0.0.0/16"]
  location = "${var.location}"
  name = "${var.org_name}-${var.env}-vnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  address_prefix = "10.0.0.0/24"
  name = "${var.org_name}-${var.env}-snet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
}

resource "azurerm_network_interface" "nic" {
  location = "${var.location}"
  name = "${var.org_name}-${var.env}-nic"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  ip_configuration {
    name = "ubuntu-vm-ip"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.public_ip.id}"
    subnet_id = "${azurerm_subnet.subnet.id}"
  }
}

resource "azurerm_public_ip" "public_ip" {
  location = "${var.location}"
  name = "ubuntu-ip"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method = "Dynamic"
}
