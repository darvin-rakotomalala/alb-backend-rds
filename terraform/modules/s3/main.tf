############################################
# S3 BUCKET — JAR Artifacts
############################################

resource "aws_s3_bucket" "jar_artifacts" {
  bucket        = var.jar_bucket_name
  force_destroy = var.environment == "prod" ? false : true

  tags = {
    Name = "${var.naming_prefix}-jar-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "jar_artifacts" {
  bucket                  = aws_s3_bucket.jar_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "jar_artifacts" {
  bucket = aws_s3_bucket.jar_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_jar_artifacts_arn
      sse_algorithm     = "aws:kms"
    }
    # Reduces KMS API request volume during rapid ASG scale-out events
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "jar_artifacts" {
  bucket = aws_s3_bucket.jar_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# S3 Bucket Policy (Enforce SSE-KMS & TLS-only access)
############################################

resource "aws_s3_bucket_policy" "jar_artifacts" {
  bucket = aws_s3_bucket.jar_artifacts.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2InstanceRoleReadOnly"
        Effect = "Allow"
        Principal = {
          AWS = var.iam_role_ec2_app_arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.jar_artifacts.arn,
          "${aws_s3_bucket.jar_artifacts.arn}/*"
        ]
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.jar_artifacts.arn,
          "${aws_s3_bucket.jar_artifacts.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Sid       = "DenyUnencryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.jar_artifacts.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}
