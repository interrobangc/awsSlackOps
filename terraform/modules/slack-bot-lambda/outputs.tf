output "invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "lambda_arn" {
  value = module.lambda_slack_bot.lambda_function_arn
}