############################################
# ROUTE 53 VARIABLES
############################################

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "domain_name" {
  description = "Root domain name already hosted in Route 53 (e.g. cloudwithdarvin.com)"
  type        = string
}

variable "api_subdomain" {
  description = "Subdomain to alias to the ALB in addition to the root domain (e.g. api -> api.cloudwithdarvin.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "Zone ID of the existing Route 53 public hosted zone for var.domain_name"
  type        = string
}

variable "alb_dns_name" {
  description = "The domain name (DNS name) of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer (used for Route 53 alias records)"
  type        = string
}
