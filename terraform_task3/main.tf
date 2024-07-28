terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}
  

# main.tf

provider "aws" {
  region = var.region  # Specify your desired region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.resource_name
  }
}
# Create a subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true 
  availability_zone = var.subnet_zone
  tags = {
    Name = var.subnet_name
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = var.igw_name
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.route_cidr_blocks
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "web_sg" {
  name        = var.sg_name
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.ingress_ssh
    to_port     = var.ingress_ssh
    protocol    = var.ingress_ssh_protocol
    cidr_blocks = var.ingress_cidr
  }

  ingress {
    from_port   = var.ingress_web
    to_port     = var.ingress_web
    protocol    = var.ingress_web_protocol
    cidr_blocks = var.ingress_web_cidr
  }

  tags = {
    Name = var.security_group_name
  }
}

# Launch an EC2 instance
resource "aws_instance" "web" {
  ami             = var.ami_image  # Replace with a valid AMI ID for your region
  instance_type   = var.instance_size
  subnet_id       = aws_subnet.my_subnet.id
   vpc_security_group_ids = [aws_security_group.web_sg]
  key_name        = var.key  # Replace with your EC2 key pair

  tags = {
    Name = var.instance_name
  }
    
    provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"  # Adjust this based on the AMI's default user (e.g., "ubuntu" for Ubuntu AMIs)
      private_key = file(var.private_key_path)  # Path to your private key file
      host        = self.public_ip  # Use the instance's public IP address
    }
    
     inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
}