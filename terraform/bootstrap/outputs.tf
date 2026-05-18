output "state_bucket_name" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL used by the application deployment pipeline"
  value       = aws_ecr_repository.app.repository_url
}
