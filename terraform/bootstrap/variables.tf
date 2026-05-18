variable "aws_region" {
  type        = string
  description = "AWS Region where the Terraform backend resources are created"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state"
  default     = "python-app-production-terraform-state"
}

variable "app_name" {
  type        = string
  description = "Application name used for foundational resources"
  default     = "python-app"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}
