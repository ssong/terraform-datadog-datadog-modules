locals {
  priorities = {
    low    = 3
    medium = 2
    high   = 1
  }
  
  dashboard_title_prefix = var.create_dashboard ? "${var.dashboard_name_prefix} - ECS Service: ${var.cluster_name}/${var.service_name}" : ""

  thresholds = {
    low = {
      cpu_utilization         = 90.0
      cpu_warning             = 80.0
      memory_utilization      = 90.0
      memory_warning          = 80.0
      task_count_deviation    = 30.0
      task_deviation_warning  = 20.0
      service_failures        = 5
      service_failures_warning = 3
      container_restarts      = 5
      container_restarts_warning = 3
    }
    medium = {
      cpu_utilization         = 85.0
      cpu_warning             = 75.0
      memory_utilization      = 85.0
      memory_warning          = 75.0
      task_count_deviation    = 20.0
      task_deviation_warning  = 10.0
      service_failures        = 3
      service_failures_warning = 2
      container_restarts      = 3
      container_restarts_warning = 2
    }
    high = {
      cpu_utilization         = 80.0
      cpu_warning             = 70.0
      memory_utilization      = 80.0
      memory_warning          = 70.0
      task_count_deviation    = 10.0
      task_deviation_warning  = 5.0
      service_failures        = 2
      service_failures_warning = 1
      container_restarts      = 2
      container_restarts_warning = 1
    }
  }
}

