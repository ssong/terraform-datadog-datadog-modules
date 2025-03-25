output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = {
    age_max           = datadog_monitor.sqs_age_max.id
    approximate_count = datadog_monitor.sqs_approximate_count.id
    no_messages       = datadog_monitor.sqs_no_messages.id
    error_rate        = datadog_monitor.sqs_error_rate.id
    throughput_drop   = datadog_monitor.sqs_throughput_drop.id
  }
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.sqs_dashboard[0].id}" : null
}