locals {
  # Fileshare alert combinations
  fileshare_thresholds = {
    for threshold in var.fileshare_monitoring.thresholds :
    threshold => threshold / 100
  }

  fileshare_alert_combinations = flatten([
    for idx, share_name in var.fileshare_monitoring.share_names : [
      for percentage, threshold_multiplier in local.fileshare_thresholds : {
        key            = "${idx + 1}-${percentage}"
        share_index    = idx + 1
        share_name     = share_name
        percentage     = percentage
        threshold_mult = threshold_multiplier
      }
    ]
  ])

  # NetApp alert combinations
  netapp_thresholds = {
    for threshold in var.netapp_monitoring.thresholds :
    threshold => threshold / 100
  }

  netapp_alert_combinations = flatten([
    for idx, volume in var.netapp_monitoring.netapp_volumes : [
      for percentage, threshold_multiplier in local.netapp_thresholds : {
        key            = "${idx + 1}-${percentage}"
        volume_index   = idx + 1
        volume_id      = volume.volume_id
        volume_name    = volume.volume_name
        volume_quota   = volume.volume_quota
        percentage     = percentage
        threshold_mult = threshold_multiplier
      }
    ]
  ])
}

# ----------------------------------------------------------
# Fileshare Metric Alerts
# ----------------------------------------------------------
resource "azurerm_monitor_metric_alert" "fileshare_volumeconsumed" {
  for_each            = var.fileshare_monitoring.enabled ? { for item in local.fileshare_alert_combinations : item.key => item } : {}
  name                = "alr-dev-volumeconsumed${each.value.percentage}-fileshare-ai-metric-warn-pcms-${format("%02d", each.value.share_index)}"
  resource_group_name = var.fileshare_monitoring.resource_group_name
  scopes              = ["${var.fileshare_monitoring.storage_account_id}/fileServices/default"]
  description         = "Triggers alert when volume consumed size of ${each.value.share_name} exceeds ${each.value.percentage}%."
  severity            = 2
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

# ----------------------------------------------------------
# NetApp Volume Metric Alerts
# ----------------------------------------------------------
resource "azurerm_monitor_metric_alert" "netapp_volumeconsumed" {
  for_each            = var.netapp_monitoring.enabled ? { for item in local.netapp_alert_combinations : item.key => item } : {}
  name                = "alr-dev-volumeconsumed${each.value.percentage}-netapp-ai-metric-warn-pcms-${format("%02d", each.value.volume_index)}"
  resource_group_name = var.netapp_monitoring.resource_group_name
  scopes              = [each.value.volume_id]
  description         = "Triggers alert when volume consumed size of ${each.value.volume_name} exceeds ${each.value.percentage}%."
  severity            = 2
  window_size         = "PT1H"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes"
    metric_name      = "VolumeConsumedSizePercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = each.value.percentage # VolumeConsumedSizePercentage is already in percent
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
