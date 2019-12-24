resource "azurerm_network_security_group" "sg" {
  location = "${var.location}"
  name = "${var.org_name}-${var.env}-sg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "srule" {
  access = "allow"
  direction = "Inbound"
  name = "ssh"
  network_security_group_name = "${azurerm_network_security_group.sg.name}"
  priority = 100
  protocol = "tcp"
  source_port_range = "22"
  destination_port_range = "22"
  source_address_prefixes = ["0.0.0.0"]
  destination_address_prefixes = ["0.0.0.0"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet_network_security_group_association" "subnet_sg" {
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  subnet_id = "${azurerm_subnet.subnet.id}"
}