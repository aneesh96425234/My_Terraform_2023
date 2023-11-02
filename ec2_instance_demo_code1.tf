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
  access_key = "AKIAVxxxxxxxxxxWPZU7U"
  secret_key = "48xXrWQpGm2rtxxxxxxxxzTUKf/Tsxxxz5RnxxxxxxxiG"
}

resource "aws_instance" "web" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform_ec2"
  }
}

resource "aws_instance" "app" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform_ec2"
  }
}

resource "aws_instance" "db" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform_ec2"
  }
}