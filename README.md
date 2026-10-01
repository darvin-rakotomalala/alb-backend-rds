## Deploying a Two-Tier Multi-AZ Architecture — EC2 + RDS PostgreSQL (Terraform)

### The Business Problem

***

Modern enterprise applications require high availability, fault tolerance, data security, and seamless scalability
across multiple failure domains without exposing internal compute and database layers to the public internet.

### The Challenge

***

* **High Availability & Fault Tolerance**: Mitigate single-point-of-failure risks by spanning the application and
  database tiers across 3 Availability Zones (`us-east-1a`, `us-east-1b`, `us-east-1c`).
* **Zero Public Exposure**: Ensure EC2 app servers and RDS database instances remain in isolated private subnets with no
  public IPs, no SSH ingress, and no bastion host.
* **Secure Access & Administration**: Utilize AWS Systems Manager (SSM) and VPC Interface/Gateway Endpoints for safe
  remote management and internal service communication.
* **Data Security & Encryption**: Enforce TLS 1.2+ in transit and customer-managed KMS encryption at rest across RDS,
  Secrets Manager, S3, and CloudWatch.
* **Observability**: Establish end-to-end monitoring using CloudWatch metric filters, alarms, dashboards, and
  KMS-encrypted SNS topics.

### Architecture Overview

![alb-backend-rds.png](alb-backend-rds.png)

#### Core Components

* **Networking**: VPC with 3 Availability Zones (`us-east-1a`, `us-east-1b`, `us-east-1c`), featuring dedicated Public,
  Private Application, and Isolated Database Subnets.
* **ALB (Public Facing)**: Multi-AZ Application Load Balancer in public subnets distributing incoming traffic over HTTP
  (80) and HTTPS (443).
* **Application Tier**: EC2 instances (`t3.large`, Ubuntu LTS) running Spring Boot in private subnets across 3 AZs.
  Access is strictly managed via **AWS Systems Manager (SSM)** — no public IPs, no bastion hosts, and no SSH ports open.
* **Database Tier**: Amazon RDS PostgreSQL (Multi-AZ Primary + Read Replicas + RDS Proxy) hosted in isolated database
  subnets with zero internet connectivity.
* **IAM Role & Instance Profile**: Granted least-privilege policies for S3, SSM, RDS, KMS, Secrets Manager, and
  CloudWatch access.
* **AWS KMS**: Customer-managed KMS key encrypting RDS storage, Secrets Manager credentials, and CloudWatch log groups.
* **AWS Secrets Manager**: Manages database credentials with automatic 30-day credential rotation.
* **Amazon S3**: Stores application JAR artifacts (`ce-dev-springboot-jar-bucket-69127`) and ALB access logs.
* **Route 53 & ACM**: Custom domain routing (`cloudwithdarvin.com` and `api.cloudwithdarvin.com`) with SSL/TLS
  certificate termination (TLS 1.2/1.3) at the ALB.
* **VPC Endpoints**: Interface endpoints for SSM, SSM Messages, EC2 Messages, and Secrets Manager; Gateway endpoint for
  Amazon S3.
* **CloudWatch & SNS**: Centralized logging, metric filters (ERROR, WARN), alarm alerts, and real-time dashboards
  integrated with KMS-encrypted SNS email notifications.

#### Traffic Flow

1. **User Request** → Route 53 DNS → Application Load Balancer (HTTPS / TLS 1.2 & 1.3).
2. **ALB** → EC2 App Tier Instances (via target group in private subnets).
3. **App Tier Instances** → RDS PostgreSQL / RDS Proxy (Private IP, Port 5432, TLS 1.2+).
4. **Response** → ALB → User.
5. **Logs & Audit** → CloudWatch Log Groups & CloudTrail.

### Implementation Specifications

***

#### 1. Network & CIDR Layout (VPC: `18.0.0.0/16`)

