# Datadog AWS Monitoring Terraform Modules

A collection of standardized Terraform modules for setting up comprehensive Datadog monitoring for AWS services.

## Overview

This repository contains reusable Terraform modules that create pre-configured Datadog monitors and dashboards for common AWS services. Each module follows consistent patterns and supports variable criticality levels with appropriate thresholds.

## Modules

| Module | AWS Service | Key Features |
|--------|------------|--------------|
| [datadog_lambda_monitors](./datadog_lambda_monitors) | AWS Lambda | Error rates, duration, throttling, concurrency |
| [datadog_api_gateway_monitors](./datadog_api_gateway_monitors) | API Gateway | Error rates, latency, request volumes |
| [datadog_sqs_monitors](./datadog_sqs_monitors) | SQS | Queue depth, message age, throughput |
| [datadog_ecs_monitors](./datadog_ecs_monitors) | ECS | Task counts, resource utilization, failures |
| [datadog_rds_monitors](./datadog_rds_monitors) | RDS | CPU/memory utilization, storage, connections |
| [datadog_dynamodb_monitors](./datadog_dynamodb_monitors) | DynamoDB | Capacity usage, throttled requests, latency |
| [datadog_elasticache_monitors](./datadog_elasticache_monitors) | ElastiCache | CPU/memory usage, evictions, connections |

## Common Features

* **Tiered Criticality Levels**: All modules support high, medium, and low criticality with appropriate thresholds
* **Customizable Notifications**: Direct alerts to appropriate Slack channels, PagerDuty, or email
* **Message Prefixing**: Customize alert message prefixes for easy identification
* **Optional Dashboards**: Automatically create dashboards alongside monitors
* **Flexible Evaluation**: Configure custom evaluation and baseline comparison periods
* **Tagging Support**: Consistent tagging across all resources for organization

## Usage Example

```hcl
module "api_lambda_monitors" {
  source = "./datadog_lambda_monitors"

  lambda_function_name     = "api-gateway-lambda-function"
  criticality              = "high"  # Stricter thresholds
  notification_target      = "@slack-api-alerts @pagerduty-core-team"
  concurrent_execution_limit = 2000
  tags                     = ["service:api-gateway", "team:platform"]
  create_dashboard         = true
}

module "inventory_sqs_monitors" {
  source = "./datadog_sqs_monitors"

  queue_name          = "inventory-updates-queue"
  criticality         = "medium"  # Balanced thresholds
  notification_target = "@slack-inventory-alerts"
  prefix              = "[Inventory SQS] "
  tags                = ["service:inventory", "team:warehouse"]
}
```

See the [example](./example) directory for comprehensive usage examples of all modules.

## Requirements

* Terraform >= 1.0
* Datadog Provider >= 3.20.0
* Datadog API and App keys configured

## Getting Started

1. Clone this repository
2. Configure your Datadog provider with API and App keys
3. Import the desired modules in your Terraform configuration
4. Set the required variables according to your needs
5. Run `terraform init` and `terraform apply`

## License

MIT