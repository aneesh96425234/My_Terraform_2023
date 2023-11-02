terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.20.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAxxxxxxxxxxxxxx"
  secret_key = "48xXrWQpGm2rtxxxxxxxxxxKf/TsWOxxxxxxxxxBiG"
}

resource "aws_instance" "web" {
  ami           = ami-053b0d53c279acc90
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform_ec2"
  }
}