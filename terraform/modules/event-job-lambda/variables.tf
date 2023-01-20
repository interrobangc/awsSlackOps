variable "env" {
  description = "Environment"
  type        = string
}

variable "name" {
  description = "Name"
  type        = string
}

variable "slack_bot_lambda_arn" {
  description = "Slack bot lambda ARN"
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