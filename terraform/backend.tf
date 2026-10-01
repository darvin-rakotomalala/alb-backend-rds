###############################################
# Backend configuration
###############################################
/*
terraform {
  backend "s3" {
    bucket = "ce-dev-terraform-state-69127"
    key    = "dev/infrastructure/terraform.tfstate"
    region = "us-east-1"
    # Encryption
    encrypt = true # Encrypt state at rest
    # use_lockfile stores the lock directly in S3 as a .tflock file alongside your state,
    # eliminating the need for a DynamoDB table entirely.
    use_lockfile = true # ← new parameter
    # Lock acquisition timeout
    # Default: 0 (wait indefinitely)
    max_retries = 10
  }
}
*/
