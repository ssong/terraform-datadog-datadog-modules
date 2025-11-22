# Datadog RDS Monitors Terraform Module

This Terraform module creates a set of Datadog monitors for AWS RDS instances. The monitors are configured based on the criticality level provided (low, medium, high).

## Monitors Created

1. **CPU Utilization Monitor**: Alerts when the RDS instance CPU utilization exceeds thresholds
2. **Memory Utilization Monitor**: Alerts when the RDS instance memory utilization exceeds thresholds
3. **Disk Queue Depth Monitor**: Alerts when there's a high disk queue depth, indicating disk contention
4. **Free Storage Space Monitor**: Alerts when the RDS instance is running low on free storage space
5. **Connection Count Monitor**: Alerts when the RDS instance is nearing its maximum connection limit
6. **Replica Lag Monitor** (only for read replicas): Alerts when a read replica has high replication lag

## Dashboard

When `create_dashboard = true`, creates a dashboard with 7 widgets using modern Datadog query syntax:
- CPU utilization percentage
- Memory utilization percentage
- Disk queue depth
- Free storage space percentage
- Connection count
- Replica lag (conditional, only for replicas)
- Read/Write IOPS

## Usage

```hcl
# For a primary RDS instance
module "primary_rds_monitors" {
  source = "path/to/datadog_rds_monitors"

  db_instance_identifier = "my-primary-db"
  criticality            = "high"  # Options: low, medium, high
  notification_target    = "@slack-channel @pagerduty-service"
  max_connections        = 200     # The maximum connections allowed for your instance
  tags                   = ["service:database", "team:platform"]
}

# For a read replica
module "replica_rds_monitors" {
  source = "path/to/datadog_rds_monitors"

  db_instance_identifier = "my-read-replica"
  criticality            = "medium"  # Options: low, medium, high
  notification_target    = "@slack-channel @pagerduty-service"
  is_replica             = true      # Enable replica lag monitoring
  tags                   = ["service:database", "team:platform"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db_instance_identifier | The identifier of the AWS RDS instance to monitor | string | n/a | yes |
| criticality | The criticality level of the RDS instance (low, medium, high) | string | n/a | yes |
| prefix | Prefix to add to the monitor names | string | "[RDS] " | no |
| notification_target | The target for alert notifications (e.g., @slack-channel, @pagerduty, @email) | string | n/a | yes |
| tags | Additional tags to add to the monitors | list(string) | [] | no |
| evaluation_period | The evaluation period for the monitors, in minutes | string | "last_15m" | no |
| max_connections | The maximum number of connections allowed for the RDS instance | number | 100 | no |
| is_replica | Whether the RDS instance is a read replica. Set to true to enable replica lag monitoring. | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of the created DataDog monitor IDs |
| criticality_thresholds | The thresholds used for each monitor based on criticality level |

## Criticality Thresholds

### High
```
cpu_utilization        = 80% (warning at 70%)
memory_utilization     = 80% (warning at 70%)
disk_queue_depth       = 15 (warning at 7)
disk_free_storage      = 20% (warning at 30%)
connection_count       = 70% (warning at 60%)
replica_lag            = 60s (warning at 30s)
```

### Medium
```
cpu_utilization        = 85% (warning at 75%)
memory_utilization     = 85% (warning at 75%)
disk_queue_depth       = 20 (warning at 10)
disk_free_storage      = 15% (warning at 25%)
connection_count       = 80% (warning at 70%)
replica_lag            = 180s (warning at 90s)
```

### Low
```
cpu_utilization        = 90% (warning at 80%)
memory_utilization     = 90% (warning at 80%)
disk_queue_depth       = 25 (warning at 15)
disk_free_storage      = 10% (warning at 20%)
connection_count       = 90% (warning at 80%)
replica_lag            = 300s (warning at 180s)
```