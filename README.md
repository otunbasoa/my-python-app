# Production-Ready Python CI/CD Pipeline on AWS

This project demonstrates an end-to-end DevOps and DevSecOps workflow for a
containerized Python FastAPI application deployed to AWS ECS Fargate through
GitHub Actions, Terraform, Amazon ECR, and GitHub OIDC.

The goal is not just to deploy a web API. The goal is to show how application
code, infrastructure, container security, CI quality gates, and cloud deployment
automation fit together in a production-style delivery pipeline.

## What This Project Shows

- FastAPI application with dedicated health checks
- Dockerized runtime using a non-root container user
- GitHub Actions CI/CD pipeline with OIDC-based AWS authentication
- Terraform-managed AWS infrastructure
- Remote Terraform state using S3 and DynamoDB locking
- Amazon ECR image repository with immutable tags and image scanning
- ECS Fargate service behind an Application Load Balancer
- Private ECS tasks with traffic restricted to the ALB security group
- CI checks for tests, linting, security scanning, container build, Terraform
  formatting, and Terraform validation
- Reproducible deployments using commit SHA image tags instead of mutable
  `latest` deployments

## Architecture

```text
Developer
   |
   | push to main / pull request
   v
GitHub Actions
   |
   | OIDC assume role
   v
AWS
   |
   +--> Terraform remote state
   |      +--> S3 state bucket
   |      +--> DynamoDB lock table
   |
   +--> ECR
   |      +--> immutable container image tags
   |
   +--> VPC
          +--> public subnets
          |      +--> Application Load Balancer
          |
          +--> private subnets
                 +--> ECS Fargate service
                        +--> FastAPI container
```

## Repository Structure

```text
.
├── .github/workflows/cicd.yml      # CI/CD pipeline
├── Dockerfile                      # Production container image
├── main.py                         # FastAPI application
├── test_main.py                    # API tests
├── requirements.txt                # Runtime dependencies
├── requirements-dev.txt            # Test, lint, and security tooling
└── terraform/
    ├── providers.tf                # AWS provider and remote backend config
    ├── vpc.tf                      # VPC, public subnets, private subnets, NAT
    ├── alb.tf                      # Public Application Load Balancer
    ├── ecr.tf                      # ECR repository
    ├── ecs.tf                      # ECS Fargate cluster and service
    ├── outputs.tf                  # Useful deployment outputs
    └── bootstrap/                  # One-time backend bootstrap stack
```

## CI/CD Workflow

The GitHub Actions pipeline is defined in `.github/workflows/cicd.yml`.

On pull requests, the pipeline runs quality checks:

- Install pinned development dependencies
- Run Python linting with Ruff
- Run security scanning with Bandit
- Run automated tests with Pytest
- Build the Docker image

On pushes to `main`, the pipeline additionally deploys:

- Authenticates to AWS using GitHub OIDC
- Initializes and validates Terraform
- Ensures the ECR repository exists
- Builds and pushes a SHA-tagged Docker image
- Applies Terraform using the exact image pushed for that commit

This avoids long-lived AWS access keys in GitHub and makes deployments traceable
to a specific Git commit.

## Security and Production Practices

This project includes several production-oriented controls:

- **No static AWS credentials in CI:** GitHub Actions authenticates through OIDC.
- **Remote Terraform state:** State is stored in S3 with DynamoDB locking.
- **Immutable image tags:** ECS deploys images tagged with the Git commit SHA.
- **Container hardening:** The image runs as a non-root Linux user.
- **Restricted ECS ingress:** ECS tasks only accept traffic from the ALB security
  group.
- **Private workloads:** ECS tasks run in private subnets.
- **Health checks:** ALB and ECS use `/health` to detect unhealthy containers.
- **Dependency separation:** Runtime and development dependencies are separated.
- **Security scanning:** Bandit checks Python code during CI.
- **ECR scanning:** Container images are scanned on push.

## Application Endpoints

```text
GET /          # Basic API response
GET /health    # Health check endpoint
GET /items/42  # Example path parameter endpoint
```

## Local Development

Install dependencies:

```bash
python3 -m pip install -r requirements-dev.txt
```

Run tests:

```bash
python3 -m pytest
```

Run linting:

```bash
python3 -m ruff check .
```

Run security checks:

```bash
python3 -m bandit -r main.py
```

Run the API locally:

```bash
python3 -m uvicorn main:app --reload
```

Then open:

```text
http://127.0.0.1:8000
```

## Terraform Backend Bootstrap

The main Terraform stack uses an S3 backend with DynamoDB locking. Because a
Terraform backend must exist before Terraform can use it, the backend resources
are managed by a separate bootstrap stack.

Run this once:

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Then initialize or migrate the main stack:

```bash
cd ..
terraform init -migrate-state
```

After this one-time setup, the GitHub Actions workflow can use the remote state
backend automatically.

## Deployment Prerequisites

Before pushing to `main`, make sure the following are configured:

- AWS account with permissions for ECS, ECR, VPC, ALB, IAM, S3, and DynamoDB
- GitHub OIDC identity provider configured in AWS IAM
- IAM role trusted by GitHub Actions
- GitHub repository secret named `AWS_ROLE_ARN`
- Terraform backend bootstrapped with `terraform/bootstrap`
- Docker available in the GitHub Actions runner, which is provided by
  `ubuntu-latest`

## Deployment Flow

After the backend and OIDC role are ready, deployment is automatic:

```bash
git push origin main
```

The workflow will test, scan, build, push, and deploy the application to ECS.

## Production Improvements I Would Add Next

This project is intentionally focused and portfolio-sized. In a real production
environment, I would extend it with:

- HTTPS listener using AWS ACM
- HTTP-to-HTTPS redirect on the ALB
- Route 53 DNS record for a custom domain
- GitHub environment approval rules for production
- Centralized application logs and alarms
- Terraform plan review on pull requests
- Container vulnerability scanning with severity gates
- Autoscaling policies for ECS
- WAF in front of the ALB
- Secrets management through AWS Secrets Manager or SSM Parameter Store

## Why This Project Matters

This project demonstrates more than basic CI/CD. It shows the ability to think
across the full delivery path:

- writing a small but testable application,
- packaging it safely,
- validating it before deployment,
- provisioning cloud infrastructure as code,
- avoiding long-lived credentials,
- deploying immutable artifacts,
- and separating bootstrap infrastructure from application infrastructure.

That combination is what makes software delivery reliable, repeatable, and
ready for real-world engineering teams.
