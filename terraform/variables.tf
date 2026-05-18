variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy resources into"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}

variable "app_name" {
  type        = string
  description = "Application name used for naming resources"
  default     = "python-app"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the custom VPC"
  default     = "10.0.0.0/16"
}

variable "container_image" {
  type        = string
  description = "Fully qualified container image URI to deploy"
  default     = ""
}
