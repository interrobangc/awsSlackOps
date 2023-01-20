resource "aws_sqs_queue" "this" {
  name = "${var.environment}-${var.name}"

  visibility_timeout_seconds = 120
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 15

  sqs_managed_sse_enabled = true

  tags = {
    name        = "${var.environment}-${var.name}"
    terraform   = "true"
    environment = var.env
  }
}

resource "aws_ssm_parameter" "queue_url" {
  name  = "/${var.environment}/slack-bot/sqs-queue-url"
  type  = "String"
  value = aws_sqs_queue.this.url

  tags = {
    terraform   = "true"
    environment = var.env
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "${var.environment}-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
  tags = merge(
  {
    Name        = "${var.environment}-${var.name}"
    terraform   = "true"
    environment = var.env
  },
  )
}

resource "aws_iam_role_policy_attachment" "lambda_execution_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

data "aws_iam_policy_document" "allow_sqs_send" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_iam_policy" "allow_sqs_send" {
  name        = "${var.environment}-${var.namespace}-sqs-send"
  description = "Provide access to ${var.environment}${name} sqs queue"
  policy      = data.aws_iam_policy_document.allow_sqs_send.json


  tags = {
    Name        = "${var.environment}-${var.namespace}-sqs-send"
    terraform   = "true"
    environment = var.env
  }
}

//TODO output sqs queue

data "aws_iam_policy_document" "jobs_processor_sqs_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    resources = [var.completed_sqs_queue_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:DeleteMessageBatch",
      "sqs:ChangeMessageVisibilityBatch",
    ]
    resources = [aws_sqs_queue.pending_jobs_queue.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]
    resources = ["arn:aws:s3:::tl-aselo-docs-*-${var.environment}/*"]
  }

  #TODO: we probably want to pass these in as part of the config
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.environment}/s3/",
      "arn:aws:ssm:*:*:parameter/${var.environment}/s3/*",
      "arn:aws:ssm:*:*:parameter/${var.environment}/twilio/",
      "arn:aws:ssm:*:*:parameter/${var.environment}/twilio/*",
    ]
  }
}

/*==== IAM policy and role to interact with pending and completed queues ======*/
resource "aws_iam_policy" "jobs_processor_sqs_policy" {
  name        = "${var.environment}-${var.namespace}-${var.contact_job_type}-processor"
  description = "Provide access to ${var.environment} async-jobs sqs resources for the ${var.namespace}-${var.contact_job_type} job , intended to be used in the processing lambda."
  policy      = data.aws_iam_policy_document.jobs_processor_sqs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "jobs_processor_sqs_policy_attach" {
  role       = aws_iam_role.job_processor_lambda.name
  policy_arn = aws_iam_policy.jobs_processor_sqs_policy.arn
}

/*==== IAM policy to define any extra permissions needed to do the actual work ======*/
resource "aws_iam_policy" "contact_jobs_processor_additional_policy" {
  count       = var.additional_policy == null ? 0 : 1
  name        = "${var.environment}-${var.namespace}-${var.contact_job_type}-additional"
  description = "Provide access to ${var.environment} resources for the ${var.namespace}-${var.contact_job_type} job, intended to be used in the processing lambda."
  policy      = jsonencode(var.additional_policy)
}

resource "aws_iam_role_policy_attachment" "contact_jobs_processor_additional_policy_attach" {
  count       = var.additional_policy == null ? 0 : 1
  role        = aws_iam_role.job_processor_lambda.arn
  policy_arn  = aws_iam_policy.contact_jobs_processor_additional_policy[0].arn
}

resource "aws_lambda_function" "contact_job_processor_lambda" {
  // This ensures that the image has been created before we try to create the lambda
  depends_on = [module.ecr-image-default-tag.id]

  function_name = "${var.environment}-${var.namespace}-${var.contact_job_type}"
  role          = aws_iam_role.job_processor_lambda.arn
  package_type  = "Image"
  image_uri     = "${module.ecr_repository.repository_url}:live"
  #TODO: this is probably a bit long
  timeout       = 300

  environment {
    variables = {
      NODE_ENV                = var.environment
      completed_sqs_queue_url = var.completed_sqs_queue_url
    }
  }
}

resource "aws_lambda_event_source_mapping" "contact_job_processor_lambda_event_source" {
  function_name    = aws_lambda_function.contact_job_processor_lambda.function_name
  enabled          = true
  event_source_arn = aws_sqs_queue.pending_jobs_queue.arn

  function_response_types = ["ReportBatchItemFailures"]
}