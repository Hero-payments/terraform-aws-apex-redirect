variable "target_domain" {
  description = "The name of the domain to redirect to"
  type        = string
}

variable "source_domains" {
  type        = list(string)
  description = "List of apex domains that should redirect"
  validation {
    condition     = alltrue([for d in var.source_domains : length(regexall("^[^.]+\\.[^.]+$", d)) > 0])
    error_message = "All domains must be apex domains (e.g., example.com)"
  }
  validation {
    condition     = length(var.source_domains) > 0
    error_message = "At least one domain must be provided"
  }
}

variable "source_repository" {
  description = "The repository calling this module"
  type        = string
  default     = ""
}

variable "redirection_schema" {
  description = "The schema to use for the redirection"
  type        = string
  default     = "https"
  validation {
    condition     = can(regex("https?", var.redirection_schema))
    error_message = "The schema must be either http or https"
  }
}

variable "managed_by" {
  description = "The team responsible for managing the resources"
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "The environment the resources are deployed to"
  type        = string
  default     = "prod"
}
variable "tags" {
  description = "Extra tags to add to the created resources"
  type        = map(string)
  default     = {}
}
