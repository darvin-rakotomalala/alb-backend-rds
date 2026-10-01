############################################
# SECRETS MANAGER OUTPUTS
############################################

output "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret holding the RDS master credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "random_password_db_master_result" {
  description = "Random password db master result"
  value       = random_password.db_master.result
}
