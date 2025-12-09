terraform {
    required_version = "~>1.14.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>6.24"
        }
    }
    backend "s3" {
        bucket         = "vertice-exercise"
        key            = "terraform-exercise/terraform.tfstate"
        region         = "eu-west-1"
        encrypt        = true
    }
}
