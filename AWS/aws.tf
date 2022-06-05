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

resource "aws_instance" "demo-ec2-web" {
  ami                         = data.aws_ami.linux2_ami.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.capic_subnet_web.id
  associate_public_ip_address = true

  tags = {
     Name = "web-vm"
  }
}

resource "aws_instance" "demo-ec2-db" {
  ami                         = data.aws_ami.linux2_ami.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.capic_subnet_db.id
  associate_public_ip_address = false

  tags = {
    Name = "db-vm"
  }
}

# Existing resources created by cAPIC

data "aws_subnet" "capic_subnet_web" {
  filter {
    name   = "tag:Name"
    values = ["subnet-[${data.terraform_remote_state.vpc.outputs.web-subnet}]"]
  }
  availability_zone = "us-east-1a"
  vpc_id            = data.aws_vpc.capic_vpc.id
}

data "aws_subnet" "capic_subnet_db" {
  filter {
    name   = "tag:Name"
    values = ["subnet-[${data.terraform_remote_state.vpc.outputs.db-subnet}]"]
  }
  availability_zone = "us-east-1b"
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
