############################################
# SECRETS MANAGER — RDS Master Credentials
############################################

# Randomly generated master password for the RDS PostgreSQL instance
resource "random_password" "db_master" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.naming_prefix}/rds/dbcrud-credentials"
  description             = "Master credentials for the ${var.naming_prefix} RDS PostgreSQL instance"
  kms_key_id              = var.kms_secrets_key_arn
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-db-credentials"
  })
}

# Initial secret value. Terraform ignores drift on this after the first rotation
# runs, since Secrets Manager (via the rotation Lambda) becomes the source of truth.
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_master.result
    engine   = "postgres"
    host     = var.rds_address
    port     = var.rds_port
    dbname   = var.db_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
