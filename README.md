# AWS ECS Deployment Spinnaker Compatible (Fargate)

This module creates an ECS Fargate deployment that is compatible with Spinnaker's [naming conventions](https://docs.armory.io/docs/overview/naming-conventions/#spinnaker-naming-conventions) and is intended to be used with [synapsestudios/terraform-aws-ecs-fargate-stack](https://github.com/synapsestudios/terraform-aws-ecs-fargate-stack)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.29 |
| aws | ~> 2.53 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.53 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the cluster this deployment will run on. | `string` | n/a | yes |
| container\_definitions | JSON Represention of the Docker definitions | `string` | n/a | yes |
| dns\_zone | Name of the DNS zone to use with this deployment. | `string` | n/a | yes |
| ecs\_cluster\_arn | ARN of ECS Cluster for this deployment. | `string` | n/a | yes |
| environment\_name | Name of environment. | `string` | n/a | yes |
| load\_balancer\_arn | ARN of the load balancer target group to assing this deployment to. | `string` | n/a | yes |
| name | Name of the deployment. | `string` | n/a | yes |
| security\_groups | List of security group IDs to associate with this deployment. | `list(string)` | n/a | yes |
| subnets | List of subnet names this deployment will reside on. | `list(string)` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| vpc\_id | ID of the VPC this deployment will use. | `string` | n/a | yes |
| alb\_health\_check\_codes | HTTP responses for passing health checks. | `list(number)` | <pre>[<br>  200<br>]</pre> | no |
| alb\_health\_check\_path | The destination for the health check request. | `string` | `"/health-check"` | no |
| alb\_health\_check\_port | The port to use for connections from the ALB to the deployment. Valid values are either ports 1-65535, or traffic-port | `string` | `"traffic-port"` | no |
| alb\_host\_names | ALB host header to associate with this deployment | `list(string)` | `[]` | no |
| alb\_listner\_rule\_priority | (Optional) The priority for the rule between 1 and 50000. Leaving it unset will automatically set the rule with next available priority after currently existing highest rule. A listener can't have multiple rules with the same priority. | `number` | `null` | no |
| alb\_path\_patterns | ALB URL Path to match for this deployment | `list(string)` | <pre>[<br>  "/*"<br>]</pre> | no |
| alb\_protocol | The protocol to use for routing traffic from the ALB to the deployment. Should be one of TCP, TLS, UDP, TCP\_UDP, HTTP or HTTPS | `string` | `"HTTP"` | no |
| alb\_source\_ips | List of CIDR address to match for this deployments ALB routing condition. Default is 0.0.0.0/0, ::/0 . This is used to allow only specific IP addresses access to deployment. | `list(string)` | <pre>[<br>  "0.0.0.0/0",<br>  "::/0"<br>]</pre> | no |
| alb\_target\_group\_name | (Optional) Name of the ALB Target group to create. Default is <cluster\_name>-<deployment\_name> | `string` | `null` | no |
| autoscaling | If true, autoscaling will be enabled on this deployment. | `bool` | `true` | no |
| autoscaling\_role | Name of the role allowed to perform autoscaling for this deployment. | `string` | `"role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"` | no |
| cpu | Ammount of cpu shares allocate for deployment. | `number` | `256` | no |
| dns\_names | DNS names to associate with this deployment | `list(string)` | `[]` | no |
| dns\_root\_target | If true, a DNS record from the root of the DNS Zone will be routed to this deployment. | `bool` | `false` | no |
| execution\_role | (Optional) IAM Role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | `"role/ecsTaskExecutionRole"` | no |
| http\_listener\_arn | ARN of the HTTP listener to assoicate this deployment with. | `string` | `null` | no |
| https\_listener\_arn | ARN of the HTTPS listener to assoicate this deployment with. | `string` | `null` | no |
| managed | If true, Terraform will ensure task modifications and replica counts are fully managed by Terraform. | `bool` | `false` | no |
| max\_capacity | The max capacity of the scalable target. | `number` | `1` | no |
| memory | Ammount of memory to allocate for deployment. | `number` | `512` | no |
| min\_capacity | The min capacity of the scalable target. | `number` | `1` | no |
| platform\_version | Fargate Platform version. | `string` | `"1.3.0"` | no |
| port\_mappings | Key value pair mappings of Docker containers and TCP ports to be connected to the load balancer. | `list(object({ container_name = string, container_port = number }))` | `[]` | no |
| private\_dns | If true, private DNS zones will be used. | `bool` | `false` | no |
| public\_ip | If true a public IP Address will be assigned to each running task. | `bool` | `false` | no |
| service\_discovery\_namespace\_id | ID of the service discovery namespace to be used | `string` | `null` | no |
| service\_name | Name of the service to associate with deployment, if unset defaults to deployment name. | `string` | `null` | no |
| task\_role | IAM role that allows your Amazon ECS container task to make calls to other AWS services. | `string` | `"role/ecsTaskExecutionRole"` | no |
| use\_load\_balancer | If true, this service will be bound to the load balancer. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| grafana\_ecs\_service\_cpu\_utilization | Grafan Panel for ECS Service CPU Utilization. |
| grafana\_ecs\_service\_memory\_utilization | Grafan Panel for ECS Service CPU Utilization. |
| grafana\_ecs\_service\_request\_response | Grafan Panel for ECS Service RequestCount / TargetResponseTime. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->