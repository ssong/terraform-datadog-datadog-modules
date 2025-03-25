locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }
  
  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - Lambda Function: ${var.lambda_function_name}" : ""

  thresholds = {
    low = {
      error_rate           = 10.0
      error_rate_warning   = 5.0
      duration_p90         = 5000
      duration_p90_warning = 3000
      throttles            = 10.0
      throttles_warning    = 5.0
      invocation_drop      = 50.0
      invocation_warning   = 30.0
      concurrent_limit     = 80.0
      concurrent_warning   = 70.0
    }
    medium = {
      error_rate           = 5.0
      error_rate_warning   = 2.0
      duration_p90         = 3000
      duration_p90_warning = 2000
      throttles            = 5.0
      throttles_warning    = 2.0
      invocation_drop      = 30.0
      invocation_warning   = 15.0
      concurrent_limit     = 70.0
      concurrent_warning   = 60.0
    }
    high = {
      error_rate           = 2.0
      error_rate_warning   = 1.0
      duration_p90         = 1000
      duration_p90_warning = 800
      throttles            = 2.0
      throttles_warning    = 1.0
      invocation_drop      = 15.0
      invocation_warning   = 10.0
      concurrent_limit     = 60.0
      concurrent_warning   = 50.0
    }
  }
}

resource "datadog_monitor" "lambda_error_rate" {
  name               = "${var.prefix}Lambda Error Rate - ${var.lambda_function_name}"
  type               = "query alert"
  message            = <<-EOT
    Lambda function ${var.lambda_function_name} is experiencing a high error rate.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "Lambda ${var.lambda_function_name} continues to experience high error rates!"

  query = "sum(${var.evaluation_period}):100 * (avg:aws.lambda.errors{aws_function_name:${var.lambda_function_name}} / avg:aws.lambda.invocations{aws_function_name:${var.lambda_function_name}}) > ${local.thresholds[var.criticality].error_rate}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].error_rate
    warning  = local.thresholds[var.criticality].error_rate_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["lambda:${var.lambda_function_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "lambda_duration" {
  name               = "${var.prefix}Lambda Duration P90 - ${var.lambda_function_name}"
  type               = "query alert"
  message            = <<-EOT
    Lambda function ${var.lambda_function_name} is experiencing high execution times.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "Lambda ${var.lambda_function_name} continues to experience high execution times!"

  query = "avg(${var.evaluation_period}):p90:aws.lambda.duration{aws_function_name:${var.lambda_function_name}} > ${local.thresholds[var.criticality].duration_p90}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].duration_p90
    warning  = local.thresholds[var.criticality].duration_p90_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["lambda:${var.lambda_function_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "lambda_throttles" {
  name               = "${var.prefix}Lambda Throttles - ${var.lambda_function_name}"
  type               = "query alert"
  message            = <<-EOT
    Lambda function ${var.lambda_function_name} is being throttled.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "Lambda ${var.lambda_function_name} continues to be throttled!"

  query = "sum(${var.evaluation_period}):avg:aws.lambda.throttles{aws_function_name:${var.lambda_function_name}} > ${local.thresholds[var.criticality].throttles}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].throttles
    warning  = local.thresholds[var.criticality].throttles_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["lambda:${var.lambda_function_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "lambda_invocation_drop" {
  name               = "${var.prefix}Lambda Invocation Drop - ${var.lambda_function_name}"
  type               = "query alert"
  message            = <<-EOT
    Lambda function ${var.lambda_function_name} invocations have dropped significantly.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "Lambda ${var.lambda_function_name} invocations continue to be below expected levels!"

  query = "pct_change(avg(${var.evaluation_period}),avg(${var.baseline_period})):avg:aws.lambda.invocations{aws_function_name:${var.lambda_function_name}} < -${local.thresholds[var.criticality].invocation_drop}"

  monitor_thresholds {
    critical = -1 * local.thresholds[var.criticality].invocation_drop
    warning  = -1 * local.thresholds[var.criticality].invocation_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["lambda:${var.lambda_function_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "lambda_concurrent_executions" {
  name               = "${var.prefix}Lambda Concurrent Executions - ${var.lambda_function_name}"
  type               = "query alert"
  message            = <<-EOT
    Lambda function ${var.lambda_function_name} is approaching concurrent execution limit.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "Lambda ${var.lambda_function_name} is still approaching concurrent execution limit!"

  query = "avg(${var.evaluation_period}):100 * (avg:aws.lambda.concurrent_executions{aws_function_name:${var.lambda_function_name}} / ${var.concurrent_execution_limit}) > ${local.thresholds[var.criticality].concurrent_limit}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].concurrent_limit
    warning  = local.thresholds[var.criticality].concurrent_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["lambda:${var.lambda_function_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

# Dashboard for Lambda metrics
resource "datadog_dashboard" "lambda_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for Lambda function ${var.lambda_function_name}"
  layout_type = "ordered"
  
  widget {
    timeseries_definition {
      title = "Invocations"
      request {
        q            = "avg:aws.lambda.invocations{aws_function_name:${var.lambda_function_name}}.as_count()"
        display_type = "line"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }
  
  widget {
    timeseries_definition {
      title = "Duration (p50, p90, p99)"
      request {
        q            = "p50:aws.lambda.duration{aws_function_name:${var.lambda_function_name}}"
        display_type = "line"
      }
      request {
        q            = "p90:aws.lambda.duration{aws_function_name:${var.lambda_function_name}}"
        display_type = "line"
      }
      request {
        q            = "p99:aws.lambda.duration{aws_function_name:${var.lambda_function_name}}"
        display_type = "line"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }
  
  widget {
    timeseries_definition {
      title = "Error Rate (%)"
      request {
        q            = "100 * (sum:aws.lambda.errors{aws_function_name:${var.lambda_function_name}}.as_count() / sum:aws.lambda.invocations{aws_function_name:${var.lambda_function_name}}.as_count())"
        display_type = "line"
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].error_rate}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].error_rate_warning}"
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
      title = "Throttles"
      request {
        q            = "avg:aws.lambda.throttles{aws_function_name:${var.lambda_function_name}}.as_count()"
        display_type = "line"
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].throttles}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].throttles_warning}"
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
      title = "Concurrent Executions"
      request {
        q            = "avg:aws.lambda.concurrent_executions{aws_function_name:${var.lambda_function_name}}"
        display_type = "line"
      }
      request {
        q            = "${var.concurrent_execution_limit}"
        display_type = "line"
        style {
          line_type  = "dashed"
          line_width = "thin"
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
      title = "Memory Utilization"
      request {
        q            = "avg:aws.lambda.enhanced.memory_utilization{aws_function_name:${var.lambda_function_name}}"
        display_type = "line"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
        max          = "100"
      }
    }
  }
  
  template_variable {
    name    = "function"
    prefix  = "aws_function_name"
    default = var.lambda_function_name
  }
  
  template_variable_preset {
    name = "Default"
    
    template_variable {
      name  = "function"
      value = var.lambda_function_name
    }
  }
  
  tags = concat(var.tags, ["lambda:${var.lambda_function_name}", "managed_by:terraform"])
}