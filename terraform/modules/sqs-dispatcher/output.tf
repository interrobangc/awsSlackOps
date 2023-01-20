output "queue_url" {
  value = replace(aws_sqs_queue.this.url, "localhost", "localstack")
}

output "allow_sqs_send_arn" {
  value = aws_iam_policy.allow_sqs_send.arn
}