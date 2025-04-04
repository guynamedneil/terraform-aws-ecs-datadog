# Datadog Terraform module for AWS ECS Tasks

[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](https://github.com/DataDog/terraform-aws-lambda-datadog/blob/main/LICENSE)

Use this Terraform module to install Datadog Monitoring for AWS Elastic Container Service tasks.

This Terraform module wraps the [aws_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) resource and automatically configures your task definition for Datadog Monitoring by:

* Adding the Datadog Agent container
  * Optionally, the Fluentbit log router
  * Optionally, the Cloud Workload Security tracer
* Configuring application containers with necessary mounts and environment variables
* Enabling the collection of metrics, traces, and logs to Datadog

## Usage

```hcl
module "ecs_task" {
  source = "../../modules/ecs_fargate"

  # Datadog Configuration
  dd_api_key_secret_arn  = "arn:aws:secretsmanager:us-east-1:0000000000:secret:example-secret"
  dd_environment = [
    {
      name  = "DD_TAGS",
      value = "team:cont-p, owner:container-monitoring"
    },
  ]

  # Task Configuration
  family = "example-app"
  container_definitions = {
    dogstatsd-app = {
      name      = "datadog-dogstatsd-app",
      image     = "ghcr.io/datadog/apps-dogstatsd:main",
      essential = false,
    },
    apm-app = {
      name      = "datadog-apm-app",
      image     = "ghcr.io/datadog/apps-tracegen:main",
      essential = false,
    }
  }
}
```
