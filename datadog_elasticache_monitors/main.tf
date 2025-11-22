locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }

  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - ElastiCache: ${var.cache_cluster_id}" : ""

  # Use appropriate metric prefix based on cache type
  metric_prefix = var.cache_type == "redis" ? "aws.elasticache.redis" : "aws.elasticache.memcached"

  thresholds = {
    low = {
      cpu_utilization          = 90.0
      cpu_warning              = 80.0
      cpu_recovery             = 75.0
      memory_utilization       = 90.0
      memory_warning           = 80.0
      memory_recovery          = 75.0
      swap_utilization         = 50.0
      swap_warning             = 35.0
      swap_recovery            = 25.0
      evictions                = 1000.0
      evictions_warning        = 500.0
      evictions_recovery       = 400.0
      connections              = 90.0
      connections_warning      = 80.0
      connections_recovery     = 75.0
      replication_lag          = 300.0
      replication_lag_warning  = 180.0
      replication_lag_recovery = 120.0
    }
    medium = {
      cpu_utilization          = 85.0
      cpu_warning              = 75.0
      cpu_recovery             = 65.0
      memory_utilization       = 85.0
      memory_warning           = 75.0
      memory_recovery          = 65.0
      swap_utilization         = 35.0
      swap_warning             = 25.0
      swap_recovery            = 15.0
      evictions                = 500.0
      evictions_warning        = 250.0
      evictions_recovery       = 200.0
      connections              = 80.0
      connections_warning      = 70.0
      connections_recovery     = 60.0
      replication_lag          = 180.0
      replication_lag_warning  = 90.0
      replication_lag_recovery = 60.0
    }
    high = {
      cpu_utilization          = 80.0
      cpu_warning              = 70.0
      cpu_recovery             = 60.0
      memory_utilization       = 80.0
      memory_warning           = 70.0
      memory_recovery          = 60.0
      swap_utilization         = 25.0
      swap_warning             = 15.0
      swap_recovery            = 10.0
      evictions                = 250.0
      evictions_warning        = 100.0
      evictions_recovery       = 75.0
      connections              = 70.0
      connections_warning      = 60.0
      connections_recovery     = 50.0
      replication_lag          = 60.0
      replication_lag_warning  = 30.0
      replication_lag_recovery = 15.0
    }
  }
}

