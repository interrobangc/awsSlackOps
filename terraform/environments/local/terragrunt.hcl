locals {
  repo_root = get_repo_root()
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "eu-west-1"
  s3_use_path_style           = true

  # Make it faster by skipping some things
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localstack:4566"
    apigatewayv2   = "http://localstack:4566"
    cloudformation = "http://localstack:4566"
    cloudwatch     = "http://localstack:4566"
    cloudwatchlogs = "http://localstack:4566"
    dynamodb       = "http://localstack:4566"
    ec2            = "http://localstack:4566"
    es             = "http://localstack:4566"
    elasticache    = "http://localstack:4566"
    firehose       = "http://localstack:4566"
    iam            = "http://localstack:4566"
    kinesis        = "http://localstack:4566"
    lambda         = "http://localstack:4566"
    rds            = "http://localstack:4566"
    redshift       = "http://localstack:4566"
    route53        = "http://localstack:4566"
    s3             = "http://localstack:4566"
    secretsmanager = "http://localstack:4566"
    ses            = "http://localstack:4566"
    sns            = "http://localstack:4566"
    sqs            = "http://localstack:4566"
    ssm            = "http://localstack:4566"
    stepfunctions  = "http://localstack:4566"
    sts            = "http://localstack:4566"
  }
}
EOF
}

inputs = {
  env          = "local"
  aws_endpoint = "http://localstack:4566"
  repo_root    = local.repo_root
}

terraform {
  source = "${local.repo_root}/terraform/modules//slack-bot"
}
