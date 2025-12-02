variable "action_group_id" {
  description = "ID of the action group."
  type        = string
}

variable "fileshare_monitoring" {
  description = "Configuration for file share monitoring alerts."
  type = object({
    enabled              = bool
    storage_account_name = string
    storage_account_id   = string
    share_names          = list(string)
    share_quota          = number
    thresholds           = list(number)
  })
  default = {
    enabled              = false
    storage_account_name = ""
    storage_account_id   = ""
    share_names          = []
    share_quota          = 100 # in GiB
    thresholds           = []
  }
}

variable "netapp_monitoring" {
  description = "Configuration for NetApp Files monitoring alerts."
  type = object({
    enabled = bool
    netapp_volumes = list(object({
      volume_id    = string
      volume_name  = string
      volume_quota = number # in GiB
    }))
    thresholds = list(number)
  })
  default = {
    enabled        = false
    netapp_volumes = []
    thresholds     = []
  }
}
