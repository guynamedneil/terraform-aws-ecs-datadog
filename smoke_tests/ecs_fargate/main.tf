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

  dd_api_key = var.dd_api_key
  dd_site    = var.dd_site
  dd_service = var.dd_service

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
  network_mode = "awsvpc"
  pid_mode     = "task"
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