resource "datadog_monitor" "ecs_cpu_utilization" {
  name               = "${var.prefix}ECS CPU Utilization - ${var.cluster_name}/${var.service_name}"
  type               = "query alert"
  message            = <<-EOT
    ECS Service ${var.service_name} in cluster ${var.cluster_name} has high CPU utilization.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ECS Service ${var.service_name} continues to experience high CPU utilization!"

  query = "avg(${var.evaluation_period}):avg:aws.ecs.service.cpu_utilization{cluster_name:${var.cluster_name},servicename:${var.service_name}} > ${local.thresholds[var.criticality].cpu_utilization}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].cpu_utilization
    warning  = local.thresholds[var.criticality].cpu_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["cluster:${var.cluster_name}", "service:${var.service_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "ecs_memory_utilization" {
  name               = "${var.prefix}ECS Memory Utilization - ${var.cluster_name}/${var.service_name}"
  type               = "query alert"
  message            = <<-EOT
    ECS Service ${var.service_name} in cluster ${var.cluster_name} has high memory utilization.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ECS Service ${var.service_name} continues to experience high memory utilization!"

  query = "avg(${var.evaluation_period}):avg:aws.ecs.service.memory_utilization{cluster_name:${var.cluster_name},servicename:${var.service_name}} > ${local.thresholds[var.criticality].memory_utilization}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].memory_utilization
    warning  = local.thresholds[var.criticality].memory_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["cluster:${var.cluster_name}", "service:${var.service_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "ecs_task_count_deviation" {
  name               = "${var.prefix}ECS Task Count Deviation - ${var.cluster_name}/${var.service_name}"
  type               = "query alert"
  message            = <<-EOT
    ECS Service ${var.service_name} in cluster ${var.cluster_name} has a significant difference between desired and running task count.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ECS Service ${var.service_name} still has a significant task count deviation!"

  query = "avg(${var.evaluation_period}):100 * abs(avg:aws.ecs.service.running{cluster_name:${var.cluster_name},servicename:${var.service_name}} - avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}) / max(avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}, 1) > ${local.thresholds[var.criticality].task_count_deviation}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].task_count_deviation
    warning  = local.thresholds[var.criticality].task_deviation_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["cluster:${var.cluster_name}", "service:${var.service_name}", "managed_by:terraform"])

  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "ecs_service_failures" {
  name               = "${var.prefix}ECS Service Failures - ${var.cluster_name}/${var.service_name}"
  type               = "query alert"
  message            = <<-EOT
    ECS Service ${var.service_name} in cluster ${var.cluster_name} is experiencing deployment failures.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ECS Service ${var.service_name} continues to experience deployment failures!"

  query = "sum(${var.evaluation_period}):sum:aws.ecs.service.deployment_failures{cluster_name:${var.cluster_name},servicename:${var.service_name}}.as_count() > ${local.thresholds[var.criticality].service_failures}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].service_failures
    warning  = local.thresholds[var.criticality].service_failures_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["cluster:${var.cluster_name}", "service:${var.service_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

resource "datadog_monitor" "ecs_container_restarts" {
  name               = "${var.prefix}ECS Container Restarts - ${var.cluster_name}/${var.service_name}"
  type               = "query alert"
  message            = <<-EOT
    ECS Service ${var.service_name} in cluster ${var.cluster_name} has containers frequently restarting.
    
    Notify: ${var.notification_target}
  EOT
  escalation_message = "ECS Service ${var.service_name} containers continue to restart frequently!"

  query = "sum(${var.evaluation_period}):derivative(avg:aws.ecs.containerinsights.restarts{cluster_name:${var.cluster_name},service_name:${var.service_name}}) > ${local.thresholds[var.criticality].container_restarts}"

  monitor_thresholds {
    critical = local.thresholds[var.criticality].container_restarts
    warning  = local.thresholds[var.criticality].container_restarts_warning
  }

  include_tags = true
  tags         = concat(var.tags, ["cluster:${var.cluster_name}", "service:${var.service_name}", "managed_by:terraform"])
  
  priority = local.priorities[var.criticality]
}

# Dashboard for ECS metrics
resource "datadog_dashboard" "ecs_dashboard" {
  count       = var.create_dashboard ? 1 : 0
  title       = local.dashboard_title_prefix
  description = "Dashboard for ECS Service ${var.service_name} in cluster ${var.cluster_name}"
  layout_type = "ordered"
  
  widget {
    timeseries_definition {
      title = "CPU Utilization (%)"
      request {
        q            = "avg:aws.ecs.service.cpu_utilization{cluster_name:${var.cluster_name},servicename:${var.service_name}}"
        display_type = "line"
        metadata {
          expression = "avg:aws.ecs.service.cpu_utilization{cluster_name:${var.cluster_name},servicename:${var.service_name}}"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].cpu_utilization}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].cpu_warning}"
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
        q            = "avg:aws.ecs.service.memory_utilization{cluster_name:${var.cluster_name},servicename:${var.service_name}}"
        display_type = "line"
        metadata {
          expression = "avg:aws.ecs.service.memory_utilization{cluster_name:${var.cluster_name},servicename:${var.service_name}}"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].memory_utilization}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].memory_warning}"
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
      title = "Running vs Desired Tasks"
      request {
        q            = "avg:aws.ecs.service.running{cluster_name:${var.cluster_name},servicename:${var.service_name}}"
        display_type = "line"
        metadata {
          alias_name = "Running Tasks"
        }
      }
      request {
        q            = "avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}"
        display_type = "line"
        metadata {
          alias_name = "Desired Tasks"
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
      title = "Task Count Deviation (%)"
      request {
        q            = "100 * abs(avg:aws.ecs.service.running{cluster_name:${var.cluster_name},servicename:${var.service_name}} - avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}) / max(avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}, 1)"
        display_type = "line"
        metadata {
          expression = "100 * abs(avg:aws.ecs.service.running{cluster_name:${var.cluster_name},servicename:${var.service_name}} - avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}) / max(avg:aws.ecs.service.desired{cluster_name:${var.cluster_name},servicename:${var.service_name}}, 1)"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].task_count_deviation}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].task_deviation_warning}"
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
      title = "Deployment Failures"
      request {
        q            = "sum:aws.ecs.service.deployment_failures{cluster_name:${var.cluster_name},servicename:${var.service_name}}.as_count()"
        display_type = "bars"
        metadata {
          expression = "sum:aws.ecs.service.deployment_failures{cluster_name:${var.cluster_name},servicename:${var.service_name}}.as_count()"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].service_failures}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].service_failures_warning}"
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
      title = "Container Restarts"
      request {
        q            = "derivative(avg:aws.ecs.containerinsights.restarts{cluster_name:${var.cluster_name},service_name:${var.service_name}})"
        display_type = "bars"
        metadata {
          expression = "derivative(avg:aws.ecs.containerinsights.restarts{cluster_name:${var.cluster_name},service_name:${var.service_name}})"
        }
      }
      marker {
        display_type = "error dashed"
        value        = "${local.thresholds[var.criticality].container_restarts}"
        label        = "Critical"
      }
      marker {
        display_type = "warning dashed"
        value        = "${local.thresholds[var.criticality].container_restarts_warning}"
        label        = "Warning"
      }
      yaxis {
        include_zero = true
        scale        = "linear"
      }
    }
  }
  
  template_variable {
    name    = "cluster"
    prefix  = "cluster_name"
  }
  
  template_variable {
    name    = "service"
    prefix  = "servicename"
  }
  
  template_variable_preset {
    name = "Default"
    
    template_variable {
      name  = "cluster"
      value = var.cluster_name
    }
    
    template_variable {
      name  = "service"
      value = var.service_name
    }
  }
  
  tags = concat(var.tags, ["cluster:${var.cluster_name}", "service:${var.service_name}", "managed_by:terraform"])
}