############################################
# CLOUDWATCH MONITORING OUTPUTS
############################################

output "alb_access_log_group_name" {
  value = aws_cloudwatch_log_group.alb_access_logs.name
}

output "ec2_access_log_group_name" {
  value = aws_cloudwatch_log_group.app_tier.name
}

output "ec2_access_log_group_arn" {
  value = aws_cloudwatch_log_group.app_tier.arn
}

output "rds_access_log_group_name" {
  value = aws_cloudwatch_log_group.rds_exported.name
}

output "cloudwatch_dashboards" {
  description = "Names of the CloudWatch dashboards created by this stack"
  value = [
    aws_cloudwatch_dashboard.alb.dashboard_name,
    aws_cloudwatch_dashboard.app_tier.dashboard_name,
    aws_cloudwatch_dashboard.rds.dashboard_name,
  ]
}
