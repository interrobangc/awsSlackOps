resource "aws_ssm_parameter" "signing-secret" {
  name        = "/${var.env}/slack-bot/signing-secret"
  type        = "SecureString"
  value       = var.signing_secret

  tags = {
    terraform = "true"
    environment = var.env
  }
}

resource "aws_ssm_parameter" "bot-token" {
  name        = "/${var.env}/slack-bot/bot-token"
  type        = "SecureString"
  value       = var.bot_token

  tags = {
    terraform = "true"
    environment = var.env
  }
}
