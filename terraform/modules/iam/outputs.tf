############################################
# IAM OUTPUTS
############################################

output "iam_role_terraform_execution_arn" {
  description = "IAM role terraform execution ARN"
  value       = aws_iam_role.terraform_execution.arn
}

output "ec2_app_role_arn" {
  description = "ARN of the EC2 application tier IAM role"
  value       = aws_iam_role.ec2_app.arn
}

output "ec2_app_role_name" {
  description = "Name of the EC2 application tier IAM role"
  value       = aws_iam_role.ec2_app.name
}

output "ec2_app_instance_profile_name" {
  description = "Name of the EC2 instance profile attached to the application server"
  value       = aws_iam_instance_profile.ec2_app.name
}

output "ec2_app_instance_profile_arn" {
  description = "ARN of the EC2 instance profile attached to the application server"
  value       = aws_iam_instance_profile.ec2_app.arn
}

output "rds_enhanced_monitoring_role_arn" {
  description = "ARN of the IAM role used for RDS Enhanced Monitoring"
  value       = aws_iam_role.rds_enhanced_monitoring.arn
}

output "kms_cloudwatch_policy_json" {
  description = "The rendered JSON policy document for the CloudWatch and SNS KMS key."
  value       = data.aws_iam_policy_document.kms_cloudwatch_policy.json
}
