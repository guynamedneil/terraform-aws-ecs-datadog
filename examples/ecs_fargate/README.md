# ECS Fargate Example

A simple ECS Fargate Task Definition with out of the box Datadog instrumentation.

## Usage

* Create a [Datadog API Key](https://app.datadoghq.com/organization-settings/api-keys)
* Create a `terraform.tfvars` file
  * Set the `dd_api_key` to the Datadog API Key (required)
  * Set the `dd_service` to the name of the service you want to use to filter for the resource in Datadog
  * Set the `dd_site` to the [Datadog destination site](https://docs.datadoghq.com/getting_started/site/) for your metrics, traces, and logs
* Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```
