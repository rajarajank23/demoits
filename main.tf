provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# S3 Bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-unique-12345" # Replace with a unique name

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "Dev"
  }

  force_destroy = true
}

# Generate RSA Key Pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# AWS Key Pair
resource "aws_key_pair" "rajakey" {
  key_name   = "rajakey-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "rajakey.pem" # Ensure this file is kept secure
}

# Security Group
resource "aws_security_group" "my_security_group" {
  name = "my-security-group-unique" # Unique name

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

  tags = {
    Name = "MySecurityGroup"
  }
}

# EC2 Instance
resource "aws_instance" "my_instance" {
  ami                   = "ami-0c7217cdde317cfec" # Replace with a valid AMI ID for your region
  instance_type         = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name              = aws_key_pair.rajakey.key_name

  tags = {
    Name = "public_instance"
  }
}

