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
  access_key = "AKIXXXXXXXXXXXXXXXXXXXU"
  secret_key = "48xXrXXXXXXXXXXXXXzTUKf/TsXXXXXXXRBXXG"
}

resource "aws_vpc" "devopslab-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "devopslab_vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.devopslab-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.devopslab-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_security_group" "devopslab-sg" {
  name        = "devopslab-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.devopslab-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  tags = {
    Name = "devopslab-sg"
  }
}

resource "aws_internet_gateway" "devopslab-igw" {
  vpc_id = aws_vpc.devopslab-vpc.id

  tags = {
    Name = "devopslab-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.devopslab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devopslab-igw.id
  } 

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_key_pair" "devopslab-key" {
  key_name   = "devopslab-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpVv0Bq0MCRgU4fSfR+HSfZ3DaWnCmJiCMALlZIbisJPZS5MSkzUtEGeOC4i+XvK+RX9kWhrsCC63C6p5dwi9KC5fCTyDy8TLwmdkLK8/8f4Svmu1AxKt4xn0TYmAoRC3rsxTBNje+5zXVM0sfBn34MtZ+DrD4MDwgM1ZxvVWxPUvUyoPAdnTmJJ4YK7sc4kdhY6o62N5UrfbrnepnRNvj9UyB79K/FeTdeCzsJOX0kO/hgy3wfjRlVZ5YdacnGzSlWJvtkZSpqrYDH85bJaDxA0tzETq8s3Lp6NTjL623pXn0VZyA5tYAHDea+AcNmfZKl4jZUjo8hUSvvsBztACn rsa-key-20231102
"
}

resource "aws_instance" "devopslab-app1" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  subnet_id 	= aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.devopslab-sg.id]
  key_name		= "devopslab-key"
  
  tags = {
    Name = "devopslab-app1"
  }
}

resource "aws_eip" "devopslab-eip" {
  instance = aws_instance.devopslab-app1.id
  domain   = "vpc"
}

resource "aws_instance" "devopslab-db1" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  subnet_id 	= aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.devopslab-sg.id]
  key_name		= "devopslab-key"
  
  tags = {
    Name = "devopslab-db1"
  }
}

resource "aws_nat_gateway" "devopslab-nat" {
  allocation_id = aws_eip.devopslab-natip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "devopslab-nat"
  }
}

resource "aws_eip" "devopslab-natip" {
  domain   = "vpc"
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.devopslab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_nat_gateway.devopslab-nat.id"
  } 

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
