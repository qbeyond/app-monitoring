# resource "azurerm_resource_group" "filealert" {
#   count    = var.fileshare_monitoring.enabled ? 1 : 0
#   location = "westeurope"
#   name     = "rg-filealert-dev-01"
#   tags     = local.tags
# }

# resource "azurerm_storage_account" "filealert" {
#   name                     = var.fileshare_monitoring.storage_account_name
#   resource_group_name      = azurerm_resource_group.filealert.name
#   location                 = azurerm_resource_group.filealert.location
#   account_tier             = "Premium"
#   account_kind             = "FileStorage"
#   account_replication_type = "ZRS"

#   public_network_access_enabled   = true
#   allow_nested_items_to_be_public = false
#   shared_access_key_enabled       = false
#   default_to_oauth_authentication = true

#   large_file_share_enabled = true # There doesn't seem to be any downside

#   tags = local.tags
# }

# # ----------------------------------------------------------
# # Fileshare via AzAPI (AAD-auth, no key)
# # ----------------------------------------------------------
# resource "azapi_resource" "premium_fileshare" {
#   for_each  = var.fileshare_monitoring.enabled ? toset(var.fileshare_monitoring.share_names) : toset([])
#   type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01"
#   name      = each.value
#   parent_id = "${azurerm_storage_account.filealert.id}/fileServices/default"

#   body = {
#     properties = {
#       accessTier       = "Premium"
#       enabledProtocols = "SMB"
#       shareQuota       = var.fileshare_monitoring.share_quota
#     }
#   }
# }
