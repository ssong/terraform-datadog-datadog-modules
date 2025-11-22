locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }

  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - RDS Instance: ${var.db_instance_identifier}" : ""

  thresholds = {
    low = {
      cpu_utilization      = 90.0
      cpu_warning          = 80.0
      cpu_recovery         = 75.0
      memory_utilization   = 90.0
      memory_warning       = 80.0
      memory_recovery      = 75.0
      disk_queue_depth     = 25.0
      disk_queue_warning   = 15.0
      disk_queue_recovery  = 10.0
      disk_free_storage    = 10.0
      disk_free_warning    = 20.0
      disk_free_recovery   = 25.0
      connection_count     = 90.0
      connection_warning   = 80.0
      connection_recovery  = 75.0
      replica_lag          = 300.0
      replica_lag_warning  = 180.0
      replica_lag_recovery = 120.0
    }
    medium = {
      cpu_utilization      = 85.0
      cpu_warning          = 75.0
      cpu_recovery         = 65.0
      memory_utilization   = 85.0
      memory_warning       = 75.0
      memory_recovery      = 65.0
      disk_queue_depth     = 20.0
      disk_queue_warning   = 10.0
      disk_queue_recovery  = 7.0
      disk_free_storage    = 15.0
      disk_free_warning    = 25.0
      disk_free_recovery   = 30.0
      connection_count     = 80.0
      connection_warning   = 70.0
      connection_recovery  = 60.0
      replica_lag          = 180.0
      replica_lag_warning  = 90.0
      replica_lag_recovery = 60.0
    }
    high = {
      cpu_utilization      = 80.0
      cpu_warning          = 70.0
      cpu_recovery         = 60.0
      memory_utilization   = 80.0
      memory_warning       = 70.0
      memory_recovery      = 60.0
      disk_queue_depth     = 15.0
      disk_queue_warning   = 7.0
      disk_queue_recovery  = 5.0
      disk_free_storage    = 20.0
      disk_free_warning    = 30.0
      disk_free_recovery   = 35.0
      connection_count     = 70.0
      connection_warning   = 60.0
      connection_recovery  = 50.0
      replica_lag          = 60.0
      replica_lag_warning  = 30.0
      replica_lag_recovery = 15.0
    }
  }
}

