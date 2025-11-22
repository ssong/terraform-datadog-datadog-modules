output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = {
    error_rate            = datadog_monitor.lambda_error_rate.id
    duration              = datadog_monitor.lambda_duration.id
    throttles             = datadog_monitor.lambda_throttles.id
    invocation_drop       = datadog_monitor.lambda_invocation_drop.id
    concurrent_executions = datadog_monitor.lambda_concurrent_executions.id
    cold_start_duration   = datadog_monitor.lambda_cold_start_duration.id
  }
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.lambda_dashboard[0].id}" : null
}