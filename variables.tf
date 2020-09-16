variable "name" {
  type        = string
  description = "Name of the deployment."
}

# variable "application_name" {
#   type        = string
#   description = "Name of application."
# }

variable "service_name" {
  type        = string
  description = "Name of the service to associate with deployment, if unset defaults to deployment name."
  default     = null
}

variable "platform_version" {
  type        = string
  description = "Fargate Platform version."
  default     = "1.3.0"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of ECS Cluster for this deployment."
}

variable "environment_name" {
  type        = string
  description = "Name of environment."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}

variable "memory" {
  type        = number
  description = "Ammount of memory to allocate for deployment."
  default     = 512
}

variable "cpu" {
  type        = number
  description = "Ammount of cpu shares allocate for deployment."
  default     = 256
}

variable "task_role" {
  type        = string
  description = "IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  default     = "role/ecsTaskExecutionRole"
}

variable "execution_role" {
  type        = string
  description = "(Optional) IAM Role that the Amazon ECS container agent and the Docker daemon can assume."
  default     = "role/ecsTaskExecutionRole"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster this deployment will run on."
}

variable "load_balancer_arn" {
  type        = string
  description = "ARN of the load balancer target group to assing this deployment to."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC this deployment will use."
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet names this deployment will reside on."
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs to associate with this deployment."
}

variable "public_ip" {
  type        = bool
  description = "If true a public IP Address will be assigned to each running task."
  default     = false
}

variable "container_definitions" {
  type        = string
  description = "JSON Represention of the Docker definitions"
}

variable "port_mappings" {
  type        = list(object({ container_name = string, container_port = number }))
  description = "Key value pair mappings of Docker containers and TCP ports to be connected to the load balancer."
  default     = []
}

variable "alb_protocol" {
  type        = string
  description = "The protocol to use for routing traffic from the ALB to the deployment. Should be one of TCP, TLS, UDP, TCP_UDP, HTTP or HTTPS"
  default     = "HTTP"
}

# No type as this accepts strings and numbers
variable "alb_health_check_port" {
  description = "The port to use for connections from the ALB to the deployment. Valid values are either ports 1-65535, or traffic-port"
  default     = "traffic-port"
}

variable "alb_health_check_path" {
  type        = string
  description = "The destination for the health check request."
  default     = "/health-check"
}

variable "alb_health_check_codes" {
  type        = list(number)
  description = "HTTP responses for passing health checks."
  default     = [200]
}

variable "dns_names" {
  type        = list(string)
  description = "DNS names to associate with this deployment"
  default     = []
}

variable "alb_host_names" {
  type        = list(string)
  description = "ALB host header to associate with this deployment"
  default     = []
}

variable "alb_target_group_name" {
  type        = string
  description = "(Optional) Name of the ALB Target group to create. Default is <cluster_name>-<deployment_name>"
  default     = null
}

variable "alb_listner_rule_priority" {
  type        = number
  description = "(Optional) The priority for the rule between 1 and 50000. Leaving it unset will automatically set the rule with next available priority after currently existing highest rule. A listener can't have multiple rules with the same priority."
  default     = null
}

variable "dns_zone" {
  type        = string
  description = "Name of the DNS zone to use with this deployment."
}

variable "private_dns" {
  type        = bool
  description = "If true, private DNS zones will be used."
  default     = false
}

variable "dns_root_target" {
  type        = bool
  description = "If true, a DNS record from the root of the DNS Zone will be routed to this deployment."
  default     = false
}

variable "alb_path_patterns" {
  type        = list(string)
  description = "ALB URL Path to match for this deployment"
  default     = ["/*"]
}

variable "alb_source_ips" {
  type        = list(string)
  description = "List of CIDR address to match for this deployments ALB routing condition. Default is 0.0.0.0/0, ::/0 . This is used to allow only specific IP addresses access to deployment."
  default     = ["0.0.0.0/0", "::/0"]
}

variable "http_listener_arn" {
  type        = string
  description = "ARN of the HTTP listener to assoicate this deployment with."
  default     = null
}

variable "https_listener_arn" {
  type        = string
  description = "ARN of the HTTPS listener to assoicate this deployment with."
  default     = null
}

variable "use_load_balancer" {
  type        = bool
  description = "If true, this service will be bound to the load balancer."
  default     = true
}

variable "managed" {
  type        = bool
  description = "If true, Terraform will ensure task modifications and replica counts are fully managed by Terraform."
  default     = false
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "ID of the service discovery namespace to be used"
  default     = null
}

# Autoscaling
variable "autoscaling" {
  type        = bool
  description = "If true, autoscaling will be enabled on this deployment."
  default     = true
}

variable "autoscaling_role" {
  type        = string
  description = "Name of the role allowed to perform autoscaling for this deployment."
  default     = "role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
}

variable "max_capacity" {
  type        = number
  description = "The max capacity of the scalable target."
  default     = 1
}

variable "min_capacity" {
  type        = number
  description = "The min capacity of the scalable target."
  default     = 1
}


