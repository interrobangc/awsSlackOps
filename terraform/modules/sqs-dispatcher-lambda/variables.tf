variable "env" {
  description = "Environment"
  type        = string
}

variable "signing_secret" {
  description = "Slack signing secret"
  type        = string
  sensitive   = true
}

variable "bot_token" {
  description = "Slack bot token"
  type        = string
  sensitive   = true
}

variable "aws_endpoint" {
  description = "AWS endpoint"
  type        = string
  default     = ""
}

variable "additional_policy" {
  description = "Any additional permissions required by the lambda processor function to do its work, beyond talking to the contact jobs SQS queues"
  type        = string
  default     = null
}

variable "repo_root" {
  description = "Root of the repository"
  type        = string
}
