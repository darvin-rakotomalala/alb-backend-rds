############################################
# CLOUDWATCH MONITORING VARIABLES
############################################

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period (days) before export to S3 for long-term storage"
  type        = number
}

variable "kms_cloudwatch_key_arn" {
  description = "ARN of the KMS key used for CloudWatch Logs / SNS encryption"
  type        = string
}

variable "cpu_threshold_percent" {
  description = "RDS CPUUtilization alarm threshold (%)"
  type        = number
}

variable "connection_threshold_percent" {
  description = "RDS DatabaseConnections alarm threshold, as a percentage of the computed max_connections"
  type        = number
}

variable "sns_alerts_topic_arn" {
  description = "ARN of the shared SNS topic used by ALB, EC2 and RDS CloudWatch alarms"
  type        = string
}

variable "app_instance_count" {
  description = "Number of Spring Boot application EC2 instances to launch across the two app-tier AZs (>=2 recommended for the objective's high-availability requirement)"
  type        = number
}

variable "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  type        = string
}

variable "aws_instance_app" {
  description = "App tier EC2 instances (id + tags), passed in from the main module's aws_instance_app output."
  type = list(object({
    id   = string
    tags = map(string)
  }))
}

variable "db_instance_main_identifier" {
  description = "The main identifier of DB instance."
  type        = string # aws_db_instance.main.identifier
}

variable "db_allocated_storage" {
  description = "Allocated storage (GiB) for RDS"
  type        = number
}

variable "db_instance_class" {
  description = "RDS instance class for the PostgreSQL primary"
  type        = string
}

variable "monthly_budget_ec2_usd" {
  description = "Monthly budget limit (USD) for EC2 application-tier spend"
  type        = number
}

variable "monthly_budget_rds_usd" {
  description = "Monthly budget limit (USD) for RDS spend"
  type        = number
}

variable "current_account_id" {
  description = "Current account ID"
  type        = string
}

variable "current_partition" {
  description = "Current partition account ID"
  type        = string
}

