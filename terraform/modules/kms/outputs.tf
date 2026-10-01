############################################
# KMS OUTPUTS
############################################

output "kms_rds_key_arn" {
  description = "ARN of the KMS key used for RDS encryption"
  value       = aws_kms_key.rds.arn
}

output "kms_secrets_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption"
  value       = aws_kms_key.secrets.arn
}

output "kms_cloudwatch_key_arn" {
  description = "ARN of the KMS key used for CloudWatch Logs / SNS encryption"
  value       = aws_kms_key.cloudwatch.arn
}

output "kms_cloudwatch_key_id" {
  description = "ID of the KMS key used for CloudWatch Logs / SNS encryption"
  value       = aws_kms_key.cloudwatch.id
}

output "kms_key_jar_artifacts_arn" {
  description = "ARN of the KMS key used for JAR artifacts"
  value       = aws_kms_key.jar_artifacts.arn
}