resource "datadog_monitor" "rds_cpu_utilization" {
  name               = "${var.prefix}RDS CPU Utilization - ${var.db_instance_identifier}"
  type               = "query alert"
  message            = <<-EOT
    RDS instance ${var.db_instance_identifier} has high CPU utilization.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "RDS instance ${var.db_instance_identifier} continues to experience high CPU utilization!"

  query = "avg(${var.evaluation_period}):avg:aws.rds.cpuutilization{dbinstanceidentifier:${var.db_instance_identifier}} > ${local.thresholds[var.criticality].cpu_utilization}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].cpu_utilization
    warning           = local.thresholds[var.criticality].cpu_warning
    critical_recovery = local.thresholds[var.criticality].cpu_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "rds_memory_utilization" {
  name               = "${var.prefix}RDS Memory Utilization - ${var.db_instance_identifier}"
  type               = "query alert"
  message            = <<-EOT
    RDS instance ${var.db_instance_identifier} has high memory utilization.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "RDS instance ${var.db_instance_identifier} continues to experience high memory utilization!"

  query = "avg(${var.evaluation_period}):avg:aws.rds.freeable_memory{dbinstanceidentifier:${var.db_instance_identifier}} / avg:aws.rds.total_memory{dbinstanceidentifier:${var.db_instance_identifier}} * 100 < (100 - ${local.thresholds[var.criticality].memory_utilization})"

  monitor_thresholds {
    critical          = 100 - local.thresholds[var.criticality].memory_utilization
    warning           = 100 - local.thresholds[var.criticality].memory_warning
    critical_recovery = 100 - local.thresholds[var.criticality].memory_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "rds_disk_queue_depth" {
  name               = "${var.prefix}RDS Disk Queue Depth - ${var.db_instance_identifier}"
  type               = "query alert"
  message            = <<-EOT
    RDS instance ${var.db_instance_identifier} has a high disk queue depth. This indicates disk contention.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "RDS instance ${var.db_instance_identifier} continues to have high disk queue depth!"

  query = "avg(${var.evaluation_period}):avg:aws.rds.disk_queue_depth{dbinstanceidentifier:${var.db_instance_identifier}} > ${local.thresholds[var.criticality].disk_queue_depth}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].disk_queue_depth
    warning           = local.thresholds[var.criticality].disk_queue_warning
    critical_recovery = local.thresholds[var.criticality].disk_queue_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "rds_free_storage_space" {
  name               = "${var.prefix}RDS Free Storage Space - ${var.db_instance_identifier}"
  type               = "query alert"
  message            = <<-EOT
    RDS instance ${var.db_instance_identifier} is running low on free storage space.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "RDS instance ${var.db_instance_identifier} storage space is still critically low!"

  query = "avg(${var.evaluation_period}):avg:aws.rds.free_storage_space{dbinstanceidentifier:${var.db_instance_identifier}} / avg:aws.rds.total_storage_space{dbinstanceidentifier:${var.db_instance_identifier}} * 100 < ${local.thresholds[var.criticality].disk_free_storage}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].disk_free_storage
    warning           = local.thresholds[var.criticality].disk_free_warning
    critical_recovery = local.thresholds[var.criticality].disk_free_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "rds_connection_count" {
  name               = "${var.prefix}RDS Connection Count - ${var.db_instance_identifier}"
  type               = "query alert"
  message            = <<-EOT
    RDS instance ${var.db_instance_identifier} is nearing its maximum connection limit.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "RDS instance ${var.db_instance_identifier} is still nearing its maximum connection limit!"

  query = "avg(${var.evaluation_period}):avg:aws.rds.database_connections{dbinstanceidentifier:${var.db_instance_identifier}} / ${var.max_connections} * 100 > ${local.thresholds[var.criticality].connection_count}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].connection_count
    warning           = local.thresholds[var.criticality].connection_warning
    critical_recovery = local.thresholds[var.criticality].connection_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "rds_replica_lag" {
  count              = var.is_replica ? 1 : 0
  name               = "${var.prefix}RDS Replica Lag - ${var.db_instance_identifier}"
  type               = "query alert"
  message            = <<-EOT
    RDS read replica ${var.db_instance_identifier} has high replication lag.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "RDS read replica ${var.db_instance_identifier} still has high replication lag!"

  query = "avg(${var.evaluation_period}):avg:aws.rds.replica_lag{dbinstanceidentifier:${var.db_instance_identifier}} > ${local.thresholds[var.criticality].replica_lag}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].replica_lag
    warning           = local.thresholds[var.criticality].replica_lag_warning
    critical_recovery = local.thresholds[var.criticality].replica_lag_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

# Dashboard for RDS metrics
resource "datadog_dashboard" "rds_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for RDS Instance ${var.db_instance_identifier}"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "CPU Utilization (%)"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.rds.cpuutilization{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
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
        formula {
          formula_expression = "100 - (query0 / query1 * 100)"
          alias              = "Memory Utilization %"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.rds.freeable_memory{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
        query {
          metric_query {
            name        = "query1"
            query       = "avg:aws.rds.total_memory{dbinstanceidentifier:${var.db_instance_identifier}}"
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
      title = "Disk Queue Depth"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.rds.disk_queue_depth{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].disk_queue_depth
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].disk_queue_warning
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
      title = "Free Storage Space (%)"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0 / query1 * 100"
          alias              = "Free Storage %"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.rds.free_storage_space{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
        query {
          metric_query {
            name        = "query1"
            query       = "avg:aws.rds.total_storage_space{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].disk_free_storage
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].disk_free_warning
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
      title = "Connection Count"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
          alias              = "Current Connections"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.rds.database_connections{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = var.max_connections * local.thresholds[var.criticality].connection_count / 100.0
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = var.max_connections * local.thresholds[var.criticality].connection_warning / 100.0
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  dynamic "widget" {
    for_each = var.is_replica ? [1] : []
    content {
      timeseries_definition {
        title = "Replica Lag (seconds)"
        request {
          display_type = "line"
          formula {
            formula_expression = "query0"
          }
          query {
            metric_query {
              name        = "query0"
              query       = "avg:aws.rds.replica_lag{dbinstanceidentifier:${var.db_instance_identifier}}"
              data_source = "metrics"
            }
          }
        }
        marker {
          display_type = "error dashed"
          value        = local.thresholds[var.criticality].replica_lag
          label        = "Critical"
        }
        marker {
          display_type = "warning dashed"
          value        = local.thresholds[var.criticality].replica_lag_warning
          label        = "Warning"
        }
        yaxis {
          include_zero = true
          scale        = "linear"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Read/Write IOPS"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
          alias              = "Read IOPS"
        }
        formula {
          formula_expression = "query1"
          alias              = "Write IOPS"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.rds.read_iops{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
        query {
          metric_query {
            name        = "query1"
            query       = "avg:aws.rds.write_iops{dbinstanceidentifier:${var.db_instance_identifier}}"
            data_source = "metrics"
          }
        }
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  template_variable {
    name   = "db_instance"
    prefix = "dbinstanceidentifier"
  }

  template_variable_preset {
    name = "Default"

    template_variable {
      name  = "db_instance"
      value = var.db_instance_identifier
    }
  }

  tags = concat(var.tags, ["rds:${var.db_instance_identifier}", "managed_by:terraform"])
}