| Subnet Tier                    | Availability Zone                            | CIDR Block                                         | Internet Access                     |
|:-------------------------------|:---------------------------------------------|:---------------------------------------------------|:------------------------------------|
| **Public Subnets** (ALB & NAT) | `us-east-1a`<br>`us-east-1b`<br>`us-east-1c` | `18.0.1.0/24`<br>`18.0.2.0/24`<br>`18.0.3.0/24`    | Internet Gateway                    |
| **Private App Subnets** (EC2)  | `us-east-1a`<br>`us-east-1b`<br>`us-east-1c` | `18.0.11.0/24`<br>`18.0.12.0/24`<br>`18.0.13.0/24` | Outbound via NAT Gateway (1 per AZ) |
| **Private Data Subnets** (RDS) | `us-east-1a`<br>`us-east-1b`<br>`us-east-1c` | `18.0.21.0/24`<br>`18.0.22.0/24`<br>`18.0.33.0/24` | None (Isolated)                     |

#### 2. Security Groups & Network Isolation

* **`ALB-SG`**: Inbound HTTP (80) & HTTPS (443) from `0.0.0.0/0`; redirect HTTP to HTTPS.
* **`EC2-APP-SG`**: Inbound HTTP/HTTPS from `ALB-SG` only. Outbound access to RDS (`RDS-SG`) and NAT Gateways.
* **`RDS-SG`**: Inbound PostgreSQL (5432) from `EC2-APP-SG` only.
* **`SSM-SG`**: Inbound HTTPS (443) from VPC CIDR (`18.0.0.0/16`) for SSM and Secrets Manager Interface Endpoints.

#### 3. Database Architecture (RDS PostgreSQL)

* **Engine / Hardware**: PostgreSQL 16 on `db.r5.large` with `gp3` storage and storage auto-scaling.
* **High Availability**: Multi-AZ primary instance with automated failover + Read Replicas across AZs.
* **Connection Pooling**: Managed via **RDS Proxy** (`require_tls = true`, IAM authentication required).
* **Security & Auth**: Encryption at rest via KMS; dynamic credentials managed by Secrets Manager with 30-day rotation.

### Prerequisites

Before starting, ensure you have:

* Terraform >= 1.14
* AWS CLI v2 configured with valid credentials
* Java Development Kit (JDK 17+) and Maven 3.6+
* AWS Session Manager Plugin installed locally
* Git installed
* Active domain hosted on Route 53 (`cloudwithdarvin.com`)

### Implementation & Deployment

***

#### Step 1 — Infrastructure Provisioning with Terraform

Execute the following commands from the root terraform directory:

```bash
$ cd alb-backend-rds/terraform
$ terraform init
$ terraform fmt -recursive
$ terraform validate
$ terraform plan -var-file="terraform.tfvars" -no-color -out=TFplan.JSON
$ terraform apply -var-file="terraform.tfvars" -auto-approve
$ terraform destroy -var-file="terraform.tfvars" -auto-approve
```

![1-Outputs.png](Screenshot%20verification/1-Outputs.png)

#### Step 2 — Deployment Workflow

- ```checkov.yml``` — Automated security scanning framework using Checkov to detect Terraform misconfigurations at both
  repository and pull request (PR) levels
- ```deploy_infra.yml``` — Terraform workflow to provision infrastructure
- ```deploy_app.yml``` — Terraform workflow to deploy JAR Java Spring Boot application from S3 to EC2

### Verification & API Testing

***

You can check the full documentation for **technical specifications** in ```Documentation``` directory and all
screenshot in ```Screenshot verification```.

- **EC2 instance created**

![2-EC2 Instances.png](Screenshot%20verification/2-EC2%20Instances.png)

- **ALB created**

![3-ALB.png](Screenshot%20verification/3-ALB.png)

![4-TG 1.png](Screenshot%20verification/4-TG%201.png)

- **RDS created**

![5-RDS.png](Screenshot%20verification/5-RDS.png)

- **Route 53 created**

![6-Route 53.png](Screenshot%20verification/6-Route%2053.png)

