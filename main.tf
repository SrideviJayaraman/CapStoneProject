# vpc
resource "aws_vpc" "sri_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "sri-terr-vpc"
  }
}
# subnet 1 (public)
resource "aws_subnet" "sri_subnet1" {
  vpc_id = aws_vpc.sri_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone_id = "use1-az1"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terr-subnet1"
  }
}

resource "aws_subnet" "sri_subnet2" {
  vpc_id = aws_vpc.sri_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone_id = "use1-az2"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terr-subnet2"
  }
}
# subnet 2(public) change it to private
resource "aws_subnet" "sri_subnet3" {
  vpc_id = aws_vpc.sri_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone_id = "use1-az3"
  map_public_ip_on_launch = false
  tags = {
    Name = "Terr-subnet3"
  }

}

# internet gateway
resource "aws_internet_gateway" "sri_igw" {
  vpc_id = aws_vpc.sri_vpc.id
  tags = {
    Name = "Terr-igw"
  }
}


# route table 1 
resource "aws_route_table" "sri_rt_public" {
  vpc_id = aws_vpc.sri_vpc.id
  tags = {
    Name = "Terr-rt1"
  }
}
#route table 2 
resource "aws_route_table" "sri_rt_private" {
  gateway_id = "sri_igw"
  vpc_id = aws_vpc.sri_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "Terr-rt2"
  }
}
# Associating route table 1 with subnet 1 
resource "aws_route_table_association" "sri_subnet_rt_association1" {
  subnet_id = aws_subnet.sri_subnet1.id
  route_table_id = aws_route_table.sri_rt_public.id
}

# Associating route table 1 with subnet 2
resource "aws_route_table_association" "sri_subnet_rt_association2" {
  subnet_id = aws_subnet.sri_subnet2.id
  route_table_id = aws_route_table.sri_rt_public.id
}

# Associating route table 2 with subnet 3
resource "aws_route_table_association" "sri_subnet_rt_association3" {
  subnet_id = aws_subnet.sri_subnet3.id
  route_table_id = aws_route_table.sri_rt_private.id
}

# Adding the internet gateway route to route table 1
resource "aws_route" "sri_route1" {
  route_table_id = aws_route_table.sri_rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.sri_igw.id
}

# NAT Gateway
resource "aws_nat_gateway" "sri_nat_gateway" {
  allocation_id = aws_eip.sri_eip.id
  subnet_id     = aws_subnet.sri_subnet1.id # Replace with your public subnet ID
}

# Elastic IP for NAT Gateway
resource "aws_eip" "sri_eip" {
  domain = "vpc"
}

# Modify the route table associated with your private subnet to route traffic through the NAT Gateway
resource "aws_route" "sri_private_subnet_route" {
  route_table_id         = aws_route_table.sri_rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.sri_nat_gateway.id
}

# creating a security group
resource "aws_security_group" "sri_sg" {
  name = "terr-securitygroup"
  vpc_id = aws_vpc.sri_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "web_server1" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"   
  subnet_id     = aws_subnet.sri_subnet1.id
  key_name      = "ssh-terraform-key"
  security_groups = [aws_security_group.sri_sg.id]
  tags = {
    Name = "webserver-public"
  }
}
resource "aws_instance" "web_server2" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"    
  subnet_id     = aws_subnet.sri_subnet2.id
  key_name      = "ssh-terraform-key"
  security_groups = [aws_security_group.sri_sg.id]
  tags = {
    Name = "webserver-private"
  }
}

output "private_ip1" {
   value = aws_instance.web_server1.private_ip
}
output "public_ip1" {
   value = aws_instance.web_server1.public_ip
}

output "private_ip2" {
   value = aws_instance.web_server2.private_ip
}
output "public_ip2" {
   value = aws_instance.web_server2.public_ip
}
