module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "v4.12.1"

  function_name = "${var.env}-slack-bot-${var.name}"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  publish       = true

  use_existing_cloudwatch_log_group = false
  attach_cloudwatch_logs_policy     = false

  source_path = [
    {
      path = "${var.repo_root}/${var.path}"
      commands = [
        "cp -r ${var.repo_root}/${var.path} /tmp/${var.name}",
        "cd /tmp/${var.name}",
        "npm i --omit=dev",
        "cp -r node_modules dist",
        "cd dist",
        ":zip ."
      ]
    }
  ]

  environment_variables = {
    NODE_ENV             = var.env
    AWS_ENDPOINT         = var.aws_endpoint
    SLACK_BOT_TOKEN      = var.bot_token
    SLACK_SIGNING_SECRET = var.signing_secret
    SQS_QUEUE_URL        = var.queue_url
    CONFIG               = jsonencode(var.config)
  }

  allowed_triggers = {
    SlackBotLambda = {
      source_arn = var.slack_bot_lambda_arn
    },
  }

  tags = {
    Name = "${var.env}-slack-bot-${var.name}"

    terraform   = "true"
    environment = var.env
  }
}
