############################################
# VPC FLOW LOGS VARIABLES
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

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
}

variable "kms_cloudwatch_key_arn" {
  description = "ARN of the KMS key used for CloudWatch Logs / SNS encryption"
  type        = string
}
