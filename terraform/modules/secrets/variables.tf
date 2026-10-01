############################################
# SECRETS MANAGER VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "kms_secrets_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption"
  type        = string
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS PostgreSQL instance"
  type        = string
}

variable "rds_port" {
  description = "Port the RDS PostgreSQL instance listens on"
  type        = string
}

variable "rds_address" {
  description = "Hostname of the RDS PostgreSQL primary instance"
  type        = string
}
