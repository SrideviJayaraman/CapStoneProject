resource "aws_vpc" "sri_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub1(pub)" {
  vpc_id     = aws_vpc.sri_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "sub2(pub)" {
  vpc_id     = aws_vpc.sri_vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "sub3(priv)" {
  vpc_id     = aws_vpc.sri_vpc.id
  cidr_block = "10.0.3.0/24"
}
