# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

output "example_module" {
  value = module.datadog_ecs_fargate_task.arn
}
