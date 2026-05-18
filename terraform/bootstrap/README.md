# Terraform Backend Bootstrap

This stack creates the S3 bucket and DynamoDB table used by the main Terraform
configuration for remote state and state locking.

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
