############################################
# IAM VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "current_account_id" {
  description = "Current account ID"
  type        = string
}

variable "current_partition" {
  description = "Current partition account ID"
  type        = string
  # default = data.aws_partition.current.partition
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
}

variable "jar_bucket_arn" {
  description = "Name of the S3 bucket that stores the Spring Boot JAR artifact"
  type        = string
}

variable "kms_key_jar_artifacts_arn" {
  description = "ARN of the KMS key used for JAR artifacts"
  type        = string
}

variable "kms_key_secrets_arn" {
  description = "ARN of Secrets Manager KMS key"
  type        = string
}

variable "kms_key_cloudwatch_arn" {
  description = "ARN of CloudWatch KMS key"
  type        = string
}

variable "log_group_app_tier_arn" {
  description = "ARN of CloudWatch log group App tier"
  type        = string
}

variable "db_master_user_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret holding the master credentials"
  type        = string
  sensitive   = true
}
