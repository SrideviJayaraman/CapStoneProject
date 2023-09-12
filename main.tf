resource "aws_vpc" "sri-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub1_pub" {
  vpc_id     = aws_vpc.sri-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "sub2_pub" {
  vpc_id     = aws_vpc.sri-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "sub3_priv" {
  vpc_id     = aws_vpc.sri-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_route_table" "PUBLIC-RT" {
  vpc_id = aws_vpc.sri-vpc.id
}

resource "aws_route_table" "PRIVATE-RT" {
  vpc_id = aws_vpc.sri-vpc.id
}

resource "aws_route_table_association" "PUBLIC-RT1" {
  subnet_id      = aws_subnet.sub1_pub.id
  route_table_id = aws_route_table.PUBLIC-RT.id
}

resource "aws_route_table_association" "PUBLIC-RT2" {
  subnet_id      = aws_subnet.sub2_pub.id
  route_table_id = aws_route_table.PUBLIC-RT.id
}

resource "aws_route_table_association" "PRIVATE-RT" {
  subnet_id      = aws_subnet.sub3_priv.id
  route_table_id = aws_route_table.PRIVATE-RT.id
}

resource "aws_internet_gateway" "sri-gw" {
  vpc_id = aws_vpc.sri-vpc.id
}

resource "aws_route_table_association" "rt-igw" {
  gateway_id     = aws_internet_gateway.sri-gw.id
  route_table_id = aws_route_table.PUBLIC-RT.id
}
resource "aws_eip" "sri-eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "sri-ngw" {
  allocation_id = aws_eip.sri-eip.id
  subnet_id     = aws_subnet.sub1_pub.id
}

resource "aws_route" "PRIVATE-RT-NGW" {
  route_table_id         = aws_route_table.PRIVATE-RT.id
  nat_gateway_id         = aws_nat_gateway.sri-ngw.id
}
