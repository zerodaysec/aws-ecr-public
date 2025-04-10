# ECR Repository Terraform Module

This Terraform module creates an AWS Elastic Container Registry (ECR) repository with configurable options for image scanning, encryption, and tagging. It is designed to follow best practices for security, resource management, and cost allocation.

## Overview

The module provisions an ECR repository in AWS with the following capabilities:

- Enabling image scanning on push for added security.
- Configuring encryption with either KMS (if enabled) or defaulting to AES256.
- Applying standard tags to facilitate cost tracking, security, and governance.
- Optionally setting up a repository policy to allow public push access (adjustable per security requirements).

This module is built for compatibility with Terraform version 1.9.0 or later and assumes that the AWS provider configuration is managed at the root module level.

## Features

- **Image Scanning on Push**  
  Automatically enables scanning on image push to detect vulnerabilities early.

- **Configurable Encryption**  
  Choose between KMS encryption (with a provided key) or rely on AES256 encryption as a secure default.

- **Comprehensive Tagging**  
  Tags are applied to the repository for better resource tracking and operational governance. Tags include Company, App, Environment, Owner, and CostCenter.

- **Repository Policy for Push Access**  
  The module includes an example repository policy, which allows all authenticated AWS users to push images. Adjust this policy according to your security needs.

## Variables

| Variable                  | Description                                                                                           | Type    | Default          |
|---------------------------|-------------------------------------------------------------------------------------------------------|---------|------------------|
| `repository_name`         | Name of the ECR repository.                                                                           | string  | _None (required)_|
| `enable_image_scanning`   | Enable image scanning on push.                                                                        | bool    | true             |
| `enable_kms_encryption`   | Set to true to enable KMS encryption; false to use AES256 encryption.                                  | bool    | false            |
| `kms_key`                 | KMS Key ARN to use when enabling KMS encryption.                                                      | string  | ""               |
| `company`                 | Company name for tagging.                                                                             | string  | "YourCompany"    |
| `app`                     | Application name for tagging.                                                                         | string  | "YourApp"        |
| `env`                     | Environment (e.g., dev, prod) for tagging.                                                            | string  | "dev"            |
| `owner`                   | Owner of the resource for tagging.                                                                    | string  | "<owner@example.com>" |
| `costcenter`              | Cost center for tagging.                                                                              | string  | "CC-0000"        |

## Usage

Below is an example of how to use the module in your Terraform configuration:

hcl
module "ecr_repository" {
  source = "./modules/ecr_repository"

  repository_name         = "my-ecr-repo"
  enable_image_scanning   = true
  enable_kms_encryption   = false
  kms_key                 = ""                # Provide KMS key ARN if enable_kms_encryption is true

  company                 = "AcmeCorp"
  app                     = "MyApplication"
  env                     = "prod"
  owner                   = "<admin@acmecorp.com>"
  costcenter              = "CC-1234"
}

After applying, you can reference the output values from this module:

- `repository_url` – The URL of the ECR repository.
- `repository_arn` – The ARN of the ECR repository.

Example:
hcl
output "ecr_repo_url" {
  value = module.ecr_repository.repository_url
}

output "ecr_repo_arn" {
  value = module.ecr_repository.repository_arn
}

## Notes

- **Terraform Version:** Ensure you are using Terraform version 1.9.0 or later.
- **AWS Provider Configuration:** The AWS provider should be configured at the root module level.
- **Repository Policy:** The module includes an optional repository policy that grants public push access. Adjust or remove this policy based on your organization's security guidelines.

This module is designed to bring a level of standardization and best practices to managing ECR repositories within your organization. Customize as necessary to best fit your specific requirements.
