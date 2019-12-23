provider "azurerm" {
  version = "1.39"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id = "${var.tenant_id}"
  environment = "public"
}

resource "azurerm_resource_group" "rg" {
  location = "${var.location}"
  name = "${var.org_name}-${var.env}-rg"
}

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

resource "azurerm_virtual_machine" "ubuntuvm" {
  location = "${var.location}"
  name = "ubuntu-vm"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
  vm_size = "${var.vm_size}"
  storage_os_disk {
    name              = "vmdist"
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
    admin_username = "${var.admin_username}"
    computer_name = "ubuntu"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${tls_private_key.key.public_key_openssh}"
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }
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

provider "tls" {}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

provider "local" {}

resource "local_file" "private_key" {
  filename = "private_key.pem"
  content = "${tls_private_key.key.private_key_pem}"
}
