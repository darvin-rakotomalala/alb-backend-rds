## Project: Deploying a Two-Tier Multi-AZ Architecture → EC2 + RDS PostgreSQL (Terraform)

***

**Objective**: Create a highly available, Scalable, Secure VPC with public, cost-effective, application, and database
tiers across 3 Availability Zones. Connectivity Two-tier application of backend App tier and RDS database tier each in
separate private subnet.

**Specification**: a public ALB in front of a Spring Boot application tier (EC2, private subnets), backed by an isolated
RDS PostgreSQL Multi-AZ database, all across 3 Availability Zones (`us-east-1a`, `us-east-1b`, `us-east-1c`). Deploying
a few EC2 instances in a private subnet and attach them to an application load balancer in a public subnet.

## Architecture overview

***

**Core Components**

* **Networking**: VPC with 3 AZs, public/private/database subnets.
* **ALB public facing**: Application Load Balancer (ALB) in public subnet (3 AZs) for distributing incoming traffic.
* **Application Tier**: EC2 instances backend App Tier in private subnet with SSM agent installed (which has NAT Gateway
  to access internet). **Access via SSM only** — no bastion host, no SSH inbound rule, no public IP on
  the app or DB tiers.
* **Database Tier**: Data Tier RDS PostgreSQL (Multi-AZ) in isolated database subnets.
* **IAM role**: Instance role with policy to allow EC2 access for S3, SSM, RDS, KMS, Secrets Manger and CloudWatch
* **S3** — Stores our application JAR file and for access logs contain detailed information about requests sent to the
  load balancer. Each log contains information such as the time the request was received, the client’s IP address,
  latencies, request paths, and server responses. You can use these access logs to analyze traffic patterns and
  troubleshoot issues.
* **KMS** — KMS key for RDS, Secrets Manger, CloudWatch encryption.
* **AWS Secrets Manager** — to securely store, rotate, and manage database credentials.
* **Route 53/DNS tier** — Handle DNS resolution
* **Certificate Manager** — SSL/TLS termination with ACM certificates used by ALB.
* **CloudWatch** — Log group for ALB, App tier and RDS database.
* **SNS** — Shared KMS-encrypted SNS topic + email subscription.
* **VPC endpoints**: for SSM, EC2 messages, and SSM messages.
* **Security groups**: ```ALB-SG```, ```EC2-APP-SG```, ```RDS-SG``` and SSM Interface Endpoints.
* **Security**: Security Groups, NACLs, VPC endpoints, KMS for encryption, IAM roles with the least privilege.

Here is the architecture diagram related to the scenario we are going to address.

![alb-backend-rds.png](../alb-backend-rds.png)

**Traffic Flow**

1. User requests → Route 53 → ALB (HTTPS / TLS 1.2/1.3)
2. ALB → App tier Servers
3. App tier Servers → RDS (Private IP / TLS 1.2+)
4. Response → ALB → Route 53 → User
5. All logs → CloudWatch, audit → CloudTrail

## Implementation steps with Terraform

***

### VPC Configuration

***

**VPC**: 18.0.0.0/16

**Public Subnets for ALB public facing and NAT gateways**

- 18.0.1.0/24 (us-east-1a)
- 18.0.2.0/24 (us-east-1b)
- 18.0.3.0/24 (us-east-1c)

**Private Subnets for Backend Application Tier server - Can reach the internet through NAT gateway**

- 18.0.11.0/24 (us-east-1a)
- 18.0.12.0/24 (us-east-1b)
- 18.0.13.0/24 (us-east-1c)

**Private Subnets for Database Tier and sensitive data - No internet access at all**

- 18.0.21.0/24 (us-east-1a)
- 18.0.22.0/24 (us-east-1b)
- 18.0.33.0/24 (us-east-1c)

- 3 NAT Gateways and One NAT Gateway per AZ for high availability

**Step 1: Create VPC**

- CIDR: 18.0.0.0/16
- Enable DNS hostnames
- Enable DNS support (enabled by default)
- Enable Internet Gateway
- Enable NAT Gateway and allocate Elastic IPs per AZ
- 3 NAT Gateways one per AZ for high availability
- Create VPC Flow Logs with CloudWatch
- Generate the outputs

**Step 2: Create Subnets**

