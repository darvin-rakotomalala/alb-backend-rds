############################################
# EC2 VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "availability_zones" {
  description = "Three AWS Availability Zones used across all tiers"
  type        = list(string)
}

variable "app_instance_count" {
  description = "Number of Spring Boot application EC2 instances to launch across the three app-tier AZs (>=2 recommended for the objective's high-availability requirement)"
  type        = number
}

variable "ec2_instance_type" {
  description = "Instance type for the Spring Boot application server"
  type        = string
}

variable "app_subnet_ids" {
  description = "IDs of the private application-tier subnets"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ID of the EC2-APP-SG security group"
  type        = string
}

variable "ec2_app_instance_profile_name" {
  description = "Name of the EC2 instance profile attached to the application server"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "Root EBS volume size (GiB) for the application server"
  type        = number
}

variable "db_instance_main" {
  description = "RDS db instance main"
  type        = string
}

variable "lb_listener_https" {
  description = "HTTPS of ALB listener"
  type        = string
}

variable "lb_target_group_app_arn" {
  description = "ARN of Target Group ALB listener"
  type        = string
}

variable "app_port" {
  description = "TCP port the Spring Boot application listens on"
  type        = number
}
