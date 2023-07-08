resource "random_password" "vmss_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = local.vmss_input["name"]
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  upgrade_mode                    = "Manual"
  sku                             = local.vmss_input["sku"]
  instances                       = 2
  admin_username                  = "adminuser"
  disable_password_authentication = false
  admin_password                  = random_password.vmss_password.result


  network_interface {
    name    = "VMSSNetworkProfile"
    primary = true

    ip_configuration {
      name      = "VMSSIPConfiguration"
      primary   = true
      subnet_id = element(module.network.vnet_subnets, 0)
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [instances]
  }
}

resource "azurerm_monitor_autoscale_setting" "vmss" {
  name                = "vmssAutoscaleSetting"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  predictive {
    scale_mode      = "Enabled"
    look_ahead_time = "PT5M"
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["admin@contoso.com"]
    }
  }
}
