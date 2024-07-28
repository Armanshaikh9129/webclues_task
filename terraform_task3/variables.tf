variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "igw_name" {
  type = string
}

variable "route_cidr_blocks" {
  type = string
}

variable "route_table_name" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "ingress_ssh" {
  type = string
}

variable "ingress_ssh_protocol" {
  type = string
}

variable "ingress_cidr" {
  type = list(string)
}

variable "ingress_web" {
  type = string
}

variable "ingress_web_protocol" {
  type = string
}

variable "ingress_web_cidr" {
  type = list(string)
}

variable "security_group_name" {
  type = string
}

variable "ami_image" {
  type = string
}

variable "instance_size" {
  type = string
}

variable "key" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "subnet_zone" {
  type = string
}
variable "private_key_path" {
  type = string
  description = "/home/arman/armankey.pem"
}



