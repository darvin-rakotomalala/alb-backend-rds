############################################
# S3 VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "jar_bucket_name" {
  description = "Name of the S3 bucket that stores the Spring Boot JAR artifact"
  type        = string
}

variable "iam_role_ec2_app_arn" {
  description = "ARN of IAM Role EC2 App"
  type        = string
}

variable "kms_key_jar_artifacts_arn" {
  description = "ARN of KMS key JAR artifacts"
  type        = string
}
