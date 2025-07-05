output "sns_topic_arn" {
  value = aws_sns_topic.notifications_nisha.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.main_queue_nisha.id
}