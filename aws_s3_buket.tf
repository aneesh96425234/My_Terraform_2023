terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAxxxxxxxxxxxxXW92"
  secret_key = "fPCD+rjIF+ddddddddddddddddzzzzzzzzz7Q5a"
}

resource "aws_s3_bucket" "devopslab-s3-bucket" {
  bucket = "devopslab-s3-bucket"  
  acl    = "private"  

  tags = {
    Name = "devopslab-s3-bucket"
  }
}