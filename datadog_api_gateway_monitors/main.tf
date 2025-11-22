locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }

  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - API Gateway: ${var.api_gateway_name}" : ""

  thresholds = {
    low = {
      error_rate            = 10.0
      warning_rate          = 5.0
      error_rate_recovery   = 9.0
      warning_rate_recovery = 4.0
      server_error_rate     = 5.0
      server_error_warning  = 2.0
      server_error_recovery = 1.5
      latency_p90           = 5000
      latency_p90_warning   = 3000
      latency_p90_recovery  = 2500
      count_drop            = 50.0
      count_warning         = 30.0
      count_recovery        = 25.0
      throttles             = 10.0
      throttles_warning     = 5.0
      throttles_recovery    = 3.0
      integration_latency   = 3000
      integration_warning   = 2000
      integration_recovery  = 1500
    }
    medium = {
      error_rate            = 5.0
      warning_rate          = 2.0
      error_rate_recovery   = 4.5
      warning_rate_recovery = 1.5
      server_error_rate     = 2.0
      server_error_warning  = 1.0
      server_error_recovery = 0.75
      latency_p90           = 3000
      latency_p90_warning   = 2000
      latency_p90_recovery  = 1500
      count_drop            = 30.0
      count_warning         = 15.0
      count_recovery        = 10.0
      throttles             = 5.0
      throttles_warning     = 2.0
      throttles_recovery    = 1.0
      integration_latency   = 2000
      integration_warning   = 1000
      integration_recovery  = 750
    }
    high = {
      error_rate            = 2.0
      warning_rate          = 1.0
      error_rate_recovery   = 1.5
      warning_rate_recovery = 0.5
      server_error_rate     = 1.0
      server_error_warning  = 0.5
      server_error_recovery = 0.25
      latency_p90           = 1000
      latency_p90_warning   = 800
      latency_p90_recovery  = 600
      count_drop            = 15.0
      count_warning         = 10.0
      count_recovery        = 5.0
      throttles             = 2.0
      throttles_warning     = 1.0
      throttles_recovery    = 0.5
      integration_latency   = 1000
      integration_warning   = 500
      integration_recovery  = 300
    }
  }
}

