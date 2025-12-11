resource "azurerm_monitor_metric_alert" "netapp_volumeconsumed" {
  for_each            = var.netapp_monitoring.enabled ? { for item in local.netapp_alert_combinations : item.key => item } : {}
  name                = "alr-dev-volumeconsumed${each.value.percentage}-netapp-ai-metric-warn-pcms-${format("%02d", each.value.volume_index)}"
  resource_group_name = var.netapp_monitoring.resource_group_name
  scopes              = [each.value.volume_id]
  description         = "Triggers alert when volume consumed size of ${each.value.volume_name} exceeds ${each.value.percentage}%."
  severity            = each.value.severity_group
  window_size         = "PT1H"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes"
    metric_name      = "VolumeConsumedSizePercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = each.value.percentage
  }

  action {
    action_group_id = var.action_group_id
    webhook_properties = {
      monitor_name    = "AZ_NETAPP_VOLUME_ALMOST_FULL"
      monitor_package = "AZ_BS_ManagedNetAppFiles"
    }
  }

  auto_mitigate = false
}
