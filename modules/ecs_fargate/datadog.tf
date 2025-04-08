locals {
  # Application container modifications
  is_linux = var.runtime_platform == null || var.runtime_platform.operating_system_family == null || var.runtime_platform.operating_system_family == "LINUX"
  is_apm_socket_mount = var.dd_apm.enabled && var.dd_apm.socket_enabled && local.is_linux
  is_dsd_socket_mount = var.dd_dogstatsd.enabled && var.dd_dogstatsd.socket_enabled && local.is_linux
  is_apm_dsd_volume   = local.is_apm_socket_mount || local.is_dsd_socket_mount

  apm_dsd_mount = local.is_apm_dsd_volume ? [
    {
      containerPath = "/var/run/datadog"
      sourceVolume  = "dd-sockets"
      readOnly      = false
    }
  ] : []

  apm_socket_var = local.is_apm_socket_mount ? [
    {
      name  = "DD_TRACE_AGENT_URL"
      value = "unix:///var/run/datadog/apm.socket"
    }
  ] : []

  dsd_socket_var = local.is_dsd_socket_mount ? [
    {
      name  = "DD_DOGSTATSD_URL"
      value = "unix:///var/run/datadog/dsd.socket"
    }
  ] : []

  dsd_port_var = !local.is_dsd_socket_mount && var.dd_dogstatsd.enabled ? [
    {
      name  = "DD_AGENT_HOST"
      value = "127.0.0.1"
    }
  ] : []

  modified_container_definitions = [
    for container in var.container_definitions : merge(
      container,
      {
        # Append new environment variables to any existing ones.
        environment = concat(
          lookup(container, "environment", []),
          local.dsd_socket_var,
          local.apm_socket_var,
          local.dsd_port_var,
        ),
        # Append new volume mounts to any existing mountPoints.
        mountPoints = concat(
          lookup(container, "mountPoints", []),
          local.apm_dsd_mount
        )
      }
    )
  ]

  # Volume configuration for task
  apm_dsd_volume = local.is_apm_dsd_volume ? [
    {
      name = "dd-sockets"
    }
  ] : []

  modified_volumes = concat(
    [for k, v in coalesce(var.volumes, {}) : v],
    local.apm_dsd_volume
  )

  # Datadog Agent container environment variables
  dynamic_env = [
    for pair in [
      { key = "DD_API_KEY", value = var.dd_api_key },
      { key = "DD_SITE", value = var.dd_site },
      { key = "DD_SERVICE", value = var.dd_service },
      { key = "DD_ENV", value = var.dd_env },
      { key = "DD_VERSION", value = var.dd_version },
      { key = "DD_DOGSTATSD_TAG_CARDINALITY", value = var.dd_dogstatsd.dogstatsd_cardinality }
      # TODO: clusterName, ddTags, etc.
    ] : { name = pair.key, value = pair.value } if pair.value != null
  ]

  origin_detection_vars = var.dd_dogstatsd.origin_detection_enabled ? [
    {
      name  = "DD_DOGSTATSD_ORIGIN_DETECTION"
      value = "true"
    },
    {
      name  = "DD_DOGSTATSD_ORIGIN_DETECTION_CLIENT"
      value = "true"
    }
  ] : []

  dd_agent_env = concat(
    var.dd_environment,
    local.dynamic_env,
    local.origin_detection_vars,
  )

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
    ],
    mountPoints = local.apm_dsd_mount
  }
}