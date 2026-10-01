############################################
# RDS VARIABLES
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

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_engine_version" {
  description = "Preferred PostgreSQL major version (latest stable minor is resolved automatically)"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for the primary PostgreSQL instance"
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial allocated storage (GiB) for the RDS instance"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Storage autoscaling ceiling (GiB) for the RDS instance"
  type        = number
}

variable "db_name" {
  description = "Initial database name created on the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
}

variable "db_multi_az" {
  description = "Enable Multi-AZ synchronous standby for the RDS instance"
  type        = bool
}

variable "db_backup_retention_days" {
  description = "Automated backup retention period (days)"
  type        = number
}

variable "kms_rds_key_arn" {
  description = "ARN of the KMS key used for RDS encryption"
  type        = string
}

variable "kms_secrets_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption"
  type        = string
}

variable "db_port" {
  description = "TCP port the Spring Boot application listens on"
  type        = number
}

variable "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group"
  type        = string
}

variable "rds_security_group_id" {
  description = "ID of the RDS-SG security group"
  type        = string
}

variable "rds_enhanced_monitoring_role_arn" {
  description = "ARN of the IAM role used for RDS Enhanced Monitoring"
  type        = string
}

variable "app_instance_ids" {
  description = "IDs of the static application-tier EC2 instances"
  type        = list(string)
}

variable "random_password_db_master_result" {
  description = "Random password db master result"
  type        = string
  sensitive   = true
}

