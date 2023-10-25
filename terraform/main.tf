terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic on port 443"
  # vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    # cidr_blocks      = [aws_vpc.main.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "app_ami" {
  most_recent = true

  # name_regex       = "^myami-\\d{3}"
  name_regex = "cocktails-app-*"

  # owners           = ["self"]
  owners = ["amazon"]
}

resource "aws_instance" "web_app" {
  instance_type = "t2.micro"

  # ami                    = "ami-0c55b159cbfafe1f0"
  ami = data.aws_ami.app_ami.id

  vpc_security_group_ids = [aws_security_group.allow_tls.id]
}
