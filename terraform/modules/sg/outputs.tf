############################################
# SG OUTPUTS
############################################

output "alb_security_group_id" {
  description = "ID of the ALB-SG security group"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the EC2-APP-SG security group"
  value       = aws_security_group.app.id
}

output "rds_security_group_id" {
  description = "ID of the RDS-SG security group"
  value       = aws_security_group.rds.id
}

output "ssm_endpoints_security_group_id" {
  description = "ID of the SSM-SG security group used by the interface VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
