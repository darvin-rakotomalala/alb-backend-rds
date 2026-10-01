############################################
# VPC VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

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