resource "datadog_monitor" "api_gateway_error_rate" {
  name               = "${var.prefix}API Gateway 4xx/5xx Error Rate - ${var.api_gateway_name}"
  type               = "query alert"
  message            = <<-EOT
    API Gateway ${var.api_gateway_name} is experiencing a high error rate.

    Notify: ${var.notification_target}
  EOT
  escalation_message = "API Gateway ${var.api_gateway_name} continues to experience high error rates!"

  query = "sum(${var.evaluation_period}):100 * (sum:aws.apigateway.5xxerror{apiname:${var.api_gateway_name}} + sum:aws.apigateway.4xxerror{apiname:${var.api_gateway_name}}) / sum:aws.apigateway.count{apiname:${var.api_gateway_name}} > ${local.thresholds[var.criticality].error_rate}"

  monitor_thresholds {
    critical         = local.thresholds[var.criticality].error_rate
    warning          = local.thresholds[var.criticality].warning_rate
    warning_recovery = local.thresholds[var.criticality].warning_rate_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["api_gateway:${var.api_gateway_name}", "managed_by:terraform", "team:${var.team}"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "api_gateway_5xx_error_rate" {
  name               = "${var.prefix}API Gateway 5xx Server Error Rate - ${var.api_gateway_name}"
  type               = "query alert"
  message            = <<-EOT
    API Gateway ${var.api_gateway_name} is experiencing a high 5xx server error rate.
    This indicates server-side issues that require immediate attention.

    Notify: ${var.notification_target}
  EOT
  escalation_message = "API Gateway ${var.api_gateway_name} continues to experience high 5xx server error rates!"

  query = "sum(${var.evaluation_period}):100 * sum:aws.apigateway.5xxerror{apiname:${var.api_gateway_name}} / sum:aws.apigateway.count{apiname:${var.api_gateway_name}} > ${local.thresholds[var.criticality].server_error_rate}"

  monitor_thresholds {
    critical         = local.thresholds[var.criticality].server_error_rate
    warning          = local.thresholds[var.criticality].server_error_warning
    warning_recovery = local.thresholds[var.criticality].server_error_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["api_gateway:${var.api_gateway_name}", "managed_by:terraform", "team:${var.team}", "error_type:5xx"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "api_gateway_latency" {
  name               = "${var.prefix}API Gateway Latency P90 - ${var.api_gateway_name}"
  type               = "query alert"
  message            = <<-EOT
    API Gateway ${var.api_gateway_name} is experiencing high latency.

    Notify: ${var.notification_target}
  EOT
  escalation_message = "API Gateway ${var.api_gateway_name} continues to experience high latency!"

  query = "avg(${var.evaluation_period}):p90:aws.apigateway.latency{apiname:${var.api_gateway_name}} > ${local.thresholds[var.criticality].latency_p90}"

  monitor_thresholds {
    critical         = local.thresholds[var.criticality].latency_p90
    warning          = local.thresholds[var.criticality].latency_p90_warning
    warning_recovery = local.thresholds[var.criticality].latency_p90_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["api_gateway:${var.api_gateway_name}", "managed_by:terraform", "team:${var.team}"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "api_gateway_count_drop" {
  name               = "${var.prefix}API Gateway Request Count Drop - ${var.api_gateway_name}"
  type               = "query alert"
  message            = <<-EOT
    API Gateway ${var.api_gateway_name} request count has dropped significantly.

    Notify: ${var.notification_target}
  EOT
  escalation_message = "API Gateway ${var.api_gateway_name} request count continues to be below expected levels!"

  query = "pct_change(avg(${var.evaluation_period}),avg(${var.baseline_period})):sum:aws.apigateway.count{apiname:${var.api_gateway_name}} < -${local.thresholds[var.criticality].count_drop}"

  monitor_thresholds {
    critical         = -1 * local.thresholds[var.criticality].count_drop
    warning          = -1 * local.thresholds[var.criticality].count_warning
    warning_recovery = -1 * local.thresholds[var.criticality].count_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["api_gateway:${var.api_gateway_name}", "managed_by:terraform", "team:${var.team}"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "api_gateway_throttles" {
  name               = "${var.prefix}API Gateway Throttles - ${var.api_gateway_name}"
  type               = "query alert"
  message            = <<-EOT
    API Gateway ${var.api_gateway_name} is being throttled.

    Notify: ${var.notification_target}
  EOT
  escalation_message = "API Gateway ${var.api_gateway_name} continues to be throttled!"

  query = "sum(${var.evaluation_period}):sum:aws.apigateway.throttlecount{apiname:${var.api_gateway_name}} > ${local.thresholds[var.criticality].throttles}"

  monitor_thresholds {
    critical         = local.thresholds[var.criticality].throttles
    warning          = local.thresholds[var.criticality].throttles_warning
    warning_recovery = local.thresholds[var.criticality].throttles_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["api_gateway:${var.api_gateway_name}", "managed_by:terraform", "team:${var.team}"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "api_gateway_integration_latency" {
  name               = "${var.prefix}API Gateway Integration Latency - ${var.api_gateway_name}"
  type               = "query alert"
  message            = <<-EOT
    API Gateway ${var.api_gateway_name} is experiencing high integration latency.

    Notify: ${var.notification_target}
  EOT
  escalation_message = "API Gateway ${var.api_gateway_name} continues to experience high integration latency!"

  query = "avg(${var.evaluation_period}):avg:aws.apigateway.integration_latency{apiname:${var.api_gateway_name}} > ${local.thresholds[var.criticality].integration_latency}"

  monitor_thresholds {
    critical         = local.thresholds[var.criticality].integration_latency
    warning          = local.thresholds[var.criticality].integration_warning
    warning_recovery = local.thresholds[var.criticality].integration_recovery
  }

  include_tags = true
  tags         = concat(var.tags, ["api_gateway:${var.api_gateway_name}", "managed_by:terraform", "team:${var.team}"])

  priority = local.priorities[var.criticality]
}

# Dashboard for API Gateway metrics
resource "datadog_dashboard" "api_gateway_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for API Gateway ${var.api_gateway_name}"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "Request Count"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
        }
        queries {
          name        = "query0"
          query       = "sum:aws.apigateway.count{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
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
      title = "Latency (p50, p90, p99)"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
          alias   = "p50"
        }
        formulas {
          formula = "query1"
          alias   = "p90"
        }
        formulas {
          formula = "query2"
          alias   = "p99"
        }
        queries {
          name        = "query0"
          query       = "p50:aws.apigateway.latency{apiname:${var.api_gateway_name}}"
          data_source = "metrics"
        }
        queries {
          name        = "query1"
          query       = "p90:aws.apigateway.latency{apiname:${var.api_gateway_name}}"
          data_source = "metrics"
        }
        queries {
          name        = "query2"
          query       = "p99:aws.apigateway.latency{apiname:${var.api_gateway_name}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].latency_p90
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].latency_p90_warning
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
      title = "Integration Latency"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
        }
        queries {
          name        = "query0"
          query       = "avg:aws.apigateway.integration_latency{apiname:${var.api_gateway_name}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].integration_latency
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].integration_warning
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
      title = "Error Rate (%) - 4xx/5xx"
      request {
        display_type = "line"
        formulas {
          formula = "100 * (query0 + query1) / query2"
          alias   = "Error Rate %"
        }
        queries {
          name        = "query0"
          query       = "sum:aws.apigateway.5xxerror{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
        }
        queries {
          name        = "query1"
          query       = "sum:aws.apigateway.4xxerror{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
        }
        queries {
          name        = "query2"
          query       = "sum:aws.apigateway.count{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].error_rate
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].warning_rate
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
      title = "4xx vs 5xx Errors"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
          alias   = "4xx errors"
        }
        formulas {
          formula = "query1"
          alias   = "5xx errors"
        }
        queries {
          name        = "query0"
          query       = "sum:aws.apigateway.4xxerror{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
        }
        queries {
          name        = "query1"
          query       = "sum:aws.apigateway.5xxerror{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
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
      title = "Throttle Count"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
        }
        queries {
          name        = "query0"
          query       = "sum:aws.apigateway.throttlecount{apiname:${var.api_gateway_name}}.as_count()"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = local.thresholds[var.criticality].throttles
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = local.thresholds[var.criticality].throttles_warning
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }

  template_variable {
    name     = "apigateway"
    prefix   = "apiname"
    defaults = [var.api_gateway_name]
  }

  template_variable_preset {
    name = "Default"

    template_variable {
      name   = "apigateway"
      values = [var.api_gateway_name]
    }
  }

  tags = concat(var.tags, ["team:${var.team}"])
}
