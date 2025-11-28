locals {
  alert_thresholds = {
    80 = 0.8
    95 = 0.95
  }

  alert_combinations = flatten([
    for idx, share_name in var.file_share_names : [
      for percentage, threshold_multiplier in local.alert_thresholds : {
        key            = "${idx + 1}-${percentage}"
        share_index    = idx + 1
        share_name     = share_name
        percentage     = percentage
        threshold_mult = threshold_multiplier
      }
    ]
  ])
}

resource "azurerm_monitor_metric_alert" "volumeconsumed" {
  for_each            = { for item in local.alert_combinations : item.key => item }
  name                = "alr-dev-volumeconsumed${each.value.percentage}-fileshare-ai-metric-warn-pcms-${format("%02d", each.value.share_index)}"
  resource_group_name = azurerm_resource_group.filealert.name
  scopes              = ["${var.storage_account_id}/fileServices/default"]
  description         = "Triggers alert when volume consumed size of ${each.value.share_name} exceeds ${each.value.percentage}%."
  severity            = 2
  window_size         = "PT1H"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
    metric_name      = "FileCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = local.shareQuota * 1073741824 * each.value.threshold_mult

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
