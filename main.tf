data "azurerm_subscription" "current" {
}

module "alerts" {
  source = "./alerts"

  action_group_id      = var.action_group_id
  fileshare_monitoring = var.fileshare_monitoring
  netapp_monitoring    = var.netapp_monitoring
}
