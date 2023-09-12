resource "aws_vpc" "CAPSTONE" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "CAPSTONE"
  }
}
resource "aws_subnet" "PUBLIC-1" {
  vpc_id     = aws_vpc.CAPSTONE.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "PUBLIC-2" {
  vpc_id     = aws_vpc.CAPSTONE.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}
resource "aws_subnet" "PRIVATE" {
  vpc_id     = aws_vpc.CAPSTONE.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}
resource "aws_route_table" "PUBLIC" {
  vpc_id = aws_vpc.CAPSTONE.id
}
resource "aws_route_table" "PRIVATE" {
  vpc_id = aws_vpc.CAPSTONE.id
}
resource "aws_route_table_association" "PUBLIC-1" {
  subnet_id      = aws_subnet.PUBLIC-1.id
  route_table_id = aws_route_table.PUBLIC.id
}
resource "aws_route_table_association" "PUBLIC-2" {
  subnet_id      = aws_subnet.PUBLIC-2.id
  route_table_id = aws_route_table.PUBLIC.id
}
resource "aws_route_table_association" "PRIVATE" {
  subnet_id      = aws_subnet.PRIVATE.id
  route_table_id = aws_route_table.PRIVATE.id
}
resource "aws_internet_gateway" "CAPSTONE" {
  vpc_id = aws_vpc.CAPSTONE.id
}
resource "aws_route_table_association" "IG-ROUTE" {
  gateway_id     = aws_internet_gateway.CAPSTONE.id
  route_table_id = aws_route_table.PUBLIC.id
}
resource "aws_eip" "CAPSTONE" {
  domain   = "vpc"
}
resource "aws_nat_gateway" "CAPSTONE" {
  allocation_id = aws_eip.CAPSTONE.id
  subnet_id     = aws_subnet.PUBLIC-1.id
}
resource "aws_route" "ATTACH" {
  route_table_id = aws_route_table.PRIVATE.id
  nat_gateway_id = aws_nat_gateway.CAPSTONE.id
}
resource "aws_security_group" "CAPSTONE" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.CAPSTONE.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.CAPSTONE.cidr_block]
  }

    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.CAPSTONE.cidr_block]
  }

    ingress {
    description      = "TLS from VPC"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.CAPSTONE.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_key_pair" "CAPSTONE-KP" {
  key_name = "CAPSTONE.pem"
}
resource "aws_instance" "CAPSTONE-PROJECT" {
  ami           = ami-053b0d53c279acc90
  instance_type = "t2.micro"
  vpc_security_group_ids = aws_security_group.CAPSTONE.id
  subnet_id = aws_subnet.PRIVATE.id
  key_name = aws_key_pair.CAPSTONE.CAPSTONE.pem

  tags = {
    Name = "HelloWorld"
  }
}
