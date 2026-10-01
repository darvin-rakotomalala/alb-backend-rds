############################################
# NCALs VARIABLES
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
  description = "List of Availability Zones"
  type        = list(string)
}

variable "app_port" {
  description = "TCP port the Spring Boot application listens on"
  type        = number
}

variable "db_port" {
  description = "TCP port the DB listens on"
  type        = number
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "IDs of App subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs of Public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDRs of App subnets"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDRs of DB subnets"
  type        = list(string)
}

variable "db_subnet_ids" {
  description = "IDs of DB subnets"
  type        = list(string)
}
