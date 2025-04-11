#############################
# module: ecr_repository
#
# This Terraform module creates an AWS ECR repository with options for:
#  - Enabling image scanning on push.
#  - Configuring encryption with KMS (if enabled).
#  - Adding standard tags for cost and security tracking.
#
# Best practices applied:
#  - Using variables for configuration to allow reusability.
#  - Enforcing encryption. AES256 is used if KMS is not enabled.
#  - Enabling image scanning to add a layer of security.
#  - Using tagging to help with cost allocation and resource management.
#
# Note: This module is built for compatibility with Terraform version 1.9.0 or earlier.
#############################

#############################
##### versions.tf
#############################
terraform {
  required_version = ">= 1.9.0"

  # Provider configuration is assumed to be done at the root module level.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }
}

#############################
##### variables.tf
#############################
# Variable for the repository name.
variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
}

# Variable to enable or disable image scanning on push.
variable "enable_image_scanning" {
  description = "Enable image scanning on push."
  type        = bool
  default     = true
}

# Variable to enable KMS encryption.
variable "enable_kms_encryption" {
  description = "Set to true to enable KMS encryption, false to use AES256 encryption."
  type        = bool
  default     = false
}

# Variable to specify the KMS key ARN if KMS encryption is enabled.
variable "kms_key" {
  description = "KMS Key ARN to use when enable_kms_encryption is true."
  type        = string
  default     = ""
}

# Variables for resource tagging for security, cost optimization, and governance.
variable "company" {
  description = "Company name for tagging."
  type        = string
  default     = "YourCompany"
}

variable "app" {
  description = "Application name for tagging."
  type        = string
  default     = "YourApp"
}

variable "env" {
  description = "Environment (e.g., dev, prod) for tagging."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resource for tagging."
  type        = string
  default     = "owner@example.com"
}

variable "costcenter" {
  description = "Cost center for tagging."
  type        = string
  default     = "CC-0000"
}

#############################
##### locals.tf
#############################
locals {
  # Merge resource tags with any additional custom tags in the future.
  tags = {
    Company   = var.company
    App       = var.app
    Env       = var.env
    Owner     = var.owner
    CostCenter = var.costcenter
  }
  
  # Determine the encryption configuration based on a boolean flag.
  encryption_configuration = var.enable_kms_encryption && var.kms_key != "" ? [{
    encryption_type = "KMS"
    kms_key         = var.kms_key
  }] : [{
    encryption_type = "AES256"
  }]
}

#############################
##### main.tf
#############################
resource "aws_ecr_repository" "this" {
  name = var.repository_name

  # Enable scanning on push if the flag is set.
  image_scanning_configuration {
    scan_on_push = var.enable_image_scanning
  }

  # Apply encryption configuration.
  encryption_configuration {
    encryption_type = local.encryption_configuration[0].encryption_type
    # kms_key is only defined if KMS encryption is enabled.
    kms_key         = local.encryption_configuration[0].encryption_type == "KMS" ? local.encryption_configuration[0].kms_key : null
  }

  # It is a security best practice to apply tags for resource management.
  tags = local.tags

  # Policy for public push access can be defined via a repository policy.
  # This example policy allows all authenticated AWS users to push images.
  # NOTE: Adjust according to your security requirements.
  lifecycle_policy {
    # An example policy for image cleanup or retention can be inserted here.
    # For now, we leave this blank.
  }
}

# Optional: Define a repository policy to allow public push if needed.
# WARNING: Granting public push access can have security implications.
resource "aws_ecr_repository_policy" "this_policy" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version   = "2008-10-17"
    Statement = [
      {
        Sid       = "AllowPushPull"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  })
}

#############################
##### outputs.tf
#############################
# Output the repository URL so that it can be referenced by other modules.
output "repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.this.repository_url
}

# Output the repository ARN.
output "repository_arn" {
  description = "The ARN of the ECR repository."
  value       = aws_ecr_repository.this.arn
}