############################################
# SNS OUTPUTS
############################################

output "sns_alerts_topic_arn" {
  description = "The Amazon Resource Name (ARN) of the SNS topic used for alerts"
  value       = aws_sns_topic.alerts.arn
}
