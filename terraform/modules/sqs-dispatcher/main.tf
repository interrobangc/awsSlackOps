resource "aws_sqs_queue" "this" {
  name = "${var.env}-sqs-dispatcher"

  visibility_timeout_seconds = 120
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 15

  sqs_managed_sse_enabled = true

  tags = {
    name        = "${var.env}-sqs-dispatcher"
    terraform   = "true"
    environment = var.env
  }
}

resource "aws_ssm_parameter" "queue_url" {
  name  = "/${var.env}/slack-bot/sqs-queue-url"
  type  = "String"
  value = replace(aws_sqs_queue.this.url, "localhost", "localstack")

  tags = {
    terraform   = "true"
    environment = var.env
  }
}

data "aws_iam_policy_document" "allow_sqs_send" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_iam_policy" "allow_sqs_send" {
  name        = "${var.env}-sqs-dispatcher-sqs-send"
  description = "Provide access to ${aws_sqs_queue.this.name} sqs queue"
  policy      = data.aws_iam_policy_document.allow_sqs_send.json


  tags = {
    Name        = "${var.env}-sqs-dispatcher-sqs-send"
    terraform   = "true"
    environment = var.env
  }
}

//TODO output sqs queue

data "aws_iam_policy_document" "queue_dispatcher_sqs_policy_document" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:DeleteMessageBatch",
      "sqs:ChangeMessageVisibilityBatch",
    ]
    resources = [aws_sqs_queue.this.arn]
  }
}

/*==== IAM policy and role to interact with pending and completed queues ======*/
resource "aws_iam_policy" "queue_processor_sqs_policy" {
  name        = "${var.env}-sqs-dispatcher"
  description = "Provide access to ${var.env} async-queue sqs resources for the sqs-dispatcher job , intended to be used in the processing lambda."
  policy      = data.aws_iam_policy_document.queue_dispatcher_sqs_policy_document.json
}

# resource "aws_iam_role_policy_attachment" "queue_processor_sqs_policy_attach" {
#   role       = aws_iam_role.job_processor_lambda.name
#   policy_arn = aws_iam_policy.queue_processor_sqs_policy.arn
# }

# /*==== IAM policy to define any extra permissions needed to do the actual work ======*/
# resource "aws_iam_policy" "queue_processor_additional_policy" {
#   count       = var.additional_policy == null ? 0 : 1
#   name        = "${var.env}-sqs-dispatcher--additional"
#   description = "Provide access to ${var.env} resources for the sqs-dispatcher job, intended to be used in the processing lambda."
#   policy      = jsonencode(var.additional_policy)
# }

# resource "aws_iam_role_policy_attachment" "queue_processor_additional_policy_attach" {
#   count       = var.additional_policy == null ? 0 : 1
#   role        = aws_iam_role.job_processor_lambda.arn
#   policy_arn  = aws_iam_policy.queue_processor_additional_policy[0].arn
# }

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "v4.12.1"

  function_name = "${var.env}-slack-bot-sqs-dispatcher"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  publish       = true

  use_existing_cloudwatch_log_group = false
  attach_cloudwatch_logs_policy     = false

  source_path = [
    {
      path = "../../../../../../../"
      commands = [
        "echo 'pwd'",
        "pwd",
        "rm -rf /tmp/lambda-slack-bot-sqs-dispatcher",
        "mkdir /tmp/lambda-slack-bot-sqs-dispatcher",
        "cp package.json /tmp/lambda-slack-bot-sqs-dispatcher",
        "cp package-lock.json /tmp/lambda-slack-bot-sqs-dispatcher",
        "cp -r packages /tmp/lambda-slack-bot-sqs-dispatcher",
        "cd /tmp/lambda-slack-bot-sqs-dispatcher",
        "npm install --omit=dev -w packages/lambda/sqs-dispatcher",
        "rm -rf node_modules/@interrobangc",
        "mkdir dist",
        "cp -r packages/lambda/sqs-dispatcher/* dist",
        "cp -R node_modules dist",
        "cd dist",
        ":zip ."
      ]
    }
  ]

  event_source_mapping = {
    sqs = {
      event_source_arn        = aws_sqs_queue.this.arn
      function_response_types = ["ReportBatchItemFailures"]
    }
  }

  environment_variables = {
    NODE_ENV             = var.env
    AWS_ENDPOINT         = var.aws_endpoint
    SLACK_BOT_TOKEN      = var.bot_token
    SLACK_SIGNING_SECRET = var.signing_secret
    SQS_QUEUE_URL        = replace(aws_sqs_queue.this.url, "localhost", "localstack")
  }

  allowed_triggers = {
    sqs = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.this.arn
    }
  }

  tags = {
    Name = "${var.env}-slack-bot-sqs-dispatcher"

    terraform   = "true"
    environment = var.env
  }
}
