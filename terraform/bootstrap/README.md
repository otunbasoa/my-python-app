# Terraform Backend Bootstrap

This stack creates foundational resources required before the application
pipeline can run:

- S3 bucket for Terraform remote state
- ECR repository for application container images

State locking is handled by Terraform's S3 native lockfile support.

Run this stack once before running `terraform init` in the parent `terraform`
directory:

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Then migrate the main application state:

```bash
cd ..
terraform init -migrate-state
```

Keep this bootstrap stack separate from the application stack. Terraform cannot
create its own backend before the backend is initialized.
