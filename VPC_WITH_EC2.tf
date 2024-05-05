provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2-user" {
  ami = "ami-07caf09b362be10b8"
  instance_type = "t2.micro"
  key_name = "linux-kp"
  subnet_id = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
}

//create vpc
resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.10.0.0/16"
}

//create subnet

resource "aws_subnet" "demo_subnet" {
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = "10.10.1.0/24"
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

