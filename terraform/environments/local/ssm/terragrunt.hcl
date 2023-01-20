
terraform {
  source = "../../../modules//ssm"
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
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}
EOF
}

inputs = {
  env = "local"
  aws_endpoint = "http://localstack:4566"
  // bot_token = run_cmd("aws", "--region=eu-west-1", "--endpoint=http://localhost:4566", "ssm", "get-parameter", "--name=/local/slack-bot/bot-token", "--with-decryption", "--query=\"Parameter.Value\"", "--output=text")
  // signing_secret = run_cmd("aws", "--region=eu-west-1", "--endpoint=http://localhost:4566", "ssm", "get-parameter", "--name=/local/slack-bot/signing-secret", "--with-decryption", "--query=\"Parameter.Value\"", "--output=text")
}