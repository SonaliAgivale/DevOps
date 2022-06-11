provider "aws" {
  region     = "us-east-1"
}

#####vpc#####
resource "aws_vpc" "tfvpc" {
  cidr_block = "10.0.0.0/16"
}
####IG#####
resource "aws_internet_gateway" "TFgw" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    Name = "TFgw"
  }
}
#########subnet##########
resource "aws_subnet" "privateTF1" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "privateTF1"
  }
}
#####
resource "aws_subnet" "privateTF2" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privateTF2"
  }
}
resource "aws_subnet" "publicTF1" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "publicTF1"
  }
}
resource "aws_subnet" "publicTF2" {
  vpc_id     = aws_vpc.tfvpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "publicTF2"
  }
}
#####route table#####
resource "aws_route_table" "tfroute" {
  vpc_id = aws_vpc.tfvpc.id

  route = []
  tags = {
    Name = "tfroute"
  }
  }
  #####rout###########
resource "aws_route" "tfr" {
  route_table_id            = aws_route_table.tfroute.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.TFgw.id
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  depends_on                = [aws_route_table.tfroute]
}
####Security group###
resource "aws_security_group" "TfSecuritygrp" {
  name        = "TfSecuritygrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tfvpc.id

  ingress {#inbound rule
    description      = "All traffic"
    from_port        = 0
    to_port          = 0 #all Port
    protocol         = "-1"#All trafic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids = null
    security_groups = null
    self = null
  }

  egress { #Outbound rule
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Outbound rule"
    prefix_list_ids = null
    security_groups = null
    self = null
  }

  tags = {
    Name = "allow_traffic"
  }
}
#### rout table associaton ####
resource "aws_route_table_association" "RTTFAsssociation" {
  subnet_id      = aws_subnet.publicTF1.id
  route_table_id = aws_route_table.tfroute.id
}
#####EC2######
resource "aws_instance" "web" {
  ami           = "ami-005de95e8ff495156"
  instance_type = "t2.micro"

  tags = {
    Name = "TFInstance"
  }
}