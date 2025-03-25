variable "lambda_function_name" {
  description = "The name of the AWS Lambda function to monitor"
  type        = string
}

variable "criticality" {
  description = "The criticality level of the Lambda function (low, medium, high)"
  type        = string
  validation {
    condition     = contains(["low", "medium", "high"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high"
  }
}

variable "prefix" {
  description = "Prefix to add to the monitor names"
  type        = string
  default     = "[Lambda] "
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

variable "baseline_period" {
  description = "The baseline period for comparison monitors, in hours"
  type        = string
  default     = "hour_before"
}

variable "concurrent_execution_limit" {
  description = "The concurrent execution limit for the Lambda function"
  type        = number
  default     = 1000 # Default AWS Lambda limit
}

variable "create_dashboard" {
  description = "Whether to create a dashboard for the Lambda function"
  type        = bool
  default     = false
}

variable "dashboard_name_prefix" {
  description = "Prefix to add to the dashboard name"
  type        = string
  default     = "Lambda Function Metrics"
}