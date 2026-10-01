############################################
# VPC FLOW LOGS OUTPUTS
############################################

output "vpc_flow_log_id" {
  description = "The ID of the VPC Flow Log."
  value       = aws_flow_log.main.id
}

output "vpc_flow_log_arn" {
  description = "The ARN of the VPC Flow Log."
  value       = aws_flow_log.main.arn
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group storing the VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_log.arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group storing the VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_log.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role used by the VPC Flow Log service."
  value       = aws_iam_role.flow_log.arn
}
