terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}
  



provider "aws" {
  region = var.region 
}


resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.resource_name
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true 
  availability_zone = var.subnet_zone
  tags = {
    Name = var.subnet_name
  }
}


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


resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


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


resource "aws_instance" "web" {
  ami             = var.ami_image  
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
      user        = "ubuntu"  
      private_key = file(var.private_key_path)  
      host        = self.public_ip  
    }
    
     inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
}
