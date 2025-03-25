locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }
  
  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - SQS Queue: ${var.queue_name}" : ""

  thresholds = {
    low = {
      age_max               = 3600
      age_warning           = 1800
      approximate_count     = 10000
      approximate_warning   = 5000
      no_messages           = 180
      no_messages_warning   = 120
      error_rate            = 10.0
      error_rate_warning    = 5.0
      throughput_drop       = 50.0
      throughput_warning    = 30.0
    }
    medium = {
      age_max               = 1800
      age_warning           = 900
      approximate_count     = 5000
      approximate_warning   = 3000
      no_messages           = 120
      no_messages_warning   = 60
      error_rate            = 5.0
      error_rate_warning    = 2.0
      throughput_drop       = 30.0
      throughput_warning    = 15.0
    }
    high = {
      age_max               = 900
      age_warning           = 600
      approximate_count     = 2000
      approximate_warning   = 1000
      no_messages           = 60
      no_messages_warning   = 30
      error_rate            = 2.0
      error_rate_warning    = 1.0
      throughput_drop       = 15.0
      throughput_warning    = 10.0
    }
  }
}

resource "datadog_monitor" "sqs_age_max" {
  name               = "${var.prefix}SQS Max Age - ${var.queue_name}"
  type               = "query alert"
  message            = <<-EOT
    SQS Queue ${var.queue_name} has messages with high age. Messages are taking too long to process.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "SQS Queue ${var.queue_name} still has messages with high age!"

  query = "max(${var.evaluation_period}):avg:aws.sqs.approximate_age_of_oldest_message{queue_name:${var.queue_name}} > ${local.thresholds[var.criticality].age_max}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].age_max
    warning  = local.thresholds[var.criticality].age_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["sqs:${var.queue_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "sqs_approximate_count" {
  name               = "${var.prefix}SQS Queue Depth - ${var.queue_name}"
  type               = "query alert"
  message            = <<-EOT
    SQS Queue ${var.queue_name} has too many messages waiting to be processed.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "SQS Queue ${var.queue_name} still has too many messages waiting to be processed!"

  query = "avg(${var.evaluation_period}):avg:aws.sqs.approximate_number_of_messages_visible{queue_name:${var.queue_name}} > ${local.thresholds[var.criticality].approximate_count}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].approximate_count
    warning  = local.thresholds[var.criticality].approximate_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["sqs:${var.queue_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "sqs_no_messages" {
  name               = "${var.prefix}SQS No Messages - ${var.queue_name}"
  type               = "query alert"
  message            = <<-EOT
    SQS Queue ${var.queue_name} has not received any messages for an extended period.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "SQS Queue ${var.queue_name} is still not receiving messages!"

  query = "${var.evaluation_period}:sum:aws.sqs.number_of_messages_sent{queue_name:${var.queue_name}}.as_count() == 0"

  monitor_threshold_windows {
    trigger_window  = "${local.thresholds[var.criticality].no_messages}m"
    recovery_window = "${local.thresholds[var.criticality].no_messages_warning}m"
  }

  include_tags = true
  tags         = concat(var.tags, ["sqs:${var.queue_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "sqs_error_rate" {
  name               = "${var.prefix}SQS Error Rate - ${var.queue_name}"
  type               = "query alert"
  message            = <<-EOT
    SQS Queue ${var.queue_name} is experiencing a high error rate for message deliveries.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "SQS Queue ${var.queue_name} continues to experience high error rates for message deliveries!"

  query = "sum(${var.evaluation_period}):100 * (sum:aws.sqs.number_of_messages_received_not_valid{queue_name:${var.queue_name}}.as_count() / sum:aws.sqs.number_of_messages_received{queue_name:${var.queue_name}}.as_count()) > ${local.thresholds[var.criticality].error_rate}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].error_rate
    warning  = local.thresholds[var.criticality].error_rate_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["sqs:${var.queue_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "sqs_throughput_drop" {
  name               = "${var.prefix}SQS Throughput Drop - ${var.queue_name}"
  type               = "query alert"
  message            = <<-EOT
    SQS Queue ${var.queue_name} throughput has dropped significantly.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "SQS Queue ${var.queue_name} throughput continues to be below expected levels!"

  query = "pct_change(avg(${var.evaluation_period}),avg(${var.baseline_period})):sum:aws.sqs.number_of_messages_received{queue_name:${var.queue_name}}.as_count() < -${local.thresholds[var.criticality].throughput_drop}"

  monitor_thresholds {
    critical = -1 * local.thresholds[var.criticality].throughput_drop
    warning  = -1 * local.thresholds[var.criticality].throughput_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["sqs:${var.queue_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

# Dashboard for SQS metrics
resource "datadog_dashboard" "sqs_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for SQS Queue ${var.queue_name}"
  layout_type = "ordered"
  
  widget {
    timeseries_definition {
      title = "Messages Sent vs Received"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
          alias = "Messages Sent"
        }
        formulas {
          formula = "query1"
          alias = "Messages Received"
        }
        queries {
          name    = "query0"
          query   = "sum:aws.sqs.number_of_messages_sent{queue_name:${var.queue_name}}.as_count()"
          data_source = "metrics"
        }
        queries {
          name    = "query1"
          query   = "sum:aws.sqs.number_of_messages_received{queue_name:${var.queue_name}}.as_count()"
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
      title = "Queue Depth (Visible, Not Visible, Delayed)"
      request {
        display_type = "line"
        formulas {
          formula = "query0"
          alias = "Visible Messages"
        }
        formulas {
          formula = "query1"
          alias = "Not Visible Messages"
        }
        formulas {
          formula = "query2"
          alias = "Delayed Messages"
        }
        queries {
          name    = "query0"
          query   = "avg:aws.sqs.approximate_number_of_messages_visible{queue_name:${var.queue_name}}"
          data_source = "metrics"
        }
        queries {
          name    = "query1"
          query   = "avg:aws.sqs.approximate_number_of_messages_not_visible{queue_name:${var.queue_name}}"
          data_source = "metrics"
        }
        queries {
          name    = "query2"
          query   = "avg:aws.sqs.approximate_number_of_messages_delayed{queue_name:${var.queue_name}}"
          data_source = "metrics"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].approximate_count}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].approximate_warning}"
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
      title = "Age of Oldest Message (seconds)"
      request {
        q            = "avg:aws.sqs.approximate_age_of_oldest_message{queue_name:${var.queue_name}}"
        display_type = "line"
        metadata {
          expression = "avg:aws.sqs.approximate_age_of_oldest_message{queue_name:${var.queue_name}}"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].age_max}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].age_warning}"
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
      title = "Message Reception Error Rate (%)"
      request {
        q            = "100 * (sum:aws.sqs.number_of_messages_received_not_valid{queue_name:${var.queue_name}}.as_count() / sum:aws.sqs.number_of_messages_received{queue_name:${var.queue_name}}.as_count())"
        display_type = "line"
        metadata {
          expression = "100 * (sum:aws.sqs.number_of_messages_received_not_valid{queue_name:${var.queue_name}}.as_count() / sum:aws.sqs.number_of_messages_received{queue_name:${var.queue_name}}.as_count())"
        }
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
      title = "Messages Deleted"
      request {
        q            = "sum:aws.sqs.number_of_messages_deleted{queue_name:${var.queue_name}}.as_count()"
        display_type = "line"
        metadata {
          expression = "sum:aws.sqs.number_of_messages_deleted{queue_name:${var.queue_name}}.as_count()"
        }
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }
  
  template_variable {
    name    = "queue"
    prefix  = "queue_name"
  }
  
  template_variable_preset {
    name = "Default"
    
    template_variable {
      name  = "queue"
      value = var.queue_name
    }
  }
  
  tags = concat(var.tags, ["sqs:${var.queue_name}", "managed_by:terraform"])
}