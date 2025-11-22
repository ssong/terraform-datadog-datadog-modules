locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }

  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - DynamoDB Table: ${var.table_name}" : ""

  thresholds = {
    low = {
      read_throttle_events       = 50.0
      read_throttle_warning      = 25.0
      read_throttle_recovery     = 15.0
      write_throttle_events      = 50.0
      write_throttle_warning     = 25.0
      write_throttle_recovery    = 15.0
      consumed_read_capacity     = 85.0
      consumed_read_warning      = 75.0
      consumed_read_recovery     = 70.0
      consumed_write_capacity    = 85.0
      consumed_write_warning     = 75.0
      consumed_write_recovery    = 70.0
      system_errors              = 10.0
      system_errors_warning      = 5.0
      system_errors_recovery     = 3.0
      conditional_check_failed   = 25.0
      conditional_check_warning  = 15.0
      conditional_check_recovery = 10.0
    }
    medium = {
      read_throttle_events       = 25.0
      read_throttle_warning      = 10.0
      read_throttle_recovery     = 7.0
      write_throttle_events      = 25.0
      write_throttle_warning     = 10.0
      write_throttle_recovery    = 7.0
      consumed_read_capacity     = 75.0
      consumed_read_warning      = 65.0
      consumed_read_recovery     = 60.0
      consumed_write_capacity    = 75.0
      consumed_write_warning     = 65.0
      consumed_write_recovery    = 60.0
      system_errors              = 5.0
      system_errors_warning      = 2.0
      system_errors_recovery     = 1.0
      conditional_check_failed   = 15.0
      conditional_check_warning  = 7.0
      conditional_check_recovery = 5.0
    }
    high = {
      read_throttle_events       = 10.0
      read_throttle_warning      = 5.0
      read_throttle_recovery     = 3.0
      write_throttle_events      = 10.0
      write_throttle_warning     = 5.0
      write_throttle_recovery    = 3.0
      consumed_read_capacity     = 70.0
      consumed_read_warning      = 60.0
      consumed_read_recovery     = 55.0
      consumed_write_capacity    = 70.0
      consumed_write_warning     = 60.0
      consumed_write_recovery    = 55.0
      system_errors              = 2.0
      system_errors_warning      = 1.0
      system_errors_recovery     = 0.5
      conditional_check_failed   = 10.0
      conditional_check_warning  = 5.0
      conditional_check_recovery = 3.0
    }
  }
}

