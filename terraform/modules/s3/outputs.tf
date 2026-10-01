############################################
# S3 OUTPUTS
############################################

output "jar_artifacts_bucket_name" {
  value = aws_s3_bucket.jar_artifacts.id
}

output "jar_artifacts_bucket_arn" {
  description = "ARN of the S3 bucket storing the Spring Boot JAR artifact"
  value       = aws_s3_bucket.jar_artifacts.arn
}
