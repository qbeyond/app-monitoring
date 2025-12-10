locals {
  tags = {
    alerting = "replace"
    test     = "test"
  }

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
