#########################################################
## VPC
#########################################################

module "vpc" {
  source             = "./modules/vpc"
  common_tags        = local.common_tags
  naming_prefix      = local.naming_prefix
  app_port           = var.app_port
  availability_zones = var.availability_zones
  db_port            = var.db_port
  single_nat_gateway = false
  vpc_cidr           = var.vpc_cidr
}

#########################################################
## VPC FLOW LOGS
#########################################################

module "flow-logs" {
  source                 = "./modules/flow-logs"
  naming_prefix          = local.naming_prefix
  common_tags            = local.common_tags
  kms_cloudwatch_key_arn = module.kms.kms_cloudwatch_key_arn
  log_retention_days     = var.log_retention_days
  vpc_id                 = module.vpc.vpc_id
}

#########################################################
## NACLs
#########################################################

module "nacls" {
  source              = "./modules/nacls"
  naming_prefix       = local.naming_prefix
  common_tags         = local.common_tags
  app_port            = var.app_port
  app_subnet_cidrs    = module.vpc.app_subnet_cidrs
  app_subnet_ids      = module.vpc.app_subnet_ids
  availability_zones  = var.availability_zones
  db_port             = var.db_port
  db_subnet_cidrs     = module.vpc.db_subnet_cidrs
  db_subnet_ids       = module.vpc.db_subnet_ids
  public_subnet_cidrs = module.vpc.public_subnet_cidrs
  public_subnet_ids   = module.vpc.public_subnet_ids
  vpc_cidr            = var.vpc_cidr
  vpc_id              = module.vpc.vpc_id
}

#########################################################
## SECURITY GROUPS
#########################################################

module "sg" {
  source        = "./modules/sg"
  common_tags   = local.common_tags
  naming_prefix = local.naming_prefix
  app_port      = var.app_port
  db_port       = var.db_port
  vpc_id        = module.vpc.vpc_id
}

#########################################################
## VPC ENDPOINTS
#########################################################

module "endpoint" {
  source                          = "./modules/endpoint"
  naming_prefix                   = local.naming_prefix
  common_tags                     = local.common_tags
  app_route_table_ids             = module.vpc.app_route_table_ids
  app_subnet_ids                  = module.vpc.app_subnet_ids
  bucket_jar_artifacts_arn        = module.s3.jar_artifacts_bucket_arn
  current_account_id              = data.aws_caller_identity.current.account_id
  db_master_user_secret_arn       = module.secrets.db_credentials_secret_arn
  primary_region                  = var.primary_region
  ssm_endpoints_security_group_id = module.sg.ssm_endpoints_security_group_id
  vpc_id                          = module.vpc.vpc_id
}

#########################################################
## IAM
#########################################################

module "iam" {
  source                    = "./modules/iam"
  current_account_id        = data.aws_caller_identity.current.account_id
  naming_prefix             = local.naming_prefix
  common_tags               = local.common_tags
  github_org                = var.github_org
  github_repo               = var.github_repo
  current_partition         = data.aws_partition.current.partition
  db_master_user_secret_arn = module.secrets.db_credentials_secret_arn
  jar_bucket_arn            = module.s3.jar_artifacts_bucket_arn
  kms_key_cloudwatch_arn    = module.kms.kms_cloudwatch_key_arn
  kms_key_jar_artifacts_arn = module.kms.kms_key_jar_artifacts_arn
  kms_key_secrets_arn       = module.kms.kms_secrets_key_arn
  log_group_app_tier_arn    = module.cloudwatch.ec2_access_log_group_arn
  primary_region            = var.primary_region
}

#########################################################
## KMS
#########################################################

module "kms" {
  source                           = "./modules/kms"
  naming_prefix                    = local.naming_prefix
  common_tags                      = local.common_tags
  current_account_id               = data.aws_caller_identity.current.account_id
  current_partition                = data.aws_partition.current.partition
  iam_role_ec2_app_arn             = module.iam.ec2_app_role_arn
  iam_role_terraform_execution_arn = module.iam.iam_role_terraform_execution_arn
  kms_cloudwatch_policy_json       = module.iam.kms_cloudwatch_policy_json
}

#########################################################
## S3
#########################################################

module "s3" {
  source                    = "./modules/s3"
  naming_prefix             = local.naming_prefix
  common_tags               = local.common_tags
  environment               = var.environment
  iam_role_ec2_app_arn      = module.iam.ec2_app_role_arn
  jar_bucket_name           = var.jar_bucket_name
  kms_key_jar_artifacts_arn = module.kms.kms_key_jar_artifacts_arn
}

#########################################################
## RDS
#########################################################

