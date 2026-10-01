############################################
# MAIN VARIABLES
############################################

variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "team_name" {
  description = "Team name"
  type        = string
}

variable "cost_center" {
  description = "Cost center"
  type        = string
}

variable "compliance" {
  description = "Compliance"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or user that owns the deployment repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name used for CI/CD deployments"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones to deploy across — 3 AZs for Multi-AZ high availability"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 Availability Zones are required."
  }
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT Gateway instead of one per AZ. Set false (default) for full HA, one NAT Gateway per AZ."
  type        = bool
}

variable "app_port" {
  description = "TCP port the Spring Boot application listens on"
  type        = number
}

variable "db_port" {
  description = "TCP port PostgreSQL listens on"
  type        = number
}

variable "alert_emails" {
  description = "Email addresses subscribed to the shared SNS alerts topic"
  type        = list(string)
}

variable "db_secret_rotation_days" {
  description = "Rotation interval (days) for the RDS master password in Secrets Manager"
  type        = number
}

variable "jar_bucket_name" {
  description = "Name of the S3 bucket that stores the Spring Boot JAR artifact"
  type        = string
}

variable "domain_name" {
  description = "Root domain name already hosted in Route 53 (e.g. cloudwithdarvin.com)"
  type        = string
}

variable "api_subdomain" {
  description = "Subdomain to alias to the ALB in addition to the root domain (e.g. api -> api.cloudwithdarvin.com)"
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

variable "log_retention_days" {
  description = "CloudWatch Logs retention period (days) before export to S3 for long-term storage"
  type        = number
}

variable "app_instance_count" {
  description = "Number of Spring Boot application EC2 instances to launch across the three app-tier AZs (>=2 recommended for the objective's high-availability requirement)"
  type        = number
}

variable "ec2_instance_type" {
  description = "Instance type for the Spring Boot application server"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "Root EBS volume size (GiB) for the application server"
  type        = number
}

variable "cpu_threshold_percent" {
  description = "RDS CPUUtilization alarm threshold (%)"
  type        = number
}

variable "connection_threshold_percent" {
  description = "RDS DatabaseConnections alarm threshold, as a percentage of the computed max_connections"
  type        = number
}

variable "monthly_budget_ec2_usd" {
  description = "Monthly budget limit (USD) for EC2 application-tier spend"
  type        = number
}

variable "monthly_budget_rds_usd" {
  description = "Monthly budget limit (USD) for RDS spend"
  type        = number
}

variable "health_check_path" {
  description = "HTTP path the ALB target group uses for application health checks"
  type        = string
}

variable "enable_deletion_protection" {
  type        = bool
  description = "If true, deletion protection will be enabled on the Application Load Balancer to prevent accidental deletion."
}
