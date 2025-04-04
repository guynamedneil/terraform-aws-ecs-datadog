variable "dd_api_key" {
  description = "Datadog API Key"
  type        = string
}

variable "dd_service" {
  description = "Service name for resource filtering in Datadog"
  type        = string
}

variable "dd_site" {
  description = "Datadog Site"
  type        = string
  default     = "datadoghq.com"
}