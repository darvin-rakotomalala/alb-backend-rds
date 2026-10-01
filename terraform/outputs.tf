############################################
# MAIN OUTPUTS
############################################

output "iam_role_terraform_execution_arn" {
  description = "IAM role terraform execution ARN"
  value       = module.iam.iam_role_terraform_execution_arn
}

output "ec2_instance_ids" {
  description = "Instance IDs of EC2 server (use these to start an SSM session)"
  value       = module.ec2.app_instance_ids
}

output "ec2_private_ips" {
  description = "Private IP addresses of the EC2 instance(s)"
  value       = module.ec2.app_instance_private_ips
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ssm_connect_commands" {
  description = "AWS CLI commands to open a Session Manager shell on each instance"
  value = [
    for id in module.ec2.app_instance_ids :
    "aws ssm start-session --target ${id} --region ${var.primary_region}"
  ]
}

output "rds_endpoint" {
  description = "Connection endpoint (host:port) for the RDS primary"
  value       = module.rds.rds_endpoint
}

output "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret holding the RDS master credentials"
  value       = module.secrets.db_credentials_secret_name
}

output "jar_bucket_name" {
  description = "Name of the S3 bucket storing the Spring Boot JAR artifact"
  value       = var.jar_bucket_name
}

output "ssm_port_forward_commands" {
  description = "AWS CLI commands to open an SSM port-forwarding session from your laptop to the RDS primary, via each private EC2 host"
  value = [
    for id in module.ec2.app_instance_ids :
    "aws ssm start-session --target ${id} --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"${module.rds.db_primary_address}\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"4898\"]}'"
  ]
}

output "kms_key_jar_artifacts_arn" {
  description = "ARN of the KMS key used for JAR artifacts"
  value       = module.kms.kms_key_jar_artifacts_arn
}
