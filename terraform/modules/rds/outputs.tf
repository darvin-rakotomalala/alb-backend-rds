############################################
# RDS OUTPUTS
############################################

output "db_instance_main" {
  description = "RDS db instance main"
  value       = aws_db_instance.main
}

output "db_instance_main_identifier" {
  description = "The main identifier of DB instance."
  value       = aws_db_instance.main.identifier
}

output "db_primary_endpoint" {
  description = "Connection endpoint (host:port) for the RDS primary instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_endpoint" {
  description = "Connection endpoint (host:port) of the RDS PostgreSQL primary instance"
  value       = aws_db_instance.main.endpoint
}

output "db_primary_address" {
  description = "Hostname only, for use in application configuration"
  value       = aws_db_instance.main.address
}

output "ssm_port_forward_to_rds_command" {
  description = "AWS CLI command to open an SSM port-forwarding session from a local machine, through the first app-tier instance, to the RDS primary (no bastion, no public DB access required)"
  value       = "aws ssm start-session --target ${var.app_instance_ids[0]} --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"${aws_db_instance.main.address}\"],\"portNumber\":[\"${var.db_port}\"],\"localPortNumber\":[\"4898\"]}' --region ${var.primary_region}"
}

output "rds_address" {
  description = "Hostname of the RDS PostgreSQL primary instance"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Port the RDS PostgreSQL instance listens on"
  value       = aws_db_instance.main.port
}

output "rds_identifier" {
  description = "Identifier of the RDS PostgreSQL instance"
  value       = aws_db_instance.main.identifier
}

output "rds_engine_version" {
  description = "PostgreSQL engine version deployed"
  value       = aws_db_instance.main.engine_version_actual
}
