# Define variables
variable "aws_region" {
  description = "The AWS region where resources will be created."
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "web_sg_ingress_rules" {
  description = "Ingress rules for the web security group"
  type        = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    # Add more rules as needed
  }
}

variable "web_sg_egress_rules" {
  description = "Egress rules for the web security group"
  type        = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Add more rules as needed
  ]
}

variable "app_instance_ami" {
  description = "AMI for the app instance"
  default     = "ami-xxxxxxxxxxxxxx"
}

variable "app_instance_type" {
  description = "Instance type for the app instance"
  default     = "t2.micro"
}

variable "app_instance_subnet_id" {
  description = "Subnet ID for the app instance"
  default     = "subnet-xxxxxxxxxxxxxx"
}

variable "app_instance_security_group_ids" {
  description = "Security group IDs for the app instance"
  type        = list(string)
  default     = ["sg-xxxxxxxxxxxxxx"]
}

variable "app_instance_key_name" {
  description = "Key name for the app instance"
  default     = "your-key-pair"
}

variable "db_instance_ami" {
  description = "AMI for the DB instance"
  default     = "ami-xxxxxxxxxxxxxx"
}

variable "db_instance_type" {
  description = "Instance type for the DB instance"
  default     = "t2.micro"
}

variable "db_instance_subnet_id" {
  description = "Subnet ID for the DB instance"
  default     = "subnet-xxxxxxxxxxxxxx"
}

variable "db_instance_security_group_ids" {
  description = "Security group IDs for the DB instance"
  type        = list(string)
  default     = ["sg-xxxxxxxxxxxxxx"]
}

variable "db_instance_key_name" {
  description = "Key name for the DB instance"
  default     = "your-key-pair"
}

variable "db_nat_gateway_eip" {
  description = "EIP ID for the NAT Gateway"
  default     = "eip-xxxxxxxxxxxxxx"
}

variable "db_subnet_route_table_cidr" {
  description = "CIDR block for the DB subnet route table"
  default     = "0.0.0.0/0"
}

variable "private_subnet_route_table_association" {
  description = "ID of the private subnet route table association"
  default     = "rtbassoc-xxxxxxxxxxxxxx"
}

# Create the VPC, subnets, and internet gateway
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count = 1
  cidr_block = var.public_subnet_cidr_block
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 1
  cidr_block = var.private_subnet_cidr_block
  availability_zone = "us-east-1b"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"
  description = "Web Security Group"

  dynamic "ingress" {
    for_each = var.web_sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.web_sg_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyIGW"
  }
}

# Create route tables and associate them
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw.id
}

resource "aws_subnet_route_table_association" "private_subnet_association" {
  count = 1
  subnet_id = element(aws_subnet.private_subnet[*].id, 0)
  route_table_id = aws_route_table.private_route_table.id
}

# Create the app and DB instances
resource "aws_instance" "app_instance" {
  ami           = var.app_instance_ami
  instance_type = var.app_instance_type
  subnet_id     = var.app_instance_subnet_id
  security_groups = var.app_instance_security_group_ids
  key_name     = var.app_instance_key_name
  tags = {
    Name = "App Instance"
  }
}

resource "aws_instance" "db_instance" {
  ami           = var.db_instance_ami
  instance_type = var.db_instance_type
  subnet_id     = var.db_instance_subnet_id
  security_groups = var.db_instance_security_group_ids
  key_name     = var.db_instance_key_name
  tags = {
    Name = "DB Instance"
  }
}

# Create a single EIP associated with the app instance
resource "aws_eip" "app_instance_eip" {
  instance = aws_instance.app_instance.id
}

# Create a NAT Gateway and route for the DB
resource "aws_nat_gateway" "db_nat_gateway" {
  allocation_id = var.db_nat_gateway_eip
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
  tags = {
    Name = "DB NAT Gateway"
  }
}

resource "aws_route" "db_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = var.db_subnet_route_table_cidr
  nat_gateway_id = aws_nat_gateway.db_nat_gateway.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = element(aws_subnet.private_subnet[*].id, 0)
  route_table_id = aws_route_table.private_route_table.id
}
