data "aws_ssm_parameter" "signing_secret" {
  name = "/${var.env}/slack-bot/signing-secret"
}

data "aws_ssm_parameter" "bot_token" {
  name = "/${var.env}/slack-bot/bot-token"
}

locals {
  events = [{name = "associate-vpn"}]
  signing_secret = data.aws_ssm_parameter.signing_secret.value
  bot_token = data.aws_ssm_parameter.bot_token.value
}

module "lambda" {
  source = "../slack-bot-lambda"

  env = var.env

  signing_secret = local.signing_secret
  bot_token      = local.bot_token
  aws_endpoint   = var.aws_endpoint
}

module "event_lambdas" {
  for_each = {for e in local.events: e.name => e}

  source = "../event-job-lambda"

  env  = var.env
  name = each.value.name

  slack_bot_lambda_arn = module.lambda.lambda_arn
  signing_secret       = local.signing_secret
  bot_token            = local.bot_token
  aws_endpoint         = var.aws_endpoint
}
