resource "random_password" "vm_password" {
  length           = 16
  special          = true
  upper            = true
  numeric          = true
  override_special = "-!(@#%"
}

# resource "random_password" "vm_password" {
#   length  = 24
#   special = true
#   upper   = true
#   numeric = true
# }


resource "azurerm_public_ip" "pip" {
  name                = "web-pip1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "web-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-configuration"
    subnet_id                     = element(module.network.vnet_subnets, 1)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "web-vm"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  disable_password_authentication = false
  admin_password                  = random_password.vm_password.result
  network_interface_ids           = [azurerm_network_interface.nic.id]

  os_disk {
    name                 = "os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ansible",
      # "ansible-playbook -i localhost, Ansible/apache_install.yaml"
    ]

    connection {
      type     = "ssh"
      host     = azurerm_public_ip.pip.ip_address
      user     = "adminuser"
      password = random_password.vm_password.result
      agent    = false
    }
  }
}

# Run Ansible


resource "null_resource" "ansible_provisioning" {
  provisioner "local-exec" {
    command = <<-EOT
      pwd;
      ls -la;
      ansible-playbook -i "${azurerm_public_ip.pip.ip_address}," -u "${azurerm_linux_virtual_machine.vm.admin_username}" --extra-vars "ansible_ssh_pass=${random_password.vm_password.result}" "${path.root}/Ansible/apache_install.yaml"
    EOT
    # working_dir = path.module
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  depends_on = [azurerm_linux_virtual_machine.vm]
}


resource "azurerm_public_ip" "pip2" {
  name                = "lb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_lb" "lb2" {
  name                = "web-load-balancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip2.id
  }
}


resource "azurerm_lb_backend_address_pool" "lbpool" {
  name            = "my-lb-backend-pool"
  loadbalancer_id = azurerm_lb.lb2.id
}

resource "azurerm_lb_probe" "lbprobe" {
  name            = "my-lb-probe"
  loadbalancer_id = azurerm_lb.lb2.id
  protocol        = "Tcp"
  port            = 8080
}

resource "azurerm_lb_rule" "lbrule" {
  name                           = "my-lb-rule"
  loadbalancer_id                = azurerm_lb.lb2.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_port                   = 8080
  # backend_address_pool_id        = azurerm_lb_backend_address_pool.lbpool.id
  probe_id = azurerm_lb_probe.lbprobe.id
}

