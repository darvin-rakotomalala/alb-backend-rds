#!/bin/bash
############################################
# Base packages: curl, AWS CLI, Java 17, psql client
############################################
apt-get update -y
apt-get install -y curl unzip jq gnupg lsb-release openjdk-17-jdk

# AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws

# Add the official PostgreSQL (PGDG) apt repo so we can install psql 16
# to match the RDS server major version (avoids the v14 client / v16 server mismatch)
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  | tee /etc/apt/sources.list.d/pgdg.list
apt-get update -y
apt-get install -y postgresql-client-16

############################################
# SSM Agent (preinstalled via snap on Ubuntu 22.04 - ensure it is enabled)
############################################
snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || systemctl enable amazon-ssm-agent || true
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || systemctl start amazon-ssm-agent || true
