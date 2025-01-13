 terraform {
  backend "s3" {
    bucket         = "raja"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
	dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}
  
  
resource "aws_key_pair" "rajakey" {
  key_name   = "rajakey-key"
  public_key = tls_private_key.rsa.public_key_openssh

}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits   = 4096
}

resource "local_file" "private_key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "rajakey"
}

resource "aws_security_group" "my-security-group" {
  name = "my-security-group"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-instance" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.my-security-group.name]
  key_name=aws_key_pair.rajakey.key_name
  
  tags = {
  Name = "public_instance"
}
}
