provider "aws" {
  region = "us-east-1"
}

# Use the existing main VPC
data "aws_vpc" "my_vpc" {
  id = "vpc-0f0d4cadca20b9291"
}

# Use an existing subnet that doesn't conflict
data "aws_subnet" "existing_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.my_vpc.id]
  }
}

# Use an existing internet gateway (if one is already attached)
data "aws_internet_gateway" "existing_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.my_vpc.id]
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}


resource "aws_security_group" "ec2_sg" {
  name        = "EC2SecurityGroup"
  description = "Allow SSH access"
  vpc_id      = data.aws_vpc.my_vpc.id

  ingress {
    description = "SSH from anywhere (for lab purposes; restrict in production)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2SecurityGroup"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.existing_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "WebServerInstance"
  }
}

variable "key_pair_name" {
  description = "The name of the AWS key pair to use for SSH access"
  type        = string
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}
