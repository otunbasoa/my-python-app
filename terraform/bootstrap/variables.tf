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

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"
  default     = "python-app-production-terraform-locks"
}
