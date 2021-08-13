########
# Locals
########
locals {
  host_names = distinct(concat(var.dns_names, var.alb_host_names))

  alb_host_names = [
    for host in local.host_names :
    host == var.dns_zone ? host : format("%s.${var.dns_zone}", host)
  ]
}

################
# AWS Account ID
################
data "aws_caller_identity" "current" {}

####################
# AWS Current Region
####################
data "aws_region" "current" {}

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
}

#######################################
# AWS Route53 Zone for this environment
#######################################
data "aws_route53_zone" "this" {
  name         = var.dns_zone
  private_zone = var.private_dns
}

data "aws_lb" "this" {
  arn = var.load_balancer_arn
}

#########################
# Route53 Aliases for ALB
#########################
resource "aws_route53_record" "this" {
  count = length(var.dns_names)

  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.dns_names[count.index]
  type    = "A"

  alias {
    name                   = data.aws_lb.this.dns_name
    zone_id                = data.aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

#################################
# Route53 Alias for ALB Root Zone
#################################
resource "aws_route53_record" "dns_root_target" {
  count = var.dns_root_target == true ? 1 : 0

  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.dns_zone
  type    = "A"

  alias {
    name                   = data.aws_lb.this.dns_name
    zone_id                = data.aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

#############
# ECS - Tasks
#############
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.cluster_name}-${var.name}"
  container_definitions    = var.container_definitions
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.task_role}"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.execution_role}"
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  requires_compatibilities = ["FARGATE"]
  tags                     = var.tags
}

#########################
# ECS - Service - Managed
#########################
resource "aws_ecs_service" "managed" {
  count = var.managed == true ? 1 : 0

  depends_on       = [aws_lb_target_group.this[0]]
  name             = var.service_name != null ? var.service_name : "${var.cluster_name}-${var.name}"
  launch_type      = "FARGATE"
  cluster          = var.ecs_cluster_arn
  task_definition = "arn:aws:ecs:${data.aws_region.current}:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  desired_count    = var.min_capacity
  platform_version = var.platform_version

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # TODO opt in is required for adding tags here
  # See: https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/settings
  # tags            = var.tags

  dynamic "load_balancer" {
    for_each = var.port_mappings
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
    }
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.public_ip
  }

  dynamic "service_registries" {
    for_each = var.port_mappings
    content {
      # TODO this breaks with multiple dns 
      registry_arn   = aws_service_discovery_service.this[0].arn
      container_name = service_registries.value["container_name"]
      container_port = service_registries.value["container_port"]
    }
  }
}

############################
# ECS - Service - Un-Managed
############################
resource "aws_ecs_service" "un_managed" {
  count = var.managed == false ? 1 : 0

  depends_on       = [aws_lb_target_group.this[0]]
  name             = var.service_name != null ? var.service_name : "${var.cluster_name}-${var.name}"
  launch_type      = "FARGATE"
  cluster          = var.ecs_cluster_arn
  task_definition = "arn:aws:ecs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  desired_count    = var.min_capacity
  platform_version = var.platform_version

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # TODO opt in is required for adding tags here
  # See: https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/settings
  # tags            = var.tags

  dynamic "load_balancer" {
    for_each = var.port_mappings
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
    }
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.public_ip
  }

  dynamic "service_registries" {
    for_each = var.port_mappings
    content {
      registry_arn   = length(aws_service_discovery_service.this) == 1 ? aws_service_discovery_service.this[0].arn : ""
      container_name = service_registries.value["container_name"]
      container_port = service_registries.value["container_port"]
    }
  }

  # This allows dynamic scaling and external deployments
  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

###################
# Service Discovery
###################
resource "aws_service_discovery_service" "this" {
  count = var.service_discovery_namespace_id != null ? length(var.dns_names) : 0

  name = var.dns_names[count.index]

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

###################
# ALB Listener Rule
###################
resource "aws_lb_listener_rule" "this" {
  count = var.use_load_balancer == true ? 1 : 0

  depends_on   = [var.load_balancer_arn]
  listener_arn = var.https_listener_arn
  priority     = var.alb_listner_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    path_pattern {
      values = var.alb_path_patterns
    }
  }

  condition {
    host_header {
      values = local.alb_host_names
    }
  }

  condition {
    source_ip {
      values = var.alb_source_ips
    }
  }
}

#####################
# ALB - Target Groups
#####################
resource "aws_lb_target_group" "this" {
  count = var.use_load_balancer == true ? 2 : 0

  name        = var.alb_target_group_name == null ? "${var.cluster_name}-${var.name}${count.index}" : var.alb_target_group_name
  port        = 80
  protocol    = var.alb_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags        = var.tags

  health_check {
    enabled             = true
    interval            = 20
    path                = var.alb_health_check_path
    port                = var.alb_health_check_port
    protocol            = var.alb_protocol
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = join(",", var.alb_health_check_codes)
  }

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  lifecycle {
     create_before_destroy = true
  }
}

####################################
# CloudWatch - Application Log Group
####################################
resource "aws_cloudwatch_log_group" "this" {
  count = length(jsondecode(var.container_definitions))

  name = jsondecode(var.container_definitions)[count.index].logConfiguration.options.awslogs-group
  tags = var.tags
}

########################
# App Autoscaling Target
########################
resource "aws_appautoscaling_target" "this" {
  count = var.autoscaling == true ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.cluster_name}-${var.name}"
  role_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.autoscaling_role}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

########################
# App Autoscaling Policy
########################
resource "aws_appautoscaling_policy" "memory" {
  count = var.autoscaling == true ? 1 : 0

  name               = "${var.name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = "70"
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.autoscaling == true ? 1 : 0

  name               = "${var.name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = "70"
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
