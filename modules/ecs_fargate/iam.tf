locals {
  edit_execution_role    = var.execution_role_arn != null
  create_execution_role  = !local.edit_execution_role
  create_dd_secret_perms = var.dd_api_key_secret_arn != null
}

# ==============================
# Datadog API Key Secret Policy (Optional)
# ==============================
data "aws_iam_policy_document" "dd_secret_access" {
  count = local.create_dd_secret_perms ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.dd_api_key_secret_arn]
  }
}

resource "aws_iam_policy" "dd_secret_access" {
  count  = local.create_dd_secret_perms ? 1 : 0
  name   = "${var.family}-dd-secret-access"
  policy = data.aws_iam_policy_document.dd_secret_access[0].json
}

# ==============================
# ECS Task Permissions Policy
# ==============================
data "aws_iam_policy_document" "dd_ecs_task_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListClusters",
      "ecs:ListContainerInstances",
      "ecs:DescribeContainerInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "dd_ecs_task_permissions" {
  name   = "${var.family}-dd-ecs-task-policy"
  policy = data.aws_iam_policy_document.dd_ecs_task_permissions.json
}

# ==============================
# Case 1: User provides existing Task Execution Role
# ==============================
data "aws_iam_role" "ecs_task_role" {
  count = local.edit_execution_role ? 1 : 0
  name  = element(split("/", var.execution_role_arn), 1)
}

# Always attach `dd_ecs_task_permissions`
resource "aws_iam_role_policy_attachment" "existing_role_ecs_task_permissions" {
  count      = local.edit_execution_role ? 1 : 0
  role       = data.aws_iam_role.ecs_task_role[0].name
  policy_arn = aws_iam_policy.dd_ecs_task_permissions.arn
}

# Conditionally attach `dd_secret_access` only if required
resource "aws_iam_role_policy_attachment" "existing_role_dd_secret" {
  count      = local.edit_execution_role && local.create_dd_secret_perms ? 1 : 0
  role       = data.aws_iam_role.ecs_task_role[0].name
  policy_arn = aws_iam_policy.dd_secret_access[0].arn
}

# ==============================
# Case 2: Create a Task Execution Role
# ==============================
resource "aws_iam_role" "ecs_task_execution" {
  count = local.create_execution_role ? 1 : 0
  name  = "${var.family}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  count      = local.create_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Always attach `dd_ecs_task_permissions`
resource "aws_iam_role_policy_attachment" "new_role_ecs_task_permissions" {
  count      = local.create_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = aws_iam_policy.dd_ecs_task_permissions.arn
}

# Conditionally attach `dd_secret_access` only if required
resource "aws_iam_role_policy_attachment" "new_role_dd_secret" {
  count      = local.create_execution_role && local.create_dd_secret_perms ? 1 : 0
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = aws_iam_policy.dd_secret_access[0].arn
}
