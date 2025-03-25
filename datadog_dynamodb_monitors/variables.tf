variable "table_name" {
  description = "The name of the AWS DynamoDB table to monitor"
  type        = string
}

variable "criticality" {
  description = "The criticality level of the DynamoDB table (low, medium, high)"
  type        = string
  validation {
    condition     = contains(["low", "medium", "high"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high"
  }
}

variable "prefix" {
  description = "Prefix to add to the monitor names"
  type        = string
  default     = "[DynamoDB] "
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

variable "provisioned_capacity" {
  description = "Whether the table uses provisioned capacity. Set to true to enable capacity-based monitoring."
  type        = bool
  default     = false
}

variable "read_capacity_units" {
  description = "The provisioned read capacity units for the table. Only used if provisioned_capacity is true."
  type        = number
  default     = 5
}

variable "write_capacity_units" {
  description = "The provisioned write capacity units for the table. Only used if provisioned_capacity is true."
  type        = number
  default     = 5
}

variable "create_dashboard" {
  description = "Whether to create a dashboard for the DynamoDB table"
  type        = bool
  default     = false
}

variable "dashboard_name_prefix" {
  description = "Prefix to add to the dashboard name"
  type        = string
  default     = "DynamoDB Table Metrics"
}