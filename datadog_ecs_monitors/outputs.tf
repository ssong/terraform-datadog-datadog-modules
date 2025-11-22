output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = {
    cpu_utilization      = datadog_monitor.ecs_cpu_utilization.id
    memory_utilization   = datadog_monitor.ecs_memory_utilization.id
    task_count_deviation = datadog_monitor.ecs_task_count_deviation.id
    service_failures     = datadog_monitor.ecs_service_failures.id
    container_restarts   = datadog_monitor.ecs_container_restarts.id
  }
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.ecs_dashboard[0].id}" : null
}