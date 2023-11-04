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
  access_key = "AKIAHHHHHHHHHHHHHHHLLLLLLLXW62"
  secret_key = "fPCD+rjIF+pOOOOOOOOOOOOOOOOOO+AvGn2c6LLLLLLLLLL5a"
}

resource "aws_key_pair" "devopslab_key_dec_2023"  {
  key_name    = "devopslab_key_dec_2023"
  public_key  =  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2h7fUERaVkWOJBVohCApsHx87KQFiyeY+kfpDPL25yYRu/3RpJ2kw1DdFe1wUNfxLohVGxnMch9shVGgRr8GmYZrgPsd+v+VNSbVoYxi6sRP6pFKNqgl7OWTYcV78/7yW0xf/Rlf2xRqIAicY3MZEQD3Jyl37SyVmXDIdXvS1GFNPRphnGOJSc/kKt3NGwTKmJusmzyyDsF79DRvOTktc0oL2TarWaWHo2fO4tUIuLM5LyGzsojs4Xuie84wH6Fn1ayKs/xlGHpKzpKuNZ/yQdeS2wdIe6kwp1SzSFdRJBvIhkG7Slt9e1uLhPLv58GwePI65DEPJZPK/2wX3+EKxhpSzS38u15r0P1VbqZa/Eq3M4wKeA8MK/Q7HCBbbjzqrxkNo6pxb2P8lnjCyvBQklik1SaVkf9PvAzL78uadyxxLk/uRuUhu/YKkRb1nlN5ZkLSGHDt5hCQxZSil7nrWCZXtOmbwJKZoA7EBXbJrGbJFs= aneesh@rocky9"
}

resource "aws_instance" "App1" {
  ami           = "ami-05c13eab67c5d8861"
  instance_type = "t2.micro"
  key_name  = "devopslab_key_dec_2023"

  tags = {
    Name = "prod"
}
provisioner "file"  {
    source      = "/Terraform_Multtipple_Project_TV_PC_Dec_2023/Terraform_Project_1/html_template/index.html"
    destination = "/tmp/index.html" 
}

provisioner "remote-exec"  {
  inline = [
    "sudo yum install httpd -y",
	"sudo systemctl reload httpd",
	"sudo systemctl start httpd",
	"sudo systemctl enable httpd",
	"sudo cp /tmp/index.html /var/www/html",
	"sudo systemctl restart httpd"
  ]
}

connection  {
  host  = self.public_ip
  user  = "ec2-user"
  type  = "ssh"
  private_key = "Terraform_Multtipple_Project_TV_PC_Dec_2023/Terraform_Project_1/ssh_key/devopslab_key_dec_2023"
  timeout     = "300s"
}
}
