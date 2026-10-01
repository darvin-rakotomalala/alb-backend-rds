# ─── Adjust for your environment ────────────────────────────────────

primary_region = "us-east-1"
environment    = "dev"
project_name   = "ce"
team_name      = "training"
cost_center    = "engineering"
compliance     = "internal"
github_org     = "darvin-rakotomalala"
github_repo    = "alb-backend-rds"
bucket_name    = "ce-dev-terraform-state-69127"

availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_cidr                     = "18.0.0.0/16"
single_nat_gateway           = false
alert_emails                 = ["darvintojo@gmail.com"]
app_port                     = 8080
db_port                      = 5432
db_secret_rotation_days      = 30
jar_bucket_name              = "ce-dev-springboot-jar-bucket-69127"
db_instance_class            = "db.r5.large"
db_engine_version            = "16.4"
db_allocated_storage         = 100
db_max_allocated_storage     = 500
db_name                      = "springbootcrud"
db_username                  = "app_admin"
db_multi_az                  = true
db_backup_retention_days     = 7
ec2_instance_type            = "t3.large"
app_instance_count           = 3 # fixed static fleet size, no Auto Scaling Group
ec2_root_volume_size         = 30
log_retention_days           = 30
health_check_path            = "/health"
enable_deletion_protection   = false
connection_threshold_percent = 80
cpu_threshold_percent        = 80
monthly_budget_ec2_usd       = 200
monthly_budget_rds_usd       = 300

# --- DNS / Certificate (required) ---
domain_name   = "cloudwithdarvin.com"
api_subdomain = "api"