- **Test our Application using Postman with Route 53 DNS**

    * Health Check: `GET https://api.cloudwithdarvin.com/health`
    * Create Note: `POST https://api.cloudwithdarvin.com/notes`
    * Create multi Note: `POST https://api.cloudwithdarvin.com/notes/save-all`
    * Get All Note and/or filter by title: `GET https://api.cloudwithdarvin.com/notes`
    * Get Note by ID: `GET https://api.cloudwithdarvin.com/notes/{id}`
    * Update Note: `PUT https://api.cloudwithdarvin.com/notes`
    * Delete Note: `DELETE https://api.cloudwithdarvin.com/notes/{id}`

### Summary

***

We have successfully:

* Created a complete Spring Boot CRUD application with REST endpoints.
* Externalized database properties and built the application into a deployable JAR artifact.
* Provisioned multi-AZ AWS infrastructure using Terraform IaC:
    * **Networking**: Custom VPC (`18.0.0.0/16`) spanning 3 Availability Zones (`us-east-1a`, `us-east-1b`,
      `us-east-1c`) with public, private application, and isolated database subnets.
    * **High Availability Compute & Routing**: Multi-AZ Application Load Balancer in public subnets with HTTP to HTTPS
      redirection and Spring Boot EC2 app instances deployed across private subnets.
    * **Multi-AZ Database Architecture**: RDS PostgreSQL primary instance with Multi-AZ automated failover, read
      replicas, and RDS Proxy with connection pooling.
    * **Secure Access**: Zero public exposure on compute/data tiers (no SSH inbound, no bastion, no public IPs).
      Administrative access is strictly routed through AWS Systems Manager (SSM).
    * **VPC Endpoints**: Interface endpoints for SSM, SSM Messages, EC2 Messages, and Secrets Manager, alongside an S3
      Gateway Endpoint restricted to specific buckets.
    * **Data Protection & Encryption**: Customer-managed KMS encryption at rest for RDS, Secrets Manager, S3, and
      CloudWatch, combined with automated 30-day credential rotation.
    * **Observability & Monitoring**: Dedicated CloudWatch log groups (`/aws/alb/spring-boot-alb`,
      `/aws/ec2/spring-boot-backend-app-tier`, `/aws/rds/postgresql/spring-boot-database-tier`), metric filters for
      `ERROR`/`WARN` patterns, real-time CloudWatch dashboards, and KMS-encrypted SNS topics for automated email
      alerting.
    * **Security & Network Boundaries**: Least-privilege IAM instance profiles, custom security groups avoiding inline
      rule circular dependencies, and multi-tier NACLs.
    * **CI/CD Pipelines**: Automated GitHub Actions workflows for Checkov security scans (`checkov.yml`), Terraform
      infrastructure deployment (`deploy_infra.yml`), and Spring Boot application deployment (`deploy_app.yml`).
* Deployed the Spring Boot application JAR from S3 to EC2 instances across private subnets.
* Verified all REST API endpoints using Postman via Route 53 domain mapping (`api.cloudwithdarvin.com`).

**Next Steps for Production**

1. **Auto Scaling**: Configure Auto Scaling Groups (ASG) across the 3 private AZs for automatic capacity scaling based
   on traffic load.
2. **Authentication & Authorization**: Secure application REST endpoints using OAuth2 or JWT access tokens.
3. **API Protection**: Implement AWS WAF on the Application Load Balancer and enforce rate limiting to prevent DDoS or
   brute-force attacks.
4. **Database Query Optimization**: Review query execution plans, optimize indexing, and configure database connection
   parameters.

**Key Takeaways**

* **Zero-Bastion Security**: Managing private instances via SSM removes SSH exposure entirely while maintaining full
  control.
* **Multi-AZ Fault Tolerance**: Spanning networking, compute, and database components across 3 AZs eliminates single
  points of failure.
* **Centralized Observability**: Combining log groups, metric filters, dashboards, and SNS alarms ensures immediate
  visibility into application and infrastructure health.
* **End-to-End Encryption**: Enforcing TLS in transit and customer-managed KMS encryption at rest guarantees data
  protection across all architectural layers.
