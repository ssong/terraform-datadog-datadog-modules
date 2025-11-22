# Datadog AWS Monitoring Terraform Modules

A collection of standardized Terraform modules for setting up comprehensive Datadog monitoring for AWS services.

## Overview

This repository contains reusable Terraform modules that create pre-configured Datadog monitors and dashboards for common AWS services. Each module follows consistent patterns and supports variable criticality levels with appropriate thresholds.

All dashboards use the modern Datadog `formulas` + `queries` format for better maintainability and future compatibility.

## Modules

| Module | AWS Service | Monitors | Dashboard Widgets |
|--------|------------|----------|-------------------|
| [datadog_lambda_monitors](./datadog_lambda_monitors) | AWS Lambda | Error rate, duration, throttles, invocation drop, concurrency, **cold starts** | 6 widgets |
| [datadog_api_gateway_monitors](./datadog_api_gateway_monitors) | API Gateway | Combined errors, **5xx errors**, latency, request drop, throttles, integration latency | 6 widgets |
| [datadog_sqs_monitors](./datadog_sqs_monitors) | SQS | Message age, queue depth, no messages, error rate | 5 widgets |
| [datadog_ecs_monitors](./datadog_ecs_monitors) | ECS | CPU/memory utilization, task deviation, deployment failures, container restarts | 6 widgets |
| [datadog_rds_monitors](./datadog_rds_monitors) | RDS | CPU/memory utilization, disk queue, storage, connections, replica lag | 7 widgets |
| [datadog_dynamodb_monitors](./datadog_dynamodb_monitors) | DynamoDB | Read/write throttles, capacity usage, system errors, conditional check failures | 6 widgets |
| [datadog_elasticache_monitors](./datadog_elasticache_monitors) | ElastiCache | CPU/memory utilization, swap, evictions, connections, replication lag, cache hit rate | 8 widgets |

**Bold** = Recently added monitors

## Common Features

* **Tiered Criticality Levels**: All modules support high, medium, and low criticality with appropriate thresholds
* **Customizable Notifications**: Direct alerts to appropriate Slack channels, PagerDuty, or email
* **Message Prefixing**: Customize alert message prefixes for easy identification
* **Optional Dashboards**: Automatically create dashboards alongside monitors using modern query syntax
* **Flexible Evaluation**: Configure custom evaluation and baseline comparison periods
* **Tagging Support**: Consistent tagging across all resources for organization
* **Conditional Widgets**: Dashboards support conditional widget rendering based on resource configuration

## Usage Example

```hcl
module "api_lambda_monitors" {
  source = "./datadog_lambda_monitors"

  lambda_function_name       = "api-gateway-lambda-function"
  criticality                = "high"  # Stricter thresholds
  notification_target        = "@slack-api-alerts @pagerduty-core-team"
  concurrent_execution_limit = 2000
  tags                       = ["service:api-gateway", "team:platform"]
  create_dashboard           = true
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

## Local Validation

Validate your configuration before deploying:

```bash
# Quick validation
terraform validate
terraform fmt -recursive

# Advanced validation (recommended)
brew install tflint
tflint --recursive
```

For comprehensive validation workflows, see the [validation guide](./VALIDATION.md).

## Recent Updates

* **Dashboard Modernization**: All dashboards now use modern `formulas` + `queries` format
* **New Monitors**: Added dedicated 5xx error monitoring for API Gateway and cold start tracking for Lambda
* **Enhanced Examples**: Added comprehensive examples for DynamoDB and ElastiCache modules
* **Syntax Fixes**: Resolved all dashboard rendering issues and monitor query errors

## License

MIT