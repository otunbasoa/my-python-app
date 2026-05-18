module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name = "${var.app_name}-repo"

  repository_image_tag_mutability = "IMMUTABLE"
  repository_force_delete         = var.ecr_repository_force_delete
  repository_image_scan_on_push   = true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
