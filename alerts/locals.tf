locals {
  tags = {
    alerting = "replace"
    test     = "test"
  }

  fileshare_thresholds = {
    for threshold_str, severity_group in var.fileshare_monitoring.thresholds :
    threshold_str => {
      threshold_value    = tonumber(threshold_str) / 100
      severity_group     = severity_group
    }
  }

  fileshare_alert_combinations = flatten([
    for idx, share_name in var.fileshare_monitoring.share_names : [
      for threshold_str, threshold_data in local.fileshare_thresholds : {
        key            = "${idx + 1}-${threshold_str}"
        share_index    = idx + 1
        share_name     = share_name
        percentage     = tonumber(threshold_str)
        threshold_mult = threshold_data.threshold_value
        severity_group = threshold_data.severity_group != null ? threshold_data.severity_group : var.fileshare_monitoring.default_severity
      }
    ]
  ])

  netapp_thresholds = {
    for threshold_str, severity_group in var.netapp_monitoring.thresholds :
    threshold_str => {
      threshold_value    = tonumber(threshold_str)
      severity_group     = severity_group
    }
  }

  netapp_alert_combinations = flatten([
    for idx, volume in var.netapp_monitoring.netapp_volumes : [
      for threshold_str, threshold_data in local.netapp_thresholds : {
        key            = "${idx + 1}-${threshold_str}"
        volume_index   = idx + 1
        volume_id      = volume.volume_id
        volume_name    = volume.volume_name
        volume_quota   = volume.volume_quota
        percentage     = tonumber(threshold_str)
        threshold_mult = threshold_data.threshold_value
        severity_group = threshold_data.severity_group != null ? threshold_data.severity_group : var.netapp_monitoring.default_severity
      }
    ]
  ])
}
