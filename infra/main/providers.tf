provider "aws" {
  region  = "ap-south-1"
  profile = "retailpulse"

  default_tags {
    tags = {
      project    = "retailpulse"
      env        = "dev"
      managed_by = "terraform"
      owner      = "himanshu"
    }
  }
}
