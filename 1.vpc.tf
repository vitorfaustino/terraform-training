#######################################################################
# VPC
#######################################################################
resource "aws_vpc" "training" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

    tags = {
      Name = "vpc-training1"
  }
}


#######################################################################
# Security Groups
#######################################################################
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.training.id

  tags = {
    Name = "sg-default-training"
  }
}

resource "aws_security_group" "sg_backend" {
  name        = "training-backend-ssh"
  description = "Allow SSH only from Home/Office"
  vpc_id      = aws_vpc.training.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.home_ip]
    description = "Home Access"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-training-backend"
  }
}

resource "aws_security_group" "sg_frontend" {
  name        = "training-frontend-internet"
  description = "Allow SSH only from Home/Office"
  vpc_id      = aws_vpc.training.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.home_ip]
    description = "Home Access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Internet HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Internet HTTPS"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-training-frontend"
  }
}

#######################################################################
# Public Subnets & Public Route Association
#######################################################################

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id                  = aws_vpc.training.id
  cidr_block              = "10.0.0.${count.index * 16}/28"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = 2
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#######################################################################
# Internet gateway & Public routing table
#######################################################################
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.training.id

  tags = {
    Name = "ig-training-public"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.training.default_route_table_id

  tags = {
    Name = "crypto_rt_private_default"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.training.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name = "rt-training-public-1"
  }
}

#######################################################################
# Netwok ACL
#######################################################################
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.training.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

    tags = {
    Name = "nac-training-default"
  }

  lifecycle {
    ignore_changes = [subnet_ids]
  }

}
