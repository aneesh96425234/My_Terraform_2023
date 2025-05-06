# Terraform script to create VPC, Subnets, IGW, Route Tables, NACLs, Security Groups, ALB, and EC2 instances
#  Change the access_key, secret_key, Instance SSH public_key and Instance userdata.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAXXXXXXXXXXXXFJZGWN"
  secret_key = "F8EVXXXXXXXXXXXXXXXXXXXXXXXXXXXXzXIibverdXDv"
}

resource "aws_vpc" "test_lb_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Test-LB-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_lb_vpc.id

  tags = {
    Name = "Test_LB-IGW"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.test_lb_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Test-LB-Subnet-A"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.test_lb_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Test-LB-Subnet-B"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.test_lb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Test-LB-RT"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_network_acl" "test_lb_nacl" {
  vpc_id = aws_vpc.test_lb_vpc.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Test-LB-NACL"
  }
}

resource "aws_network_acl_association" "assoc_a" {
  subnet_id      = aws_subnet.subnet_a.id
  network_acl_id = aws_network_acl.test_lb_nacl.id
}

resource "aws_network_acl_association" "assoc_b" {
  subnet_id      = aws_subnet.subnet_b.id
  network_acl_id = aws_network_acl.test_lb_nacl.id
}

resource "aws_security_group" "test_lb_sg_a" {
  name        = "Test-LB-SG-A"
  description = "Allow HTTP and all traffic"
  vpc_id      = aws_vpc.test_lb_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "test_lb_sg_b" {
  name        = "Test-LB-SG-B"
  description = "Allow HTTP and all traffic"
  vpc_id      = aws_vpc.test_lb_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "test-lb-key-may-2025"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsq83A6poCb2ka4OWavdXXXXXXXXXXXXXXXXXXXXXXXXXXXlkzkbQI9b7ZRb20UM6caymD48FwxNbguIJ/EMNVwb4vmZMpO84Qh6qum3vn9imWm1ynsSCxxxxxxxxxxxxxxxxxxxgZe87hZFYYKrquUDqbSQBE/mqiClKngJK74xc2kzM7/zVv2HamFT5LvqWxYf0vkQ8X6RMZ+RnPuy3edeu9mrgNr/RdpkkGjO6RbXCDclRmC38oXcNGA6xkEsa2u6GGHD2lY57wzf3fuJjHygpVxsopRjU1ybGrefX17GpaMm9ECTL rsa-key-20250505"
}

resource "aws_instance" "web_a" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet_a.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.test_lb_sg_a.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = file("userdata.sh")

  tags = {
    Name = "Ubuntu-VM-A"
  }
}

resource "aws_instance" "web_b" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet_b.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.test_lb_sg_b.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = file("userdata.sh")

  tags = {
    Name = "Ubuntu-VM-B"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "test-alb-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.test_lb_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_lb" {
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  tags = {
    Name = "Test-ALB"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "Test-LB-Tgt"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_lb_vpc.id

  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

resource "aws_lb_target_group_attachment" "vm_a" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "vm_b" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_b.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
