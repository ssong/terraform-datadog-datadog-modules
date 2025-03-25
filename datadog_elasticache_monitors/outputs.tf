output "monitor_ids" {
  description = "Map of the created DataDog monitor IDs"
  value = merge(
    {
      cpu_utilization        = datadog_monitor.elasticache_cpu_utilization.id
      memory_utilization     = datadog_monitor.elasticache_memory_utilization.id
      swap_usage             = datadog_monitor.elasticache_swap_usage.id
      evictions              = datadog_monitor.elasticache_evictions.id
      current_connections    = datadog_monitor.elasticache_current_connections.id
    },
    var.cache_type == "redis" && var.is_replica ? { replication_lag = datadog_monitor.elasticache_replication_lag[0].id } : {}
  )
}

output "criticality_thresholds" {
  description = "The thresholds used for each monitor based on criticality level"
  value       = local.thresholds[var.criticality]
}

output "dashboard_url" {
  description = "URL to the created dashboard, if dashboard creation was enabled"
  value       = var.create_dashboard ? "https://app.datadoghq.com/dashboard/${datadog_dashboard.elasticache_dashboard[0].id}" : null
}