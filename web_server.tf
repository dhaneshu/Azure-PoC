# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "_%@"
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "web-pip1"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "nic" {
#   name                = "web-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "nic-configuration"
#     subnet_id                     = element(module.network.vnet_subnets, 1)
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#   }
# }

# resource "azurerm_linux_virtual_machine" "vm" {
#   name                  = "my-vm"
#   location              = azurerm_resource_group.example.location
#   resource_group_name   = azurerm_resource_group.example.name
#   size                  = "Standard_DS1_v2"
#   admin_username        = "adminuser"
#   admin_password        = random_password.password.result
#   network_interface_ids = [azurerm_network_interface.example.id]

#   os_disk {
#     name                 = "my-os-disk"
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "20.04-LTS"
#     version   = "latest"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get install -y ansible",
#       "ansible-playbook -i localhost, Ansible/apache_install.yml"
#     ]

#     connection {
#       type     = "ssh"
#       host     = azurerm_public_ip.example.ip_address
#       user     = "adminuser"
#       password = random_password.password.result
#       agent    = false
#     }
#   }
# }


# resource "azurerm_lb" "example" {
#   name                = "my-load-balancer"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   sku                 = "Standard"

#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.example.id
#   }
# }

# # resource "azurerm_lb_backend_address_pool" "example" {
# #   name                = "my-lb-backend-pool"
# #   resource_group_name = azurerm_resource_group.example.name
# #   loadbalancer_id     = azurerm_lb.example.id
# # }

# # resource "azurerm_lb_probe" "example" {
# #   name                = "my-lb-probe"
# #   resource_group_name = azurerm_resource_group.example.name
# #   loadbalancer_id     = azurerm_lb.example.id
# #   protocol            = "Tcp"
# #   port                = 8080
# # }

# # resource "azurerm_lb_rule" "example" {
# #   name                    = "my-lb-rule"
# #   resource_group_name     = azurerm_resource_group.example.name
# #   loadbalancer_id         = azurerm_lb.example.id
# #   protocol                = "Tcp"
# #   frontend_port           = 80
# #   backend_port            = 8080
# #   backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
# #   probe_id                = azurerm_lb_probe.example.id
# # }

