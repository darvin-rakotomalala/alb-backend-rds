############################################
# RDS PostgreSQL Instance (Multi-AZ, isolated database subnets, 3 AZs)
############################################

# Latest stable PostgreSQL engine version available in this account/region
data "aws_rds_engine_version" "postgres" {
  engine             = "postgres"
  preferred_versions = [var.db_engine_version, "16", "15"]
  default_only       = false
  latest             = true
}

# Custom parameter group: enforce SSL/TLS for all connections, enable pg_stat_statements
resource "aws_db_parameter_group" "postgres" {
  name        = "${var.naming_prefix}-pg-params"
  family      = data.aws_rds_engine_version.postgres.parameter_group_family
  description = "Custom parameter group to enforce SSL in transit"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "1000" # log queries slower than 1s
    apply_method = "immediate"
  }

  tags = {
    Name = "${var.naming_prefix}-pg-params"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.naming_prefix}-rds-postgres"

  # Engine
  engine         = "postgres"
  engine_version = data.aws_rds_engine_version.postgres.version

  # Compute / storage
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_rds_key_arn

  # Database / auth
  db_name  = var.db_name
  username = var.db_username
  password = var.random_password_db_master_result
  port     = 5432

  # High availability — all reads/writes go to the primary; the standby is a
  # synchronous replica used only for automatic failover, across 3 AZs.
  multi_az               = var.db_multi_az
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  # Parameter group (enforces SSL)
  parameter_group_name = aws_db_parameter_group.postgres.name

  # Backups
  backup_retention_period   = var.db_backup_retention_days
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:30-sun:05:30"
  copy_tags_to_snapshot     = true
  deletion_protection       = var.environment == "prod" ? true : false
  skip_final_snapshot       = var.environment == "prod" ? false : true
  final_snapshot_identifier = "${var.naming_prefix}-rds-postgres-final"

  # Enhanced monitoring (1-minute granularity, OS-level metrics)
  monitoring_interval = 60
  monitoring_role_arn = var.rds_enhanced_monitoring_role_arn

  # Performance Insights, encrypted with the same KMS key
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_rds_key_arn
  performance_insights_retention_period = 7 # Adjust to 731 days if long-term auditing is required

  # Export PostgreSQL logs to CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Upgrades
  auto_minor_version_upgrade = true
  apply_immediately          = false

  tags = {
    Name = "${var.naming_prefix}-rds-postgres"
    Tier = "data"
  }
}
