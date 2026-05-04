terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ----------------------------------------------------
# Fetch AWS Account ID
# ----------------------------------------------------
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# ----------------------------------------------------
# S3 Bucket for Terraform State
# ----------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.account_id}-terraform-states"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "shared"
  }
}
output "S3BucketName" {
    value = aws_s3_bucket.terraform_state.bucket
  
}

# ----------------------------------------------------
# Enable Versioning (REQUIRED)
# ----------------------------------------------------
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ----------------------------------------------------
# Enable Server-Side Encryption
# ----------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ----------------------------------------------------
# Block All Public Access (CRITICAL)
# ----------------------------------------------------
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}