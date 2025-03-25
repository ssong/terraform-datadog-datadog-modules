# Datadog DynamoDB Monitors Terraform Module

This Terraform module creates a set of Datadog monitors for AWS DynamoDB tables. The monitors are configured based on the criticality level provided (low, medium, high).

## Monitors Created

1. **Read Throttle Events Monitor**: Alerts when the DynamoDB table experiences read throttling
2. **Write Throttle Events Monitor**: Alerts when the DynamoDB table experiences write throttling
3. **Consumed Read Capacity Monitor** (only for provisioned capacity): Alerts when read capacity consumption approaches provisioned limits
4. **Consumed Write Capacity Monitor** (only for provisioned capacity): Alerts when write capacity consumption approaches provisioned limits
5. **System Errors Monitor**: Alerts when the DynamoDB table experiences system errors
6. **Conditional Check Failed Monitor**: Alerts when there's a high rate of failed conditional checks

## Usage

```hcl
# For a DynamoDB table with on-demand capacity
module "dynamodb_ondemand_monitors" {
  source = "path/to/datadog_dynamodb_monitors"

  table_name          = "my-dynamodb-table"
  criticality         = "high"  # Options: low, medium, high
  notification_target = "@slack-channel @pagerduty-service"
  tags                = ["service:users", "team:platform"]
}

# For a DynamoDB table with provisioned capacity
module "dynamodb_provisioned_monitors" {
  source = "path/to/datadog_dynamodb_monitors"

  table_name           = "my-provisioned-table"
  criticality          = "medium"  # Options: low, medium, high
  notification_target  = "@slack-channel @pagerduty-service"
  provisioned_capacity = true
  read_capacity_units  = 20
  write_capacity_units = 10
  tags                 = ["service:payments", "team:platform"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| table_name | The name of the AWS DynamoDB table to monitor | string | n/a | yes |
| criticality | The criticality level of the DynamoDB table (low, medium, high) | string | n/a | yes |
| prefix | Prefix to add to the monitor names | string | "[DynamoDB] " | no |
| notification_target | The target for alert notifications (e.g., @slack-channel, @pagerduty, @email) | string | n/a | yes |
| tags | Additional tags to add to the monitors | list(string) | [] | no |
| evaluation_period | The evaluation period for the monitors, in minutes | string | "last_15m" | no |
| provisioned_capacity | Whether the table uses provisioned capacity. Set to true to enable capacity-based monitoring. | bool | false | no |
| read_capacity_units | The provisioned read capacity units for the table. Only used if provisioned_capacity is true. | number | 5 | no |
| write_capacity_units | The provisioned write capacity units for the table. Only used if provisioned_capacity is true. | number | 5 | no |
| create_dashboard | Whether to create a dashboard for the DynamoDB table | bool | false | no |
| dashboard_name_prefix | Prefix to add to the dashboard name | string | "DynamoDB Table Metrics" | no |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of the created DataDog monitor IDs |
| criticality_thresholds | The thresholds used for each monitor based on criticality level |
| dashboard_url | URL to the created dashboard, if dashboard creation was enabled |

## Criticality Thresholds

### High
```
read_throttle_events      = 10 (warning at 5)
write_throttle_events     = 10 (warning at 5)
consumed_read_capacity    = 70% (warning at 60%)
consumed_write_capacity   = 70% (warning at 60%)
system_errors             = 2 (warning at 1)
conditional_check_failed  = 10 (warning at 5)
```

### Medium
```
read_throttle_events      = 25 (warning at 10)
write_throttle_events     = 25 (warning at 10)
consumed_read_capacity    = 75% (warning at 65%)
consumed_write_capacity   = 75% (warning at 65%)
system_errors             = 5 (warning at 2)
conditional_check_failed  = 15 (warning at 7)
```

### Low
```
read_throttle_events      = 50 (warning at 25)
write_throttle_events     = 50 (warning at 25)
consumed_read_capacity    = 85% (warning at 75%)
consumed_write_capacity   = 85% (warning at 75%)
system_errors             = 10 (warning at 5)
conditional_check_failed  = 25 (warning at 15)
```