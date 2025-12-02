variable "action_group_id" {
  description = "ID of the action group."
  type        = string
}

variable "fileshare_monitoring" {
  description = "Configuration for file share monitoring alerts."
  type = object({
    enabled            = bool
    storage_account_id = string
    share_names        = list(string)
    share_quota        = number
    thresholds         = list(number)
  })
  default = {
    enabled            = false
    storage_account_id = ""
    share_names        = []
    share_quota        = 100 # in GiB
    thresholds         = []
  }
}

variable "NetApp_monitoring" {
  description = "Configuration for NetApp monitoring alerts."
  type = object({
    enabled           = bool
    netapp_account_id = string
    volume_names      = list(string)
    volume_quota      = number
    thresholds        = list(number)
  })
  default = {
    enabled           = false
    netapp_account_id = ""
    volume_names      = []
    volume_quota      = 100 # in GiB
    thresholds        = []
  }
}
