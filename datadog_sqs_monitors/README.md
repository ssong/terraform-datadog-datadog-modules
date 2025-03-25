# Datadog SQS Monitors Terraform Module

This Terraform module creates a set of Datadog monitors for AWS SQS queues. The monitors are configured based on the criticality level provided (low, medium, high).

## Monitors Created

1. **Max Age Monitor**: Alerts when the oldest message in the queue exceeds thresholds
2. **Queue Depth Monitor**: Alerts when too many messages are waiting to be processed
3. **No Messages Monitor**: Alerts when the queue hasn't received messages for an extended period
4. **Error Rate Monitor**: Alerts when the rate of invalid messages is high
5. **Throughput Drop Monitor**: Alerts when message throughput drops significantly

## Usage

```hcl
module "sqs_monitors" {
  source = "path/to/datadog_sqs_monitors"

  queue_name          = "my-sqs-queue"
  criticality         = "high"  # Options: low, medium, high
  notification_target = "@slack-channel @pagerduty-service"
  tags                = ["service:messaging", "team:platform"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| queue_name | The name of the AWS SQS queue to monitor | string | n/a | yes |
| criticality | The criticality level of the SQS queue (low, medium, high) | string | n/a | yes |
| prefix | Prefix to add to the monitor names | string | "[SQS] " | no |
| notification_target | The target for alert notifications (e.g., @slack-channel, @pagerduty, @email) | string | n/a | yes |
| tags | Additional tags to add to the monitors | list(string) | [] | no |
| evaluation_period | The evaluation period for the monitors, in minutes | string | "last_15m" | no |
| baseline_period | The baseline period for comparison monitors, in hours | string | "hour_before" | no |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of the created DataDog monitor IDs |
| criticality_thresholds | The thresholds used for each monitor based on criticality level |

## Criticality Thresholds

### High
```
age_max               = 900s (warning at 600s)
approximate_count     = 2000 (warning at 1000)
no_messages           = 60m (recovery at 30m)
error_rate            = 2.0% (warning at 1.0%)
throughput_drop       = 15% (warning at 10%)
```

### Medium
```
age_max               = 1800s (warning at 900s)
approximate_count     = 5000 (warning at 3000)
no_messages           = 120m (recovery at 60m)
error_rate            = 5.0% (warning at 2.0%)
throughput_drop       = 30% (warning at 15%)
```

### Low
```
age_max               = 3600s (warning at 1800s)
approximate_count     = 10000 (warning at 5000)
no_messages           = 180m (recovery at 120m)
error_rate            = 10.0% (warning at 5.0%)
throughput_drop       = 50% (warning at 30%)
```