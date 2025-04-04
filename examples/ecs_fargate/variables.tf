variable "dd_api_key" {
  description = "Datadog API Key"
  type        = string
  default     = null
}

variable "dd_api_key_secret_arn" {
  description = "Datadog API Key Secret ARN"
  type        = string
  default     = null
}

variable "dd_service" {
  description = "Service name for resource filtering in Datadog"
  type        = string
  default     = null
}

variable "dd_site" {
  description = "Datadog Site"
  type        = string
  default     = "datadoghq.com"
}