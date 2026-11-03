variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "stage", "production"], var.environment)
    error_message = "Choose dev, stage or production."
  }
}
variable "namespace_name" {
  type        = string
  description = "Globally unique Service Bus namespace name; replace the example value."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,48}[a-z0-9]$", var.namespace_name))
    error_message = "Use 6-50 lowercase letters, digits or hyphens; start with a letter and end with a letter or digit."
  }
}
