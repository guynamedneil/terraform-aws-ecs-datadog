# Smoke Tests

A simple smoke test setup that creates one of each of the various configurations
that we support, making sure that our parameters are sensible and work.

## Usage

* Create a [Datadog API Key](https://app.datadoghq.com/organization-settings/api-keys)
* Create a `terraform.tfvars` file
  * Set the `dd_api_key` to the Datadog API Key
  * Set the `dd_service_name` to the name of the service you want to use to filter for the resource in Datadog
  * Set the `dd_site` to the [Datadog destination site](https://docs.datadoghq.com/getting_started/site/) for your metrics, traces, and logs
* Run the following commands

```bash
terraform init
terraform plan
terraform apply
```

Confirm that the ecs tasks were all created as expected.

Run the following commands to clean up the environment:

```bash
terraform destroy
```
