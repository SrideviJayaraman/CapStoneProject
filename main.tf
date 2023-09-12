resource "aws_vpc" "sri-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub1_pub" {
  vpc_id     = aws_vpc.sri-vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "sub2_pub" {
  vpc_id     = aws_vpc.sri-vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "sub3_priv" {
  vpc_id     = aws_vpc.sri-vpc.id
  cidr_block = "10.0.3.0/24"
}
