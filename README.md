# Module
[![GitHub tag](https://img.shields.io/github/tag/qbeyond/terraform-module-template.svg)](https://registry.terraform.io/modules/qbeyond/terraform-module-template/provider/latest)
[![License](https://img.shields.io/github/license/qbeyond/terraform-module-template.svg)](https://github.com/qbeyond/terraform-module-template/blob/main/LICENSE)

----

This is a template module. It just showcases how a module should look. This would be a short description of the module.

<!-- BEGIN_TF_DOCS -->
## Usage

It's very easy to use!
```hcl
provider "azurerm" {
  features {

  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----|
| <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id) | ID of the Action Group used to notify on alert. | `string` | n/a | yes |
| <a name="input_fileshare_monitoring"></a> [fileshare\_monitoring](#input\_fileshare\_monitoring) | File share alert configuration. | `object` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account for file shares. Must be 3-24 characters, lowercase letters and numbers only. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to created resources. | `map(string)` | `{}` | no |

## Outputs

No outputs.
## Resource types

          No resources.
      
    
## Modules

No modules.
## Resources by Files

            No resources.
        
    
<!-- END_TF_DOCS -->

## Contribute

Please use Pull requests to contribute.

When a new Feature or Fix is ready to be released, create a new Github release and adhere to [Semantic Versioning 2.0.0](https://semver.org/lang/de/spec/v2.0.0.html).

# app-monitoring

Terraform module to create Azure Monitor Metric Alerts for Storage Account file shares and NetApp volumes.

## Features

- **File Share Monitoring**: Creates metric alerts for Azure Storage file shares based on percentage thresholds.
- **NetApp Monitoring**: Creates metric alerts for Azure NetApp Files volumes based on percentage thresholds.
- Conditional resource creation via `enabled` flag in each monitoring object.

## Quick Usage

```hcl
module "app_monitoring" {
  source = "./"

  action_group_id = "/subscriptions/.../resourceGroups/rg/providers/Microsoft.Insights/actionGroups/ag-example"
  
  tags = {
    environment = "dev"
  }

  fileshare_monitoring = {
    enabled              = true
    storage_account_name = "stgenpcmsalert01"
    storage_account_id   = "/subscriptions/.../resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/stgenpcmsalert01"
    share_names          = ["share01", "share02"]
    share_quota          = 100
    thresholds           = [80, 95]
  }

  netapp_monitoring = {
    enabled = true
    netapp_volumes = [
      {
        volume_id    = "/subscriptions/.../resourceGroups/rg/providers/Microsoft.NetApp/netAppAccounts/acc/capacityPools/pool/volumes/vol1"
        volume_name  = "vol1"
        volume_quota = 500
      }
    ]
    thresholds = [80, 95]
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| action_group_id | ID of the Action Group for notifications | `string` | yes |
| tags | Tags to assign to resources | `map(string)` | no |
| fileshare_monitoring | File share monitoring configuration | `object` | no |
| netapp_monitoring | NetApp volume monitoring configuration | `object` | no |

### fileshare_monitoring object

| Attribute | Description | Type |
|-----------|-------------|------|
| enabled | Enable/disable fileshare monitoring | `bool` |
| storage_account_name | Name for the storage account (3-24 chars, lowercase alphanumeric) | `string` |
| storage_account_id | Resource ID of the storage account (for alert scope) | `string` |
| share_names | List of file share names to monitor | `list(string)` |
| share_quota | Quota per share in GiB | `number` |
| thresholds | Alert trigger percentages (e.g., [80, 95]) | `list(number)` |

### netapp_monitoring object

| Attribute | Description | Type |
|-----------|-------------|------|
| enabled | Enable/disable NetApp monitoring | `bool` |
| netapp_volumes | List of volumes to monitor | `list(object)` |
| thresholds | Alert trigger percentages (e.g., [80, 95]) | `list(number)` |

Each `netapp_volumes` entry:
| Attribute | Description | Type |
|-----------|-------------|------|
| volume_id | Full resource ID of the NetApp volume | `string` |
| volume_name | Display name for the volume | `string` |
| volume_quota | Volume quota in GiB | `number` |

## Resources Created

- `azurerm_resource_group.filealert` (when fileshare enabled)
- `azurerm_storage_account.filealert` (when fileshare enabled)
- `azapi_resource.premium_fileshare` (per share name)
- `azurerm_monitor_metric_alert.fileshare_volumeconsumed` (per share × threshold)
- `azurerm_monitor_metric_alert.netapp_volumeconsumed` (per volume × threshold)

## Contribute

Use pull requests. Follow semantic versioning for releases.