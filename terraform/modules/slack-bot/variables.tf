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