resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.env}-slack-bot"
  description = "${var.env} Slack Bot"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_slack_bot.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_slack_bot.lambda_function_invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.env
}

module "lambda_slack_bot" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.env}-slack-bot"
  description   = "Base slack bot"
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  use_existing_cloudwatch_log_group = false
  attach_cloudwatch_logs_policy     = false

  source_path = [
    {
      path     = "../../../../../../../"
      commands = [
        "echo 'pwd'",
        "pwd",
        "rm -rf /tmp/lambda-slack-bot",
        "mkdir /tmp/lambda-slack-bot",
        "cp package.json /tmp/lambda-slack-bot",
        "cp package-lock.json /tmp/lambda-slack-bot",
        "cp -r packages /tmp/lambda-slack-bot",
        "cd /tmp/lambda-slack-bot",
        "npm install --omit=dev -w packages/lambda/slack-bot",
        "rm -rf node_modules/@interrobangc",
        "mkdir dist",
        "cp -r packages/lambda/slack-bot/* dist",
        "cp -R node_modules dist",
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
  }

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
    },
  }

  tags = {
    Name = "${var.env}-slack-bot"

    terraform   = "true"
    environment = var.env
  }
}
