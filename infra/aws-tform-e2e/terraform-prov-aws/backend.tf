terraform {
    backend "s3" {
        region = "us-east-1"
        bucket = "aws-tform-e2e-tfstate"
        encrypt = "true"
        key = "terraform.tfstate"
    }
}

