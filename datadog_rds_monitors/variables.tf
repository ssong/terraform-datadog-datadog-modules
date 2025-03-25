variable "db_instance_identifier" {
  description = "The identifier of the AWS RDS instance to monitor"
  type        = string
}

variable "criticality" {
  description = "The criticality level of the RDS instance (low, medium, high)"
  type        = string
  validation {
    condition     = contains(["low", "medium", "high"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high"
  }
}

variable "prefix" {
  description = "Prefix to add to the monitor names"
  type        = string
  default     = "[RDS] "
}

variable "notification_target" {
  description = "The target for alert notifications (e.g., @slack-channel, @pagerduty, @email)"
  type        = string
}

variable "tags" {
  description = "Additional tags to add to the monitors"
  type        = list(string)
  default     = []
}

variable "evaluation_period" {
  description = "The evaluation period for the monitors, in minutes"
  type        = string
  default     = "last_15m"
}

variable "max_connections" {
  description = "The maximum number of connections allowed for the RDS instance"
  type        = number
  default     = 100
}

variable "is_replica" {
  description = "Whether the RDS instance is a read replica. Set to true to enable replica lag monitoring."
  type        = bool
  default     = false
}

variable "create_dashboard" {
  description = "Whether to create a dashboard for the RDS instance"
  type        = bool
  default     = false
}

variable "dashboard_name_prefix" {
  description = "Prefix to add to the dashboard name"
  type        = string
  default     = "RDS Instance Metrics"
}