locals {
  base_env = var.dd_environment

  dynamic_env = [
    for pair in [
      { key = "DD_API_KEY", value = var.dd_api_key },
      { key = "DD_SITE", value = var.dd_site },
      { key = "DD_SERVICE", value = var.dd_service },
      { key = "DD_ENV", value = var.dd_env },
      { key = "DD_VERSION", value = var.dd_version },
      # TODO: clusterName, ddTags, etc.
    ] : { name = pair.key, value = pair.value } if pair.value != null
  ]

  dd_agent_env = concat(local.base_env, local.dynamic_env)

  # Datadog Agent container definition
  dd_agent_container = {
    name        = "datadog-agent"
    image       = "${var.dd_registry}:${var.dd_image_version}"
    environment = local.dd_agent_env
    secrets = var.dd_api_key_secret_arn != null ? [
      {
        name      = "DD_API_KEY"
        valueFrom = var.dd_api_key_secret_arn
      }
    ] : []
    portMappings = [
      {
        containerPort = 8125
        hostPort      = 8125
        protocol      = "udp"
      },
      {
        containerPort = 8126
        hostPort      = 8126
        protocol      = "tcp"
      }
    ]
  }
}