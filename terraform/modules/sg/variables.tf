############################################
# SG VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "app_port" {
  description = "TCP port the Spring Boot application listens on"
  type        = number
}

variable "db_port" {
  description = "TCP port the Spring Boot application listens on"
  type        = number
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
