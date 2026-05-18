terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "python-app-production-terraform-state"
    key            = "ci-pipelines/my-python-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "python-app-production-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
