# Datadog ElastiCache Monitors Terraform Module

This Terraform module creates a set of Datadog monitors for AWS ElastiCache (Redis and Memcached) clusters. The monitors are configured based on the criticality level provided (low, medium, high).

## Monitors Created

1. **CPU Utilization Monitor**: Alerts when the ElastiCache cluster CPU utilization exceeds thresholds
2. **Memory Utilization Monitor**: Alerts when the ElastiCache cluster memory utilization exceeds thresholds
3. **Swap Usage Monitor**: Alerts when the ElastiCache cluster has high swap usage
4. **Evictions Monitor**: Alerts when the ElastiCache cluster has a high rate of evictions
5. **Current Connections Monitor**: Alerts when the ElastiCache cluster is nearing its maximum connection limit
6. **Replication Lag Monitor** (Redis replicas only): Alerts when a Redis replica has high replication lag

## Usage

```hcl
# For a Redis primary cluster
module "redis_primary_monitors" {
  source = "path/to/datadog_elasticache_monitors"

  cache_cluster_id     = "my-redis-primary"
  cache_type           = "redis"  # Options: redis, memcached
  criticality          = "high"   # Options: low, medium, high
  notification_target  = "@slack-channel @pagerduty-service"
  tags                 = ["service:cache", "team:platform"]
}

# For a Redis replica
module "redis_replica_monitors" {
  source = "path/to/datadog_elasticache_monitors"

  cache_cluster_id     = "my-redis-replica"
  cache_type           = "redis"  # Options: redis, memcached
  criticality          = "medium" # Options: low, medium, high
  notification_target  = "@slack-channel @pagerduty-service"
  is_replica           = true     # Enable replication lag monitoring
  tags                 = ["service:cache", "team:platform"]
}

# For a Memcached cluster
module "memcached_monitors" {
  source = "path/to/datadog_elasticache_monitors"

  cache_cluster_id     = "my-memcached"
  cache_type           = "memcached" # Options: redis, memcached
  criticality          = "high"      # Options: low, medium, high
  notification_target  = "@slack-channel @pagerduty-service"
  tags                 = ["service:sessions", "team:platform"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cache_cluster_id | The identifier of the AWS ElastiCache cluster to monitor | string | n/a | yes |
| cache_type | The type of ElastiCache (redis or memcached) | string | n/a | yes |
| criticality | The criticality level of the ElastiCache cluster (low, medium, high) | string | n/a | yes |
| prefix | Prefix to add to the monitor names | string | "[ElastiCache] " | no |
| notification_target | The target for alert notifications (e.g., @slack-channel, @pagerduty, @email) | string | n/a | yes |
| tags | Additional tags to add to the monitors | list(string) | [] | no |
| evaluation_period | The evaluation period for the monitors, in minutes | string | "last_15m" | no |
| max_connections | The maximum number of connections allowed for the ElastiCache cluster | number | 65000 | no |
| is_replica | Whether the Redis node is a replica. Set to true to enable replication lag monitoring. Only applicable for Redis. | bool | false | no |
| create_dashboard | Whether to create a dashboard for the ElastiCache cluster | bool | false | no |
| dashboard_name_prefix | Prefix to add to the dashboard name | string | "ElastiCache Metrics" | no |

## Outputs

| Name | Description |
|------|-------------|
| monitor_ids | Map of the created DataDog monitor IDs |
| criticality_thresholds | The thresholds used for each monitor based on criticality level |
| dashboard_url | URL to the created dashboard, if dashboard creation was enabled |

## Criticality Thresholds

### High
```
cpu_utilization        = 80% (warning at 70%)
memory_utilization     = 80% (warning at 70%)
swap_utilization       = 25MB (warning at 15MB)
evictions              = 250 (warning at 100)
connections            = 70% (warning at 60%)
replication_lag        = 60s (warning at 30s)
```

### Medium
```
cpu_utilization        = 85% (warning at 75%)
memory_utilization     = 85% (warning at 75%)
swap_utilization       = 35MB (warning at 25MB)
evictions              = 500 (warning at 250)
connections            = 80% (warning at 70%)
replication_lag        = 180s (warning at 90s)
```

### Low
```
cpu_utilization        = 90% (warning at 80%)
memory_utilization     = 90% (warning at 80%)
swap_utilization       = 50MB (warning at 35MB)
evictions              = 1000 (warning at 500)
connections            = 90% (warning at 80%)
replication_lag        = 300s (warning at 180s)
```