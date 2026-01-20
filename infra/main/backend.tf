terraform {
  backend "s3" {
    bucket         = "retailpulse-tfstate-206470327951"
    key            = "retailpulse/main/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "retailpulse-tflock"
    encrypt        = true
    profile        = "retailpulse"
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
