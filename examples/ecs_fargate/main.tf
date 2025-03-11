################################################################################
# Task Definition: Datadog Agent Example
################################################################################

module "ecs_task" {
  source = "../../modules/ecs_fargate"

  # Configure Datadaog
  # dd_api_key_secret_arn  = "arn:aws:secretsmanager:us-east-1:376334461865:secret:ecs-terraform-dd-api-key-IU8YjD"
  # execution_role_arn = "arn:aws:iam::376334461865:role/my-ecs-task-execution-role"
  dd_api_key = "gabegabegabe"

  dd_environment = [
    {
      name  = "DD_TAGS",
      value = "team:cont-p, owner:container-monitoring"
    },
  ]

  # Configure Task Definition
  family = "my-app"
  container_definitions = {
    dogstatsd = {
      name      = "datadog-dogstatsd-app",
      image     = "ghcr.io/datadog/apps-dogstatsd:main",
      essential = false,
    },
    apm = {
      name      = "datadog-apm-app",
      image     = "ghcr.io/datadog/apps-tracegen:main",
      essential = false,
    },
    cws = {
      name      = "datadog-cws-app",
      image     = "public.ecr.aws/ubuntu/ubuntu:22.04_stable",
      essential = true,
      entryPoint = [
        "/usr/bin/bash",
        "-c",
        "cp /usr/bin/bash /tmp/malware; chmod u+s /tmp/malware; apt update;apt install -y curl wget; /tmp/malware -c 'while true; do wget https://google.com; sleep 60; done'"
      ]
    }
  }
  requires_compatibilities = ["FARGATE"]
}

################################################################################
# Task Definition: All Task Parameters Example
################################################################################

resource "aws_efs_file_system" "fs" {
  creation_token   = "my-efs-file-system"
  performance_mode = "generalPurpose"

  tags = {
    Name = "MyEFSFileSystem"
  }
}

resource "aws_efs_access_point" "fs" {
  file_system_id = aws_efs_file_system.fs.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/example"

    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
}

module "ecs_task_all_task_features" {
  source = "../../modules/ecs_fargate"

  family = "all-task-features"

  container_definitions = {
    allContainer = {
      name      = "datadog-dummy-app",
      image     = "public.ecr.aws/ubuntu/ubuntu:22.04_stable",
      essential = true,
      entryPoint = [
        "/usr/bin/bash",
        "-c",
        "cp /usr/bin/bash /tmp/malware; chmod u+s /tmp/malware; apt update;apt install -y curl wget; /tmp/malware -c 'while true; do wget https://google.com; sleep 60; done'"
      ],
    }
  }

  cpu                    = 256
  memory                 = 512
  enable_fault_injection = false
  ephemeral_storage = {
    size_in_gib = 40
  }
  # NOT SUPPORTED ON FARGATE
  # inference_accelerator = [{
  #   device_name = "device_1"
  #   device_type = "eia1.medium"
  # }]
  # NOT SUPPORTED ON FARGATE
  # ipc_mode     = "host"
  network_mode = "awsvpc"
  pid_mode     = "task"
  # NOT SUPPORTED ON FARGATE
  # placement_constraints = [{
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-east-1a]"
  # }]
  proxy_configuration = {
    type           = "APPMESH"
    container_name = "datadog-dummy-app"
    properties = {
      AppPorts         = "8080"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
  volume = {
    name = "service-storage"

    docker_volume_configuration = {
      scope         = "shared"
      autoprovision = true
      driver        = "local"

      driver_opts = {
        "type"   = "nfs"
        "device" = "${aws_efs_file_system.fs.dns_name}:/"
        "o"      = "addr=${aws_efs_file_system.fs.dns_name},rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
      }
    }

    efs_volume_configuration = {
      file_system_id          = aws_efs_file_system.fs.id
      root_directory          = "/opt/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config = {
        access_point_id = aws_efs_access_point.fs.id
        iam             = "ENABLED"
      }
    }
  }

  skip_destroy = false

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}