# Datadog API Gateway Monitors Terraform Module

This Terraform module creates a set of Datadog monitors for AWS API Gateway. The monitors are configured based on the criticality level provided (low, medium, high).

## Monitors Created

1. **Error Rate Monitor**: Alerts when the API Gateway has a high 4xx/5xx error rate
2. **Latency Monitor**: Alerts when the API Gateway latency (P90) exceeds thresholds
3. **Request Count Drop Monitor**: Alerts when the API Gateway request count drops significantly
4. **Throttling Monitor**: Alerts when the API Gateway is being throttled
5. **Integration Latency Monitor**: Alerts when the API Gateway integration latency is high

## Usage

```hcl
module "api_gateway_monitors" {
  source = "path/to/datadog_api_gateway_monitors"

  api_gateway_name     = "my-api-gateway"
  criticality          = "high"  # Options: low, medium, high
  team                 = "engagement"  # Options: engagement, acquisition, shared-services
  notification_target  = "@slack-channel @pagerduty-service"
  tags                 = ["service:api-gateway"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api_gateway_name | The name of the AWS API Gateway to monitor | string | n/a | yes |
| criticality | The criticality level of the API Gateway (low, medium, high) | string | n/a | yes |
| prefix | Prefix to add to the monitor names | string | "[API Gateway] " | no |
| notification_target | The target for alert notifications (e.g., @slack-channel, @pagerduty, @email) | string | n/a | yes |
| tags | Additional tags to add to the monitors | list(string) | [] | no |
| evaluation_period | The evaluation period for the monitors, in minutes | string | "last_15m" | no |
| baseline_period | The baseline period for comparison monitors, in hours | string | "hour_before" | no |
| team | The team responsible for the API Gateway (engagement, acquisition, shared-services) | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of the created DataDog monitor IDs |
| criticality_thresholds | The thresholds used for each monitor based on criticality level |

## Criticality Thresholds

### High
```
error_rate           = 2.0% (warning at 1.0%)
latency_p90          = 1000ms (warning at 800ms)
count_drop           = 15% (warning at 10%)
throttles            = 2 (warning at 1)
integration_latency  = 1000ms (warning at 500ms)
```

### Medium
```
error_rate           = 5.0% (warning at 2.0%)
latency_p90          = 3000ms (warning at 2000ms)
count_drop           = 30% (warning at 15%)
throttles            = 5 (warning at 2)
integration_latency  = 2000ms (warning at 1000ms)
```

### Low
```
error_rate           = 10.0% (warning at 5.0%)
latency_p90          = 5000ms (warning at 3000ms)
count_drop           = 50% (warning at 30%)
throttles            = 10 (warning at 5)
integration_latency  = 3000ms (warning at 2000ms)
```
