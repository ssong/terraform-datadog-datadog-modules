output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = {
    error_rate          = datadog_monitor.api_gateway_error_rate.id
    server_error_rate   = datadog_monitor.api_gateway_5xx_error_rate.id
    latency             = datadog_monitor.api_gateway_latency.id
    count_drop          = datadog_monitor.api_gateway_count_drop.id
    throttles           = datadog_monitor.api_gateway_throttles.id
    integration_latency = datadog_monitor.api_gateway_integration_latency.id
  }
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.api_gateway_dashboard[0].id}" : null
}