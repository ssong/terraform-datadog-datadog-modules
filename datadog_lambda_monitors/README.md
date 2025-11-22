# DataDog Lambda Monitors Terraform Module

This Terraform module creates a standardized set of DataDog monitors for AWS Lambda functions with configurable criticality levels.

## Features

- Configurable criticality levels (low, medium, high) that automatically adjust thresholds
- Monitors for key Lambda metrics:
  - Error rate
  - Execution duration (P90)
  - Throttling
  - Invocation drops (compared to baseline)
  - Concurrent execution limits
  - Cold start duration
- Optional dashboard with 6 widgets using modern Datadog query syntax

## Usage

```hcl
module "api_lambda_monitors" {
  source = "path/to/datadog_lambda_monitors"

  lambda_function_name      = "my-lambda-function"
  criticality               = "high"  # Options: "low", "medium", "high"
  notification_target       = "@slack-channel-name @pagerduty-service"
  concurrent_execution_limit = 2000   # Optional, defaults to 1000
  tags                      = ["service:my-service", "team:my-team"]
}
```

## Requirements

- Terraform >= 0.13
- DataDog provider configured with valid API and application keys

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lambda_function_name | Name of the AWS Lambda function to monitor | `string` | n/a | yes |
| criticality | Criticality level (low, medium, high) | `string` | n/a | yes |
| notification_target | Target for alert notifications (e.g., @slack-channel) | `string` | n/a | yes |
| prefix | Prefix to add to monitor names | `string` | `"[Lambda] "` | no |
| tags | Additional tags to add to monitors | `list(string)` | `[]` | no |
| evaluation_period | Evaluation period for monitors | `string` | `"last_15m"` | no |
| baseline_period | Baseline period for comparison monitors | `string` | `"hour_before"` | no |
| concurrent_execution_limit | Concurrent execution limit for the Lambda | `number` | `1000` | no |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of created DataDog monitor IDs |
| criticality_thresholds | Thresholds used for monitors based on criticality |

## Criticality Levels and Thresholds

The module uses the following thresholds for each criticality level:

### High Criticality (Production/Critical Services)
- Error rate: 2% critical, 1% warning
- Duration (P90): 1000ms critical, 800ms warning
- Cold start duration: 1000ms critical, 750ms warning
- Throttles: 2 critical, 1 warning
- Invocation drop: 15% critical, 10% warning
- Concurrent executions: 60% critical, 50% warning

### Medium Criticality (Important Services)
- Error rate: 5% critical, 2% warning
- Duration (P90): 3000ms critical, 2000ms warning
- Cold start duration: 2000ms critical, 1500ms warning
- Throttles: 5 critical, 2 warning
- Invocation drop: 30% critical, 15% warning
- Concurrent executions: 70% critical, 60% warning

### Low Criticality (Non-Critical Services)
- Error rate: 10% critical, 5% warning
- Duration (P90): 5000ms critical, 3000ms warning
- Cold start duration: 3000ms critical, 2000ms warning
- Throttles: 10 critical, 5 warning
- Invocation drop: 50% critical, 30% warning
- Concurrent executions: 80% critical, 70% warning

## Example

See the `example` directory for a complete usage example.