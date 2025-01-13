terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "rajakey.pem"
}

resource "aws_key_pair" "rajakey" {
  key_name   = "rajakey-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_security_group" "my-security-group" {
  name = "my-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-instance" {
  ami               = "ami-0c7217cdde317cfec"
  instance_type     = "t2.micro"
  security_groups   = [aws_security_group.my-security-group.name]
  key_name          = aws_key_pair.rajakey.key_name

  tags = {
    Name = "public_instance"
  }

  depends_on = [aws_key_pair.rajakey]
}

