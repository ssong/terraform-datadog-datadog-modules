provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

# Lambda Monitors Examples
module "api_lambda_monitors" {
  source = "../datadog_lambda_monitors"

  lambda_function_name     = "api-gateway-lambda-function"
  criticality              = "high"
  notification_target      = "@slack-api-alerts @pagerduty-core-team"
  concurrent_execution_limit = 2000
  tags                     = ["service:api-gateway", "team:platform"]
  create_dashboard         = true
}

module "batch_processing_lambda_monitors" {
  source = "../datadog_lambda_monitors"

  lambda_function_name     = "batch-processing-function"
  criticality              = "medium"
  notification_target      = "@slack-batch-alerts"
  prefix                   = "[Batch Lambda] "
  tags                     = ["service:batch-processing", "team:data"]
}

module "reporting_lambda_monitors" {
  source = "../datadog_lambda_monitors"

  lambda_function_name     = "weekly-reporting-function"
  criticality              = "low"
  notification_target      = "@slack-reporting-team"
  evaluation_period        = "last_30m"
  baseline_period          = "day_before"
  tags                     = ["service:reporting", "team:analytics"]
}

# API Gateway Monitors Examples
module "main_api_gateway_monitors" {
  source = "../datadog_api_gateway_monitors"

  api_gateway_name     = "main-api-gateway"
  criticality          = "high"
  notification_target  = "@slack-api-alerts @pagerduty-api-team"
  tags                 = ["service:api-gateway", "team:platform"]
  create_dashboard     = true
}

module "internal_api_gateway_monitors" {
  source = "../datadog_api_gateway_monitors"

  api_gateway_name     = "internal-api-gateway"
  criticality          = "medium"
  notification_target  = "@slack-internal-api-alerts"
  prefix               = "[Internal API] "
  tags                 = ["service:internal-api", "team:backend"]
}

module "test_api_gateway_monitors" {
  source = "../datadog_api_gateway_monitors"

  api_gateway_name     = "test-api-gateway"
  criticality          = "low"
  notification_target  = "@slack-test-team"
  evaluation_period    = "last_30m"
  baseline_period      = "day_before"
  tags                 = ["service:test-api", "team:qa"]
}

# SQS Monitors Examples
module "payment_sqs_monitors" {
  source = "../datadog_sqs_monitors"

  queue_name          = "payment-processing-queue"
  criticality         = "high"
  notification_target = "@slack-payment-alerts @pagerduty-payments-team"
  tags                = ["service:payments", "team:finance"]
  create_dashboard    = true
}

module "inventory_sqs_monitors" {
  source = "../datadog_sqs_monitors"

  queue_name          = "inventory-updates-queue"
  criticality         = "medium"
  notification_target = "@slack-inventory-alerts"
  prefix              = "[Inventory SQS] "
  tags                = ["service:inventory", "team:warehouse"]
}

module "notification_sqs_monitors" {
  source = "../datadog_sqs_monitors"

  queue_name          = "user-notifications-queue"
  criticality         = "low"
  notification_target = "@slack-notification-team"
  evaluation_period   = "last_30m"
  tags                = ["service:notifications", "team:communications"]
}

# ECS Monitors Examples
module "api_ecs_monitors" {
  source = "../datadog_ecs_monitors"

  cluster_name        = "main-api-cluster"
  service_name        = "api-service"
  criticality         = "high"
  notification_target = "@slack-api-alerts @pagerduty-api-team"
  tags                = ["service:api", "team:platform"]
  create_dashboard    = true
}

module "worker_ecs_monitors" {
  source = "../datadog_ecs_monitors"

  cluster_name        = "worker-cluster"
  service_name        = "batch-processor"
  criticality         = "medium"
  notification_target = "@slack-worker-alerts"
  prefix              = "[Worker ECS] "
  tags                = ["service:worker", "team:data"]
}

module "reporting_ecs_monitors" {
  source = "../datadog_ecs_monitors"

  cluster_name        = "reporting-cluster"
  service_name        = "report-generator"
  criticality         = "low"
  notification_target = "@slack-reporting-team"
  evaluation_period   = "last_30m"
  tags                = ["service:reporting", "team:analytics"]
}

# RDS Monitors Examples
module "production_db_monitors" {
  source = "../datadog_rds_monitors"

  db_instance_identifier = "production-db-instance"
  criticality            = "high"
  notification_target    = "@slack-db-alerts @pagerduty-db-team"
  max_connections        = 500
  tags                   = ["service:database", "team:dba"]
  create_dashboard       = true
}

module "replica_db_monitors" {
  source = "../datadog_rds_monitors"

  db_instance_identifier = "production-read-replica"
  criticality            = "medium"
  notification_target    = "@slack-db-alerts"
  is_replica             = true
  prefix                 = "[RDS Replica] "
  tags                   = ["service:database", "team:dba", "role:replica"]
}

module "dev_db_monitors" {
  source = "../datadog_rds_monitors"

  db_instance_identifier = "development-db-instance"
  criticality            = "low"
  notification_target    = "@slack-dev-team"
  evaluation_period      = "last_30m"
  tags                   = ["service:database", "team:development", "environment:dev"]
}