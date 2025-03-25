variable "cache_cluster_id" {
  description = "The identifier of the AWS ElastiCache cluster to monitor"
  type        = string
}

variable "cache_type" {
  description = "The type of ElastiCache (redis or memcached)"
  type        = string
  validation {
    condition     = contains(["redis", "memcached"], var.cache_type)
    error_message = "Cache type must be one of: redis, memcached"
  }
}

variable "criticality" {
  description = "The criticality level of the ElastiCache cluster (low, medium, high)"
  type        = string
  validation {
    condition     = contains(["low", "medium", "high"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high"
  }
}

variable "prefix" {
  description = "Prefix to add to the monitor names"
  type        = string
  default     = "[ElastiCache] "
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
  description = "The maximum number of connections allowed for the ElastiCache cluster"
  type        = number
  default     = 65000
}

variable "is_replica" {
  description = "Whether the Redis node is a replica. Set to true to enable replication lag monitoring. Only applicable for Redis."
  type        = bool
  default     = false
}

variable "create_dashboard" {
  description = "Whether to create a dashboard for the ElastiCache cluster"
  type        = bool
  default     = false
}

variable "dashboard_name_prefix" {
  description = "Prefix to add to the dashboard name"
  type        = string
  default     = "ElastiCache Metrics"
}