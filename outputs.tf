output "grafana_ecs_service_request_response" {
  description = "Grafan Panel for ECS Service RequestCount / TargetResponseTime."
  value       = length(aws_lb_target_group.this) == 0 ? null : module.grafana_ecs_service_request_response.panel
}

output "grafana_ecs_service_cpu_utilization" {
  description = "Grafan Panel for ECS Service CPU Utilization."
  value       = module.grafana_ecs_service_cpu_utilization.panel
}

output "grafana_ecs_service_memory_utilization" {
  description = "Grafan Panel for ECS Service CPU Utilization."
  value       = module.grafana_ecs_service_memory_utilization.panel
}

