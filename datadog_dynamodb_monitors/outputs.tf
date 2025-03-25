output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = merge(
    {
      read_throttle_events     = datadog_monitor.dynamodb_read_throttle_events.id
      write_throttle_events    = datadog_monitor.dynamodb_write_throttle_events.id
      system_errors            = datadog_monitor.dynamodb_system_errors.id
      conditional_check_failed = datadog_monitor.dynamodb_conditional_check_failed.id
    },
    var.provisioned_capacity ? {
      consumed_read_capacity  = datadog_monitor.dynamodb_consumed_read_capacity[0].id
      consumed_write_capacity = datadog_monitor.dynamodb_consumed_write_capacity[0].id
    } : {}
  )
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.dynamodb_dashboard[0].id}" : null
}