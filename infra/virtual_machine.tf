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

