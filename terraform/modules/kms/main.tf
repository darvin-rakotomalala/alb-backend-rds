############################################
# KMS Keys (encryption at rest for RDS, Secrets Manager, CloudWatch Logs, S3)
############################################

# ---------- KMS key: RDS encryption ----------
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS PostgreSQL encryption at rest"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:${var.current_partition}:iam::${var.current_account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowRDSServiceUse"
        Effect    = "Allow"
        Principal = { Service = "rds.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.current_account_id
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.naming_prefix}-rds-kms-key"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.naming_prefix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# ---------- KMS key: Secrets Manager encryption ----------
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager (DB credentials) encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:${var.current_partition}:iam::${var.current_account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowSecretsManagerServiceUse"
        Effect    = "Allow"
        Principal = { Service = "secretsmanager.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.current_account_id
          }
        }
      },
      {
        # Required so RDS can create/manage the master-user secret on our behalf
        # when aws_db_instance.main.manage_master_user_password = true
        Sid       = "AllowRDSServiceUse"
        Effect    = "Allow"
        Principal = { Service = "rds.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.current_account_id
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.naming_prefix}-secrets-kms-key"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.naming_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# ---------- KMS key: CloudWatch Logs / SNS encryption ----------
resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for CloudWatch Logs (VPC Flow Logs, App tier, RDS, ALB) and SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = var.kms_cloudwatch_policy_json

  tags = {
    Name = "${var.naming_prefix}-cloudwatch-kms-key"
  }
}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/${var.naming_prefix}-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch.key_id
}

# -------- Customer Managed KMS Key for JAR Artifacts ----------
resource "aws_kms_key" "jar_artifacts" {
  description             = "KMS key used for securing JAR artifact storage in S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:${var.current_partition}:iam::${var.current_account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowEC2InstanceRoleDecryption"
        Effect    = "Allow"
        Principal = { AWS = var.iam_role_ec2_app_arn }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.naming_prefix}-jar-kms-key"
  }
}

resource "aws_kms_alias" "jar_artifacts" {
  name          = "alias/${var.naming_prefix}-jar-artifacts"
  target_key_id = aws_kms_key.jar_artifacts.key_id
}
