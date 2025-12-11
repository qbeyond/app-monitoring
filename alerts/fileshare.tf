resource "azurerm_monitor_metric_alert" "fileshare_volumeconsumed" {
  for_each            = var.fileshare_monitoring.enabled ? { for item in local.fileshare_alert_combinations : item.key => item } : {}
  name                = "alr-dev-volumeconsumed${each.value.percentage}-fileshare-ai-metric-warn-pcms-${format("%02d", each.value.share_index)}"
  resource_group_name = var.fileshare_monitoring.resource_group_name
  scopes              = ["${var.fileshare_monitoring.storage_account_id}/fileServices/default"]
  description         = "Triggers alert when volume consumed size of ${each.value.share_name} exceeds ${each.value.percentage}%."
  severity            = each.value.severity_group
  window_size         = "PT1H"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
    metric_name      = "FileCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.fileshare_monitoring.share_quota * 1073741824 * each.value.threshold_mult

    dimension {
      name     = "FileShare"
      operator = "Include"
      values   = [each.value.share_name]
    }
  }

  action {
    action_group_id = var.action_group_id
    webhook_properties = {
      monitor_name    = "AZ_FILESHARE_ALMOST_FULL"
      monitor_package = "AZ_BS_ManagedSMBFileservice"
    }
  }

  auto_mitigate = false
}