resource "datadog_monitor" "elasticache_cpu_utilization" {
  name               = "${var.prefix}ElastiCache CPU Utilization - ${var.cache_cluster_id}"
  type               = "query alert"
  message            = <<-EOT
    ElastiCache cluster ${var.cache_cluster_id} has high CPU utilization.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ElastiCache cluster ${var.cache_cluster_id} continues to experience high CPU utilization!"

  query = "avg(${var.evaluation_period}):avg:${local.metric_prefix}.cpuutilization{cacheclusterid:${var.cache_cluster_id}} > ${local.thresholds[var.criticality].cpu_utilization}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].cpu_utilization
    warning  = local.thresholds[var.criticality].cpu_warning
    recovery = local.thresholds[var.criticality].cpu_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "elasticache_memory_utilization" {
  name               = "${var.prefix}ElastiCache Memory Utilization - ${var.cache_cluster_id}"
  type               = "query alert"
  message            = <<-EOT
    ElastiCache cluster ${var.cache_cluster_id} has high memory utilization.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ElastiCache cluster ${var.cache_cluster_id} continues to experience high memory utilization!"

  query = var.cache_type == "redis" ? "avg(${var.evaluation_period}):avg:${local.metric_prefix}.database_memory_usage_percentage{cacheclusterid:${var.cache_cluster_id}} > ${local.thresholds[var.criticality].memory_utilization}" : "avg(${var.evaluation_period}):avg:${local.metric_prefix}.memory_usage{cacheclusterid:${var.cache_cluster_id}} / avg:${local.metric_prefix}.memory_limit{cacheclusterid:${var.cache_cluster_id}} * 100 > ${local.thresholds[var.criticality].memory_utilization}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].memory_utilization
    warning  = local.thresholds[var.criticality].memory_warning
    recovery = local.thresholds[var.criticality].memory_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "elasticache_swap_usage" {
  name               = "${var.prefix}ElastiCache Swap Usage - ${var.cache_cluster_id}"
  type               = "query alert"
  message            = <<-EOT
    ElastiCache cluster ${var.cache_cluster_id} has high swap usage.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ElastiCache cluster ${var.cache_cluster_id} continues to have high swap usage!"

  query = "avg(${var.evaluation_period}):avg:${local.metric_prefix}.swap_usage{cacheclusterid:${var.cache_cluster_id}} > ${local.thresholds[var.criticality].swap_utilization}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].swap_utilization
    warning  = local.thresholds[var.criticality].swap_warning
    recovery = local.thresholds[var.criticality].swap_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "elasticache_evictions" {
  name               = "${var.prefix}ElastiCache Evictions - ${var.cache_cluster_id}"
  type               = "query alert"
  message            = <<-EOT
    ElastiCache cluster ${var.cache_cluster_id} has a high rate of evictions.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ElastiCache cluster ${var.cache_cluster_id} continues to have a high rate of evictions!"

  query = "avg(${var.evaluation_period}):avg:${local.metric_prefix}.evictions{cacheclusterid:${var.cache_cluster_id}} > ${local.thresholds[var.criticality].evictions}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].evictions
    warning  = local.thresholds[var.criticality].evictions_warning
    recovery = local.thresholds[var.criticality].evictions_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "elasticache_current_connections" {
  name               = "${var.prefix}ElastiCache Current Connections - ${var.cache_cluster_id}"
  type               = "query alert"
  message            = <<-EOT
    ElastiCache cluster ${var.cache_cluster_id} is nearing its maximum connection limit.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ElastiCache cluster ${var.cache_cluster_id} is still nearing its maximum connection limit!"

  query = "avg(${var.evaluation_period}):avg:${local.metric_prefix}.curr_connections{cacheclusterid:${var.cache_cluster_id}} / ${var.max_connections} * 100 > ${local.thresholds[var.criticality].connections}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].connections
    warning  = local.thresholds[var.criticality].connections_warning
    recovery = local.thresholds[var.criticality].connections_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "elasticache_replication_lag" {
  count              = var.cache_type == "redis" && var.is_replica ? 1 : 0
  name               = "${var.prefix}ElastiCache Replication Lag - ${var.cache_cluster_id}"
  type               = "query alert"
  message            = <<-EOT
    ElastiCache Redis replica ${var.cache_cluster_id} has high replication lag.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ElastiCache Redis replica ${var.cache_cluster_id} still has high replication lag!"

  query = "avg(${var.evaluation_period}):avg:${local.metric_prefix}.replication_lag{cacheclusterid:${var.cache_cluster_id}} > ${local.thresholds[var.criticality].replication_lag}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].replication_lag
    warning  = local.thresholds[var.criticality].replication_lag_warning
    recovery = local.thresholds[var.criticality].replication_lag_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

# Dashboard for ElastiCache metrics
resource "datadog_dashboard" "elasticache_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for ElastiCache Cluster ${var.cache_cluster_id}"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "CPU Utilization (%)"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
        }
        queries {
          name        = "query0"
          query       = "avg:${local.metric_prefix}.cpuutilization{cacheclusterid:${var.cache_cluster_id}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].cpu_utilization
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].cpu_warning
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
        max          = "100"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Memory Utilization (%)"
      request {
        display_type = "line"
        formulas {
          formula = var.cache_type == "redis" ? "query0" : "query0 / query1 * 100"
          alias   = "Memory Utilization %"
        }
        queries {
          name        = "query0"
          query       = var.cache_type == "redis" ? "avg:${local.metric_prefix}.database_memory_usage_percentage{cacheclusterid:${var.cache_cluster_id}}" : "avg:${local.metric_prefix}.memory_usage{cacheclusterid:${var.cache_cluster_id}}"
          data_source = "metrics"
        }
        dynamic "queries" {
          for_each = var.cache_type == "memcached" ? [1] : []
          content {
            name        = "query1"
            query       = "avg:${local.metric_prefix}.memory_limit{cacheclusterid:${var.cache_cluster_id}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].memory_utilization
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].memory_warning
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
        max          = "100"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Swap Usage"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
        }
        queries {
          name        = "query0"
          query       = "avg:${local.metric_prefix}.swap_usage{cacheclusterid:${var.cache_cluster_id}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].swap_utilization
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].swap_warning
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Evictions"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
        }
        queries {
          name        = "query0"
          query       = "avg:${local.metric_prefix}.evictions{cacheclusterid:${var.cache_cluster_id}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].evictions
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].evictions_warning
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Current Connections"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
          alias   = "Current Connections"
        }
        queries {
          name        = "query0"
          query       = "avg:${local.metric_prefix}.curr_connections{cacheclusterid:${var.cache_cluster_id}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = var.max_connections * local.thresholds[var.criticality].connections / 100.0
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = var.max_connections * local.thresholds[var.criticality].connections_warning / 100.0
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  dynamic "widget" {
    for_each = var.cache_type == "redis" && var.is_replica ? [1] : []
    content {
      timeseries_definition {
        title = "Replication Lag (seconds)"
        request {
          display_type = "line"
          formulas {
            formula = "query0"
          }
          queries {
            name        = "query0"
            query       = "avg:${local.metric_prefix}.replication_lag{cacheclusterid:${var.cache_cluster_id}}"
            data_source = "metrics"
          }
        }
        marker {
          display_type = "error dashed"
          value        = local.thresholds[var.criticality].replication_lag
          label        = "Critical"
        }
        marker {
          display_type = "warning dashed"
          value        = local.thresholds[var.criticality].replication_lag_warning
          label        = "Warning"
        }
        yaxis {
          include_zero = true
          scale        = "linear"
        }
      }
    }
  }

  # Cache type specific widgets
  dynamic "widget" {
    for_each = var.cache_type == "redis" ? [1] : []
    content {
      timeseries_definition {
        title = "Cache Hit Rate"
        request {
          display_type = "line"
          formulas {
            formula = "query0"
          }
          queries {
            name        = "query0"
            query       = "avg:${local.metric_prefix}.cache_hit_rate{cacheclusterid:${var.cache_cluster_id}}"
            data_source = "metrics"
          }
        }
        yaxis {
          include_zero = true
          scale        = "linear"
          max          = "100"
        }
      }
    }
  }

  dynamic "widget" {
    for_each = var.cache_type == "memcached" ? [1] : []
    content {
      timeseries_definition {
        title = "Get & Set Commands"
        request {
          display_type = "line"
          formulas {
            formula = "query0"
            alias   = "Get Commands"
          }
          formulas {
            formula = "query1"
            alias   = "Set Commands"
          }
          queries {
            name        = "query0"
            query       = "avg:${local.metric_prefix}.cmd_get{cacheclusterid:${var.cache_cluster_id}}"
            data_source = "metrics"
          }
          queries {
            name        = "query1"
            query       = "avg:${local.metric_prefix}.cmd_set{cacheclusterid:${var.cache_cluster_id}}"
            data_source = "metrics"
          }
        }
        yaxis {
          include_zero = true
          scale        = "linear"
        }
      }
    }
  }

  template_variable {
    name   = "cache_cluster"
    prefix = "cacheclusterid"
  }

  template_variable_preset {
    name = "Default"

    template_variable {
      name  = "cache_cluster"
      value = var.cache_cluster_id
    }
  }

  tags = concat(var.tags, ["elasticache:${var.cache_cluster_id}", "managed_by:terraform"])
}