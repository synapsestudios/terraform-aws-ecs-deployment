
locals {
  loadbalancer_name = data.aws_lb.this.arn_suffix
  name              = upper(var.name)
  region            = data.aws_region.current.name
  target_group      = length(aws_lb_target_group.this) == 0 ? null : aws_lb_target_group.this[0].arn_suffix
}

###########################################################
# AWS ALB Grafana - Service RequestCount/TargetResponseTime
###########################################################
module "grafana_ecs_service_request_response" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "${local.name} RequestCount / TargetResponseTime"
  series_overrides = [{ alias = "Response Time", yaxis = 2 }]
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name, TargetGroup = local.target_group }
      metricName = "RequestCount"
      statistics = ["Sum"]
      period     = "$__interval"
      alias      = "Request Count"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name, TargetGroup = local.target_group }
      metricName = "TargetResponseTime"
      statistics = ["Average"]
      period     = "$__interval"
      alias      = "Response Time"
    }
  ]
}

################################################
# AWS ALB Grafana - ECS Service CPU Utilization
################################################
module "grafana_ecs_service_cpu_utilization" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title    = "${local.name} CPU Utilization"
  interval = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ECS"
      dimensions = { ClusterName = var.cluster_name, ServiceName = "${var.cluster_name}-${var.name}" }
      metricName = "CPUUtilization"
      statistics = ["Average"]
      period     = "$__interval"
      alias      = "CPU Utilization"
    }
  ]

  yaxes = [
    { show = true, decimals = 0, format = "percent", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

##################################################
# AWS ALB Grafana - ECS Service Memory Utilization
##################################################
module "grafana_ecs_service_memory_utilization" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title    = "${local.name} Memory Utilization"
  interval = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ECS"
      dimensions = { ClusterName = var.cluster_name, ServiceName = "${var.cluster_name}-${var.name}" }
      metricName = "MemoryUtilization"
      statistics = ["Average"]
      period     = "$__interval"
      alias      = "Memory Utilization"
    }
  ]

  yaxes = [
    { show = true, decimals = 0, format = "percent", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}