- Public Subnets for ALB distributes incoming traffic: 18.0.1.0/24 (AZ-a), 18.0.2.0/24 (AZ-b), 18.0.3.0/24 (AZ-c)
- Enable auto-assign public IP for public subnets
- Private Subnets for Application Tier: 18.0.11.0/24 (AZ-a), 18.0.12.0/24 (AZ-b), 18.0.13.0/24 (AZ-c)
- Application tier in private subnets can reach the internet through NAT gateway
- Private subnets for Data Tier: 18.0.21.0/24 (AZ-a), 18.0.22.0/24 (AZ-b), 18.0.23.0/24 (AZ-c)
- Database tier in private subnets no NAT and no Internet Gateway
- Create DB subnet group
- Generate the outputs

**Step 3: Create Route Tables**

- Public Route Table routes to internet gateway
- Associate public subnets with public route table
- App tier route table in the private subnet’s route tables with a route to 0.0.0.0/0 using the NAT gateway
- For backend App tier add route to Internet Gateway
- Data tier route table in the private subnet no NAT gateway
- Associate subnets with route tables for application Backend App Tier
- Associate subnets with route tables for database Data Tier
- Generate the outputs

### Security Groups

***

**Step 4: Create Security Groups**

- Each Security Groups use separate security Group rules ```aws_security_group_rule``` or
  ```aws_vpc_security_group_ingress_rule``` or ```aws_vpc_security_group_egress_rule``` resources instead of inline
  rules to avoid circular dependencies. Refer the security group instead of IP addresses
- Add Descriptions to every rule
- Security Groups for the application load balancer with ingress and egress for all IP addresses
- Application servers in private subnets (only accessible from the SSM)
- Security Groups for the EC2 instances with ingress from the load balancer security group only and egress to all IP
  addresses
