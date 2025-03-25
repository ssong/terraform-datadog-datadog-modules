# Datadog ECS Monitors Terraform Module

This Terraform module creates a set of Datadog monitors for AWS ECS services. The monitors are configured based on the criticality level provided (low, medium, high).

## Monitors Created

1. **CPU Utilization Monitor**: Alerts when the ECS service CPU utilization exceeds thresholds
2. **Memory Utilization Monitor**: Alerts when the ECS service memory utilization exceeds thresholds
3. **Task Count Deviation Monitor**: Alerts when there's a significant difference between desired and running task counts
4. **Service Failures Monitor**: Alerts when ECS service deployment failures occur
5. **Container Restarts Monitor**: Alerts when containers are frequently restarting

## Usage

```hcl
module "ecs_monitors" {
  source = "path/to/datadog_ecs_monitors"

  cluster_name        = "my-ecs-cluster"
  service_name        = "my-ecs-service"
  criticality         = "high"  # Options: low, medium, high
  notification_target = "@slack-channel @pagerduty-service"
  tags                = ["service:api", "team:platform"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | The name of the AWS ECS cluster to monitor | string | n/a | yes |
| service_name | The name of the AWS ECS service to monitor | string | n/a | yes |
| criticality | The criticality level of the ECS service (low, medium, high) | string | n/a | yes |
| prefix | Prefix to add to the monitor names | string | "[ECS] " | no |
| notification_target | The target for alert notifications (e.g., @slack-channel, @pagerduty, @email) | string | n/a | yes |
| tags | Additional tags to add to the monitors | list(string) | [] | no |
| evaluation_period | The evaluation period for the monitors, in minutes | string | "last_15m" | no |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of the created DataDog monitor IDs |
| criticality_thresholds | The thresholds used for each monitor based on criticality level |

## Criticality Thresholds

### High
```
cpu_utilization         = 80% (warning at 70%)
memory_utilization      = 80% (warning at 70%)
task_count_deviation    = 10% (warning at 5%)
service_failures        = 2 (warning at 1)
container_restarts      = 2 (warning at 1)
```

### Medium
```
cpu_utilization         = 85% (warning at 75%)
memory_utilization      = 85% (warning at 75%)
task_count_deviation    = 20% (warning at 10%)
service_failures        = 3 (warning at 2)
container_restarts      = 3 (warning at 2)
```

### Low
```
cpu_utilization         = 90% (warning at 80%)
memory_utilization      = 90% (warning at 80%)
task_count_deviation    = 30% (warning at 20%)
service_failures        = 5 (warning at 3)
container_restarts      = 5 (warning at 3)
```