module "rds" {
  source                           = "./modules/rds"
  naming_prefix                    = local.naming_prefix
  common_tags                      = local.common_tags
  app_instance_ids                 = module.ec2.app_instance_ids
  db_allocated_storage             = var.db_allocated_storage
  db_backup_retention_days         = var.db_backup_retention_days
  db_engine_version                = var.db_engine_version
  db_instance_class                = var.db_instance_class
  db_max_allocated_storage         = var.db_max_allocated_storage
  db_multi_az                      = var.db_multi_az
  db_name                          = var.db_name
  db_port                          = var.db_port
  db_subnet_group_name             = module.vpc.db_subnet_group_name
  db_username                      = var.db_username
  environment                      = var.environment
  kms_rds_key_arn                  = module.kms.kms_rds_key_arn
  kms_secrets_key_arn              = module.kms.kms_secrets_key_arn
  primary_region                   = var.primary_region
  rds_enhanced_monitoring_role_arn = module.iam.rds_enhanced_monitoring_role_arn
  rds_security_group_id            = module.sg.rds_security_group_id
  random_password_db_master_result = module.secrets.random_password_db_master_result
}

#########################################################
## SECRETS MANAGER
#########################################################

module "secrets" {
  source              = "./modules/secrets"
  naming_prefix       = local.naming_prefix
  common_tags         = local.common_tags
  db_name             = var.db_name
  db_username         = var.db_username
  kms_secrets_key_arn = module.kms.kms_secrets_key_arn
  rds_address         = module.rds.rds_address
  rds_port            = module.rds.rds_port
}

#########################################################
## EC2
#########################################################

module "ec2" {
  source                        = "./modules/ec2"
  naming_prefix                 = local.naming_prefix
  common_tags                   = local.common_tags
  app_instance_count            = var.app_instance_count
  app_port                      = var.app_port
  app_security_group_id         = module.sg.app_security_group_id
  app_subnet_ids                = module.vpc.app_subnet_ids
  availability_zones            = var.availability_zones
  ec2_app_instance_profile_name = module.iam.ec2_app_instance_profile_name
  ec2_instance_type             = var.ec2_instance_type
  ec2_root_volume_size          = var.ec2_root_volume_size
  lb_listener_https             = module.alb.lb_listener_https
  db_instance_main              = module.rds.db_instance_main_identifier
  lb_target_group_app_arn       = module.alb.lb_target_group_app_arn
}

#########################################################
## ALB
#########################################################

module "alb" {
  source                     = "./modules/alb"
  naming_prefix              = local.naming_prefix
  common_tags                = local.common_tags
  acm_certificate_arn        = module.acm.acm_certificate_arn
  alb_security_group_id      = module.sg.alb_security_group_id
  app_port                   = var.app_port
  enable_deletion_protection = var.enable_deletion_protection
  health_check_path          = var.health_check_path
  public_subnet_ids          = module.vpc.public_subnet_ids
  vpc_id                     = module.vpc.vpc_id
}

#########################################################
## ACM
#########################################################

module "acm" {
  source          = "./modules/acm"
  naming_prefix   = local.naming_prefix
  common_tags     = local.common_tags
  api_subdomain   = var.api_subdomain
  domain_name     = var.domain_name
  route53_zone_id = data.aws_route53_zone.main.zone_id
}

#########################################################
## ROUTE 53
#########################################################

module "route53" {
  source          = "./modules/route53"
  naming_prefix   = local.naming_prefix
  common_tags     = local.common_tags
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
  api_subdomain   = var.api_subdomain
  domain_name     = var.domain_name
  route53_zone_id = data.aws_route53_zone.main.zone_id
}

#########################################################
## SNS
#########################################################

module "sns" {
  source                = "./modules/sns"
  naming_prefix         = local.naming_prefix
  common_tags           = local.common_tags
  alert_emails          = var.alert_emails
  current_account_id    = data.aws_caller_identity.current.account_id
  kms_cloudwatch_key_id = module.kms.kms_cloudwatch_key_id
}

#########################################################
## CLOUDWATCH
#########################################################

module "cloudwatch" {
  source                       = "./modules/cloudwatch"
  naming_prefix                = local.naming_prefix
  common_tags                  = local.common_tags
  alb_arn_suffix               = module.alb.alb_arn_suffix
  app_instance_count           = var.app_instance_count
  aws_instance_app             = module.ec2.aws_instance_app
  connection_threshold_percent = var.connection_threshold_percent
  cpu_threshold_percent        = var.cpu_threshold_percent
  current_account_id           = data.aws_caller_identity.current.account_id
  current_partition            = data.aws_partition.current.partition
  db_allocated_storage         = var.db_allocated_storage
  db_instance_class            = var.db_instance_class
  db_instance_main_identifier  = module.rds.db_instance_main_identifier
  kms_cloudwatch_key_arn       = module.kms.kms_cloudwatch_key_arn
  log_retention_days           = var.log_retention_days
  monthly_budget_ec2_usd       = var.monthly_budget_ec2_usd
  monthly_budget_rds_usd       = var.monthly_budget_rds_usd
  primary_region               = var.primary_region
  sns_alerts_topic_arn         = module.sns.sns_alerts_topic_arn
  target_group_arn_suffix      = module.alb.target_group_arn_suffix
}
