provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2-user" {
  ami = var.os_name
  instance_type = var.instance_type
  key_name = var.key
  subnet_id = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
}

//create vpc
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc_cidr
}

//create subnet

resource "aws_subnet" "demo_subnet" {
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
     Name="demo subnet"
  }
}

//create internet gateway

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "igw"
  }
}

//create route table

resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  
  tags = {
    Name = "internet-route"
  }
}


//associate subnet for the route table

resource "aws_route_table_association" "rt_demo_subnet" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo-rt.id
}


//create security group

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  vpc_id      = aws_vpc.demo-vpc.id

  tags = {
    Name = "security group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg-ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = aws_vpc.demo-vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg-ipv6" {
  security_group_id = aws_security_group.demo-sg.id 
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv6         = "::/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

