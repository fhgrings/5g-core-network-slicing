provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Project   = "Terraform setup"
      CreatedAt = "2021-12-06"
      ManagedBy = "Terraform"
      Owner     = "Felipe Grings"
    }
  }
}