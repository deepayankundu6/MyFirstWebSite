provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {}
  required_version = ">=1.7"
}
