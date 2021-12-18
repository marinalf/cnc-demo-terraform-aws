# AWS provider

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key_id
  secret_key = var.secret_access_key
}

# Existing resources in AWS

data "aws_ami" "linux2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Creating an EC2 instance

resource "aws_instance" "demo-ec2" {
  ami                         = data.aws_ami.linux2_ami.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.capic_subnet.id
  associate_public_ip_address = true

  tags = {
    "${var.tag_key}" = var.tag_value
  }
}

# Existing resources created by cAPIC

data "aws_subnet" "capic_subnet" {
  filter {
    name   = "tag:Name"
    values = ["subnet-[${data.terraform_remote_state.vpc.outputs.subnet}]"]
  }
  availability_zone = "us-east-1a"
  vpc_id            = data.aws_vpc.capic_vpc.id
}

data "aws_vpc" "capic_vpc" {
  tags = {
    Name = "${data.terraform_remote_state.vpc.outputs.vpc}"
  }
}

# Link to main folder and outputs

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}
