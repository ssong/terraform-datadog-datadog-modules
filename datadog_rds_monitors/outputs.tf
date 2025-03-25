output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = merge(
    {
      cpu_utilization    = datadog_monitor.rds_cpu_utilization.id
      memory_utilization = datadog_monitor.rds_memory_utilization.id
      disk_queue_depth   = datadog_monitor.rds_disk_queue_depth.id
      free_storage_space = datadog_monitor.rds_free_storage_space.id
      connection_count   = datadog_monitor.rds_connection_count.id
    },
    var.is_replica ? { replica_lag = datadog_monitor.rds_replica_lag[0].id } : {}
  )
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.rds_dashboard[0].id}" : null
}