# Datadog ECS Fargate Terraform

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.77.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.90.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.dd_ecs_task_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dd_secret_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.existing_role_dd_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.existing_role_ecs_task_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.new_role_dd_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.new_role_ecs_task_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.dd_ecs_task_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dd_secret_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | A map of valid [container definitions](http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html). Please note that you should only provide values that are part of the container definition document | `any` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the `requires_compatibilities` is `FARGATE` this field is required | `number` | `512` | no |
| <a name="input_dd_api_key"></a> [dd\_api\_key](#input\_dd\_api\_key) | Datadog API Key | `string` | `null` | no |
| <a name="input_dd_api_key_secret_arn"></a> [dd\_api\_key\_secret\_arn](#input\_dd\_api\_key\_secret\_arn) | Datadog API Key Secret ARN | `string` | `null` | no |
| <a name="input_dd_environment"></a> [dd\_environment](#input\_dd\_environment) | Datadog Agent container environment variables | `list(map(string))` | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_dd_image_version"></a> [dd\_image\_version](#input\_dd\_image\_version) | Datadog Agent image version | `string` | `"latest"` | no |
| <a name="input_dd_registry"></a> [dd\_registry](#input\_dd\_registry) | Datadog Agent image registry | `string` | `"public.ecr.aws/datadog/agent"` | no |
| <a name="input_dd_site"></a> [dd\_site](#input\_dd\_site) | Datadog Site | `string` | `"datadoghq.com"` | no |
| <a name="input_enable_fault_injection"></a> [enable\_fault\_injection](#input\_enable\_fault\_injection) | Enables fault injection and allows for fault injection requests to be accepted from the task's containers | `bool` | `false` | no |
| <a name="input_ephemeral_storage"></a> [ephemeral\_storage](#input\_ephemeral\_storage) | The amount of ephemeral storage to allocate for the task. This parameter is used to expand the total amount of ephemeral storage available, beyond the default amount, for tasks hosted on AWS Fargate | `any` | `{}` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume | `string` | `null` | no |
| <a name="input_family"></a> [family](#input\_family) | A unique name for your task definition | `string` | n/a | yes |
| <a name="input_inference_accelerator"></a> [inference\_accelerator](#input\_inference\_accelerator) | Configuration block(s) with Inference Accelerators settings | `any` | `[]` | no |
| <a name="input_ipc_mode"></a> [ipc\_mode](#input\_ipc\_mode) | IPC resource namespace to be used for the containers in the task The valid values are `host`, `task`, and `none` | `string` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the `requires_compatibilities` is `FARGATE` this field is required | `number` | `1024` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host` | `string` | `"awsvpc"` | no |
| <a name="input_pid_mode"></a> [pid\_mode](#input\_pid\_mode) | Process namespace to use for the containers in the task. The valid values are `host` and `task` | `string` | `"task"` | no |
| <a name="input_placement_constraints"></a> [placement\_constraints](#input\_placement\_constraints) | Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the task definition, see `placement_constraints` for setting at the service | <pre>list(object({<br/>    type       = string<br/>    expression = string<br/>  }))</pre> | `[]` | no |
| <a name="input_proxy_configuration"></a> [proxy\_configuration](#input\_proxy\_configuration) | Configuration block for the App Mesh proxy | <pre>object({<br/>    container_name = string<br/>    properties     = map(any)<br/>    type           = optional(string, "APPMESH")<br/>  })</pre> | `null` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are `EC2` and `FARGATE` | `list(string)` | <pre>[<br/>  "FARGATE"<br/>]</pre> | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | Configuration block for `runtime_platform` that containers in your task may use | `any` | <pre>{<br/>  "cpu_architecture": "X86_64",<br/>  "operating_system_family": "LINUX"<br/>}</pre> | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | Whether to retain the old revision when the resource is destroyed or replacement is necessary | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the task definition/set created | `map(string)` | `{}` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | The ARN of the IAM role that allows your Amazon ECS container task to make calls to other AWS services | `string` | `null` | no |
| <a name="input_track_latest"></a> [track\_latest](#input\_track\_latest) | Whether should track latest ACTIVE task definition on AWS or the one created with the resource stored in state | `bool` | `false` | no |
| <a name="input_volume"></a> [volume](#input\_volume) | Configuration block for volumes that containers in your task may use | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Full ARN of the Task Definition (including both family and revision). |
| <a name="output_arn_without_revision"></a> [arn\_without\_revision](#output\_arn\_without\_revision) | ARN of the Task Definition with the trailing revision removed. |
| <a name="output_container_definitions"></a> [container\_definitions](#output\_container\_definitions) | A list of valid container definitions provided as a single valid JSON document. |
| <a name="output_cpu"></a> [cpu](#output\_cpu) | Number of cpu units used by the task. |
| <a name="output_enable_fault_injection"></a> [enable\_fault\_injection](#output\_enable\_fault\_injection) | Enables fault injection and allows for fault injection requests to be accepted from the task's containers. |
| <a name="output_ephemeral_storage"></a> [ephemeral\_storage](#output\_ephemeral\_storage) | The amount of ephemeral storage to allocate for the task. |
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | ARN of the task execution role. |
| <a name="output_family"></a> [family](#output\_family) | A unique name for your task definition. |
| <a name="output_inference_accelerator"></a> [inference\_accelerator](#output\_inference\_accelerator) | Inference accelerator settings. |
| <a name="output_ipc_mode"></a> [ipc\_mode](#output\_ipc\_mode) | IPC resource namespace to be used for the containers. |
| <a name="output_memory"></a> [memory](#output\_memory) | Amount (in MiB) of memory used by the task. |
| <a name="output_network_mode"></a> [network\_mode](#output\_network\_mode) | Docker networking mode to use for the containers. |
| <a name="output_pid_mode"></a> [pid\_mode](#output\_pid\_mode) | Process namespace to use for the containers. |
| <a name="output_placement_constraints"></a> [placement\_constraints](#output\_placement\_constraints) | Rules that are taken into consideration during task placement. |
| <a name="output_proxy_configuration"></a> [proxy\_configuration](#output\_proxy\_configuration) | Configuration block for the App Mesh proxy. |
| <a name="output_requires_compatibilities"></a> [requires\_compatibilities](#output\_requires\_compatibilities) | Set of launch types required by the task. |
| <a name="output_revision"></a> [revision](#output\_revision) | Revision of the task in a particular family. |
| <a name="output_runtime_platform"></a> [runtime\_platform](#output\_runtime\_platform) | Runtime platform configuration for the task definition. |
| <a name="output_skip_destroy"></a> [skip\_destroy](#output\_skip\_destroy) | Whether to retain the old revision when the resource is destroyed or replacement is necessary. |
| <a name="output_tags"></a> [tags](#output\_tags) | Key-value map of resource tags. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including inherited tags. |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. |
| <a name="output_track_latest"></a> [track\_latest](#output\_track\_latest) | Whether should track latest ACTIVE task definition on AWS or the one created with the resource stored in state. |
| <a name="output_volume"></a> [volume](#output\_volume) | Configuration block for volumes that containers in your task may use. |
<!-- END_TF_DOCS -->