- Databases in another private subnet (only accessible from the application servers)
- Network:
    - `ALB-SG` Security Group — Allow 80/443 from internet (public-facing), redirect to HTTPS
        - Allow HTTP from anywhere
        - Allow HTTPS from anywhere
    - `EC2-APP-SG` Security Group — Inbound from internet (only from ALB public-facing to App tier
        - App tier can send traffic to the database
    - `RDS-SG` Security Group — Allow 5432 from `EC2-APP-SG` App tier (only from app)
        - Allow PostgreSQL from backend application tier
        - The DB is isolated in private subnets; only authorized application servers can reach it (via security groups).
        - The security group attached to RDS instance to accept incoming database traffic exclusively from the App tier
          security group (Select the Security Group ID of App Tier)
- ```SSM-SG``` Security group for Interface VPC Endpoints: allow HTTPS from the entire VPC CIDR
- Generate the outputs

**Step 5: Create Network ACLs (Additional Layer)**

- Public subnets NACL: Allow 80, 443 inbound, Ephemeral ports (for return traffic) outbound
- Associate with public subnets
- Allow inbound from private subnets only (app tier, port = 5432)
- Allow return traffic (ephemeral ports, from_port = 1024, to_port = 65535)
- Allow isolated workloads to initiate HTTPS connections to VPC endpoints (from_port = 443, to_port = 443)
- Allow outbound responses to private subnets (from_port = 1024, to_port = 65535)
- Private subnets NACL — Deny all inbound from internet, allow VPC CIDR
- Data subnets NACL — Deny all except from application subnet CIDR
- Generate the outputs

**Step 6: Create VPC Endpoints**

- **AWS Systems Manager Endpoints**: These three endpoints enable AWS Systems Manager to manage EC2 instances in private
  subnets without internet access. Attach it on EC2 backend server.
    * ```SSM endpoint``` - for Systems Manager API calls
    * ```SSM Messages endpoint``` - for Session Manager connections
    * ```EC2 Messages endpoint``` - used by SSM Agent in Regions that support it
- Interface endpoint for Secrets Manager to read only the database password. Attach it on EC2 backend server.
- Generate the outputs

### Public facing Configuration

***

**Step 7: Create Route 53**

Use a **DNS zone** for my existing domain `cloudwithdarvin.com` Two **A records** that point the domain to an ALB
distribution:

- `cloudwithdarvin.com` ── alias ──► Application Load Balancer (root domain)
- `api.cloudwithdarvin.com` ── alias ──► Application Load Balancer

**Step 8: Create Certificate Manager (ACM)**

Provision SSL Certificate (ACM + DNS Validation)

- SSL/TLS certificate with DNS validation
- Create DNS Validation Records
- Used by ALB
- Enforces HTTPS (443)
- Supports TLS 1.2 and TLS 1.3

### Application Load Balancer, EC2 backend server and S3 Bucket

***

**Step 9: Create Application Load Balancer for distributes incoming traffic**

- ALB in three AZs
- Public-facing allow HTTP/HTTPS from anywhere, redirect to HTTPS
- Create Application Load Balancing form inbound anywhere request to EC2 backend App Tier
- Create a target group and attach the EC2 instance to the target group
- Create ALB Listener (80) and redirect to HTTPS
- Set a Health checks
- Generate the outputs

**Step 10: Create Certificate Manager (ACM) for ALB**

* Associate an ACM SSL/TLS certificate with an Application Load Balancer
* Used by Application Load Balancer Listener
* Enforces HTTPS (443)
* Supports TLS 1.2 and TLS 1.3

**Step 11: Create EC2 Application Tier server in Private Subnet**

- Create three EC2 instances (Ubuntu LTS server) in private subnets spread across three availability zones
- Instance type: ```t3.large```
- Name: ```spring-boot-server```
- Attach App tier private subnet
- Attach ```EC2-APP-SG``` Security Group
- Install and enable detailed monitoring on EC2 instance
- Attach the EC2 instance profile
- Add ```user_data``` to install the:
    - Curl
    - CloudWatch Agent
    - AWS CLI
    - Java OpenJDK 11
    - plsql Postgres
    - Enable SSM agent
- Generate the outputs

**Step 12: Create S3 bucket for artifact storage JAR file**

- This bucket contain our Spring Boot application JAR file
- Name: ```ce-dev-springboot-jar-bucket-69127```
- Create policy to allow EC2 instance to read file in this bucket
- Attach this permission on EC2 profile name

**Step 13 - Create Gateway VPC Endpoint for S3**

The S3 Gateway Endpoint is the most commonly used VPC endpoint. It adds a route to our route tables that directs S3
traffic through the endpoint instead of through the internet.

- Create Gateway VPC Endpoint for S3
- Create S3 Endpoint with Custom Policy: For better security, restrict the endpoint to specific buckets.
    - AllowSpecificBuckets: Policy restricting access to specific buckets only ```ce-dev-springboot-jar-bucket-69127```
    - AllowEC2Access
- Generate standard AWS endpoints inside the VPC for S3

### RDS Database

***

**Step 14: Create the RDS PostgreSQL Instance in Private Subnet**

* Create an RDS PostgreSQL instance in the private subnets
* RDS PostgreSQL with latest stable version
* RDS Primary ```db.r5.large```
* Multi-AZ
* All reads/writes go to primary instance
* RDS encryption at rest with AWS KMS key
* Create an AWS KMS key and policy to encrypt/decrypt the data stored in the Database
* SSL/TLS connection In Transit
* Attach security group to allow PostgreSQL (port 5432) from application tier
* Create an IAM role for enhanced monitoring of the Amazon RDS DB instance (Enhanced monitoring in Amazon RDS)
* Attach a DB subnet group and a parameter group for the Amazon RDS DB instance
* Generate outputs Database endpoint (```db_primary_endpoint```, ```db_proxy_endpoint```, ```db_replica_endpoints```)
  and SSM Port Forwarding Session command
* Use the configuration below:

**RDS Primary Instance (Multi-AZ)**

```
resource "aws_db_instance" "primary" {
  identifier     = "${var.application_name}-${var.environment}-primary"
  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.db.arn

  db_name  = "orderdb"
  username = "app_admin"
  manage_master_user_password = true # Secrets Manager-managed master credential

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:30-sun:05:30"

  deletion_protection      = true
  skip_final_snapshot      = false
  final_snapshot_identifier = "${var.application_name}-${var.environment}-final-snapshot"
  copy_tags_to_snapshot    = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.db.arn
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn

  parameter_group_name = aws_db_parameter_group.postgres16.name

  tags = {
    Name = "${var.application_name}-${var.environment}-primary"
    Tier = "data"
  }
}
```

**Read Replicas**

```
resource "aws_db_instance" "read_replica" {
  count = var.read_replica_count

  identifier          = "${var.application_name}-${var.environment}-replica-${count.index + 1}"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.db_instance_class

  vpc_security_group_ids            = [aws_security_group.db.id]
  performance_insights_enabled      = true
  performance_insights_kms_key_id   = aws_kms_key.db.arn
  monitoring_interval               = 60
  monitoring_role_arn               = aws_iam_role.rds_enhanced_monitoring.arn
  auto_minor_version_upgrade        = true

  tags = {
    Name = "${var.application_name}-${var.environment}-replica-${count.index + 1}"
    Tier = "data-readonly"
  }
}
```

**RDS Proxy**

```
resource "aws_db_proxy" "this" {
  name                   = "${var.application_name}-${var.environment}-proxy"
  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_subnet_ids         = module.vpc.private_data_subnet_ids
  require_tls            = true
  idle_client_timeout    = 1800

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_db_instance.primary.master_user_secret[0].secret_arn
  }
}

resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent      = 90
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

resource "aws_db_proxy_target" "primary" {
  db_proxy_name          = aws_db_proxy.this.name
  target_group_name      = aws_db_proxy_default_target_group.this.name
  db_instance_identifier = aws_db_instance.primary.identifier
}
```

**Step 15: Create Secret Manager for Database RDS password**

- Secrets and DB credentials
- Store DB password in Secrets Manager
- Database credentials rotation (every 30 days)
- Generate random password for database
- Generate the outputs

### IAM Role and policy

***

**Step 16: Create IAM Role for EC2**

* Role for EC2 to access a specific S3 bucket previously, SSM Agent ```AmazonSSMManagedInstanceCore``` and SSM Command ,
  KMS key for database and Log group, read secrets credential in Secrets Manager, RDS full access, CloudWatch to write
  log.
* Create Instance Profile and attach these Permissions
* Attach the IAM Role to the EC2 Instances

### Monitoring

***

**Step 17: Create CloudWatch Log Group for Application Load Balancer access logs**

- **Objective**: Set up comprehensive monitoring for ALB on public facing.
- Publish ALB Logs to CloudWatch, access Logs ```/aws/alb/spring-boot-alb```
- Send structured application logs to CloudWatch
- Encryption CloudWatch logs with KMS key
- Retention: 30 days (compliance), export to S3 for long-term storage
- **CloudWatch alarms for ALB:**
    - TargetResponseTime, HTTPCode_Target_5XX_Count, UnHealthyHostCount, RequestCount CloudWatch metrics
    - Alert on elevated 5xx error count
    - Alert on high target response time
    - High 5XX error rate / 'MetricName': 'HTTPCode_Target_5XX_Count' / 'Alert when 5XX errors exceed threshold'
    - High response time / 'Alert when response time exceeds 1 second'
    - Unhealthy host count / 'MetricName': 'UnHealthyHostCount' / 'Alert when any target becomes unhealthy'
    - Low healthy host count / 'MetricName': 'HealthyHostCount' / 'Alert when healthy hosts drop below 2'
    - High request count (potential DDoS) / 'MetricName': 'RequestCount' / 'Alert on unusually high request rate'
- **Create a CloudWatch dashboard of ALB:**
    - RequestCount
    - TargetResponseTime
    - HealthyHostCount
    - UnHealthyHostCount > 0
    - 5XX error rate > 1%
    - Response time p99 > 3 seconds
    - Target connection errors > 10/minute
    - Rejected connection count > 0
- Create SNS topic for alerts encrypted with KMS
- Email subscription to SNS topic
- Generate the outputs

- **Step 18: Create CloudWatch Log Group for App tier server**

- **Objective**: Set up comprehensive monitoring for EC2 instances App tier server
- Publish EC2 instances App tier logs to CloudWatch
- Encryption CloudWatch logs with KMS key
- Enable detailed monitoring (1-minute intervals)
- Send structured application logs to CloudWatch
- Application tier Logs ```/aws/ec2/spring-boot-backend-app-tier```
- Retention: 30 days (compliance), export to S3 for long-term storage
- This Log Group is for Spring Boot application writen to CloudWatch
- Metric Filters: Extract metrics from log patterns (ERROR, WARN)
    - Metric Filter for ERROR patterns
    - Metric Filter for WARNING patterns
- Provides the Metric below
    - CPU utilization per core
    - Memory usage percentage
    - Disk I/O statistics
    - Network throughput
    - Network connection counts
    - OS processes
    - Health check failures
- **CloudWatch Alarms for EC2 instances App tier server:**
    - Alarms CPU, memory, disk, latency, error rates
    - Latency: P50, P90, P99, P99.9 response times
    - Create CPU utilization high alarm "Alert when CPU exceeds 80% for 5 consecutive minutes"
    - Create disk utilization alarm "Alert when disk usage exceeds 85%"
    - Create a memory high alarm - fires when memory usage exceeds 90%
    - Error Rate: HTTP 4xx, 5xx errors per minute
    - In Application tier Logs ```/aws/ec2/spring-boot-backend-app-tier```
        - Error Count: Triggers when ERROR logs exceed threshold ("This metric monitors application error logs")
        - Warning Count: Monitors WARN level messages ("This metric monitors application warning logs")
    - Composite Alarm: Overall application health status
    - Create status check alarm "Alert when status checks fail"
- **Create a CloudWatch dashboard of EC2 instances App tier:**
    - EC2 CPU Widget
    - EC2 Memory Widget (Memory and Disk Usage)
    - Create a dashboard with 1-minute granularity widgets
    - EC2 instance metrics (CPU, memory, disk, network, NAT Gateway Data Transfer)
    - Application Log Metrics over time (ERROR, WARN)
    - Network Connections
    - Disk I/O
    - Error Rate Widget
    - Recent Error Logs entries
    - Service health status
    - System resource utilization
    - Latency p50/p99 Widget
    - Request Count Widget
    - Request rate, error rate, latency (last 1 hour)
    - Daily spend by EC2, data transfer
    - Month-to-date vs budget
    - Forecast for month-end spending
- Create SNS topic for alerts encrypted with KMS
- Email subscription to SNS topic
- Generate the outputs

**Step 19: RDS Database CloudWatch Log Group**

- **Objective**: Set up comprehensive monitoring for Amazon RDS PostgreSQL.
- Publish RDS PostgreSQL Logs to CloudWatch Logs group
- Encryption CloudWatch logs with KMS key
- Send structured application logs to CloudWatch
- Database Logs ```/aws/rds/postgresql/spring-boot-database-tier```
- Retention: 30 days (compliance), export to S3 for long-term storage
- Create a Metric Filter for RDS: CPU Utilization, connections, ReadIOPS/WriteIOPS latency, replica lag, deadlocks,
  ```DatabaseConnections```, ```ClientConnections```
- Performance Insights, Enhanced Monitoring, CPUUtilization, FreeableMemory, ReadLatency, WriteLatency, DiskQueueDepth,
  ReplicaLag
- **RDS Key Metrics and Alarms**

| Metric                             | Threshold (illustrative) | Severity |
|:-----------------------------------|:-------------------------|:---------|
| RDS `CPUUtilization`               | > 80% for 10 min         | Warning  |
| RDS `FreeableMemory`               | < 10% of total           | Critical |
| RDS `FreeStorageSpace`             | < 15% of allocated       | Warning  |
| RDS `DiskQueueDepth`               | > 20 sustained           | Warning  |
| RDS `ReadLatency` / `WriteLatency` | > 20ms sustained         | Warning  |
| `ReplicaLag`                       | > 5 seconds sustained    | Warning  |
| ALB `HTTPCode_Target_5XX_Count`    | > 1% of requests         | Critical |
| ALB `TargetResponseTime`           | p99 > SLA threshold      | Warning  |
| `DatabaseConnections`              | > 80% of max_connections | Warning  |

- **Configure CloudWatch RDS Alarms from the tab above**
    - Alert when CPU exceeds 90%
    - RDS slow query logs (queries > 1s)
    - Alert when free storage drops below 5 GB
    - Alert when database connections exceed 80% of max
    - Alarm when RDS burst balance drops below 20%
- **Create a CloudWatch dashboard of RDS metrics from the tab above**
    - RDS Connections Widget
    - RDS Latency Widget
    - RDS CPU Utilization
    - Database connections
    - Daily spend RDS, data transfer
    - Month-to-date vs budget
    - Forecast for month-end spending
- Create SNS topic for alerts encrypted with KMS
- Email subscription to SNS topic
- Generate the outputs