resource "datadog_monitor" "dynamodb_read_throttle_events" {
  name               = "${var.prefix}DynamoDB Read Throttle Events - ${var.table_name}"
  type               = "query alert"
  message            = <<-EOT
    DynamoDB table ${var.table_name} is experiencing read throttle events.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "DynamoDB table ${var.table_name} continues to experience read throttle events!"

  query = "avg(${var.evaluation_period}):avg:aws.dynamodb.read_throttle_events{tablename:${var.table_name}} > ${local.thresholds[var.criticality].read_throttle_events}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].read_throttle_events
    warning           = local.thresholds[var.criticality].read_throttle_warning
    critical_recovery = local.thresholds[var.criticality].read_throttle_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "dynamodb_write_throttle_events" {
  name               = "${var.prefix}DynamoDB Write Throttle Events - ${var.table_name}"
  type               = "query alert"
  message            = <<-EOT
    DynamoDB table ${var.table_name} is experiencing write throttle events.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "DynamoDB table ${var.table_name} continues to experience write throttle events!"

  query = "avg(${var.evaluation_period}):avg:aws.dynamodb.write_throttle_events{tablename:${var.table_name}} > ${local.thresholds[var.criticality].write_throttle_events}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].write_throttle_events
    warning           = local.thresholds[var.criticality].write_throttle_warning
    critical_recovery = local.thresholds[var.criticality].write_throttle_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "dynamodb_consumed_read_capacity" {
  count              = var.provisioned_capacity ? 1 : 0
  name               = "${var.prefix}DynamoDB Consumed Read Capacity - ${var.table_name}"
  type               = "query alert"
  message            = <<-EOT
    DynamoDB table ${var.table_name} is consuming high read capacity units.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "DynamoDB table ${var.table_name} continues to consume high read capacity units!"

  query = "avg(${var.evaluation_period}):avg:aws.dynamodb.consumed_read_capacity_units{tablename:${var.table_name}} / ${var.read_capacity_units} * 100 > ${local.thresholds[var.criticality].consumed_read_capacity}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].consumed_read_capacity
    warning           = local.thresholds[var.criticality].consumed_read_warning
    critical_recovery = local.thresholds[var.criticality].consumed_read_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "dynamodb_consumed_write_capacity" {
  count              = var.provisioned_capacity ? 1 : 0
  name               = "${var.prefix}DynamoDB Consumed Write Capacity - ${var.table_name}"
  type               = "query alert"
  message            = <<-EOT
    DynamoDB table ${var.table_name} is consuming high write capacity units.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "DynamoDB table ${var.table_name} continues to consume high write capacity units!"

  query = "avg(${var.evaluation_period}):avg:aws.dynamodb.consumed_write_capacity_units{tablename:${var.table_name}} / ${var.write_capacity_units} * 100 > ${local.thresholds[var.criticality].consumed_write_capacity}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].consumed_write_capacity
    warning           = local.thresholds[var.criticality].consumed_write_warning
    critical_recovery = local.thresholds[var.criticality].consumed_write_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "dynamodb_system_errors" {
  name               = "${var.prefix}DynamoDB System Errors - ${var.table_name}"
  type               = "query alert"
  message            = <<-EOT
    DynamoDB table ${var.table_name} is experiencing system errors.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "DynamoDB table ${var.table_name} continues to experience system errors!"

  query = "avg(${var.evaluation_period}):avg:aws.dynamodb.system_errors{tablename:${var.table_name}} > ${local.thresholds[var.criticality].system_errors}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].system_errors
    warning           = local.thresholds[var.criticality].system_errors_warning
    critical_recovery = local.thresholds[var.criticality].system_errors_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "dynamodb_conditional_check_failed" {
  name               = "${var.prefix}DynamoDB Conditional Check Failed - ${var.table_name}"
  type               = "query alert"
  message            = <<-EOT
    DynamoDB table ${var.table_name} has a high rate of conditional check failures.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "DynamoDB table ${var.table_name} continues to have a high rate of conditional check failures!"

  query = "avg(${var.evaluation_period}):avg:aws.dynamodb.conditional_check_failed_requests{tablename:${var.table_name}} > ${local.thresholds[var.criticality].conditional_check_failed}"

  monitor_thresholds {
    critical          = local.thresholds[var.criticality].conditional_check_failed
    warning           = local.thresholds[var.criticality].conditional_check_warning
    critical_recovery = local.thresholds[var.criticality].conditional_check_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

# Dashboard for DynamoDB metrics
resource "datadog_dashboard" "dynamodb_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for DynamoDB Table ${var.table_name}"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "Read Throttle Events"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.dynamodb.read_throttle_events{tablename:${var.table_name}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].read_throttle_events
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].read_throttle_warning
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
      title = "Write Throttle Events"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.dynamodb.write_throttle_events{tablename:${var.table_name}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].write_throttle_events
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].write_throttle_warning
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
      title = "Consumed Read Capacity Units"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
          alias              = "Consumed RCU"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.dynamodb.consumed_read_capacity_units{tablename:${var.table_name}}"
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

  widget {
    timeseries_definition {
      title = "Consumed Write Capacity Units"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
          alias              = "Consumed WCU"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.dynamodb.consumed_write_capacity_units{tablename:${var.table_name}}"
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

  widget {
    timeseries_definition {
      title = "System Errors"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.dynamodb.system_errors{tablename:${var.table_name}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].system_errors
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].system_errors_warning
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
      title = "Conditional Check Failed Requests"
      request {
        display_type = "line"
        formula {
          formula_expression = "query0"
        }
        query {
          metric_query {
            name        = "query0"
            query       = "avg:aws.dynamodb.conditional_check_failed_requests{tablename:${var.table_name}}"
            data_source = "metrics"
          }
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].conditional_check_failed
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].conditional_check_warning
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  template_variable {
    name   = "table"
    prefix = "tablename"
  }

  template_variable_preset {
    name = "Default"

    template_variable {
      name  = "table"
      value = var.table_name
    }
  }

  tags = concat(var.tags, ["dynamodb:${var.table_name}", "managed_by:terraform"])
}