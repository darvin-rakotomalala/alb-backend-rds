############################################
# VPC ENDPOINT VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "app_route_table_ids" {
  description = "IDs of public RT"
  type        = list(string)
}

variable "bucket_jar_artifacts_arn" {
  description = "ARN of S3 Bucket for JAR artifacts"
  type        = string
}

variable "app_subnet_ids" {
  description = "IDs of the private application-tier subnets"
  type        = list(string)
}

variable "ssm_endpoints_security_group_id" {
  description = "ID of the SSM-SG security group used by the interface VPC endpoints"
  type        = string
}

variable "current_account_id" {
  description = "Current account ID"
  type        = string
}

variable "db_master_user_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret holding the master credentials"
  type        = string
  sensitive   = true
}
