variable "action_group_id" {
  description = "ID of the action group."
  type        = string
}

variable "tags" {
  description = "Tags that will be assigned to all resources."
  type        = map(string)
  default     = {}
}

variable "storage_account_id" {
  description = "ID of the storage account."
  type        = string
}

variable "file_share_names" {
  description = "List of file share names for which alert rules will be created."
  type        = list(string)
  default     = [null]
}

variable "file_monitoring" {
  description = "Enable or disable file share monitoring."
  type        = bool
  default     = false
}

variable "shareQuota" {
  description = "Quota for each file share in GiB."
  type        = number
  default     = 100
}

variable "thresholds" {
  description = "Threshold percentages for alerts."
  type        = list(number)
  default     = [80]
}
