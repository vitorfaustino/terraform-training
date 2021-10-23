variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/24"
}

variable "ec2_ami" {
  type = string
  default = "ami-0a8e758f5e873d1c1"
}

variable "aws_key_name" {
  description = "Key name for SSHing into EC2"
  default = "my-region-key"
}

variable "home_ip" {
  type = string
  default = "0.0.0.0/0"
}