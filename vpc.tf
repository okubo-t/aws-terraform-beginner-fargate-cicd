locals {

  vpc-01 = {
    name                 = "${var.prefix}-${var.env}-vpc"
    cidr                 = "10.1.0.0/16"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"

  }

  igw-01 = {
    name = "${var.prefix}-${var.env}-igw"
  }

  public-subnet-01 = {
    name                    = "${var.prefix}-${var.env}-public-a"
    cidr                    = "10.1.1.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = true
  }

  public-subnet-02 = {
    name                    = "${var.prefix}-${var.env}-public-c"
    cidr                    = "10.1.2.0/24"
    availability_zone       = "ap-northeast-1c"
    map_public_ip_on_launch = true
  }

  private-subnet-01 = {
    name                    = "${var.prefix}-${var.env}-private-a"
    cidr                    = "10.1.3.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = false
  }

  private-subnet-02 = {
    name                    = "${var.prefix}-${var.env}-private-c"
    cidr                    = "10.1.4.0/24"
    availability_zone       = "ap-northeast-1c"
    map_public_ip_on_launch = false
  }

}

# vpc
resource "aws_vpc" "vpc-01" {
  cidr_block           = local.vpc-01["cidr"]
  enable_dns_support   = local.vpc-01["enable_dns_support"]
  enable_dns_hostnames = local.vpc-01["enable_dns_hostnames"]

  tags = {
    Name = local.vpc-01["name"]
  }
}

# internet gateway
resource "aws_internet_gateway" "igw-01" {
  vpc_id = aws_vpc.vpc-01.id

  tags = {
    Name = local.igw-01["name"]
  }
}

# public subnet
resource "aws_subnet" "public-subnet-01" {
  vpc_id                  = aws_vpc.vpc-01.id
  cidr_block              = local.public-subnet-01["cidr"]
  availability_zone       = local.public-subnet-01["availability_zone"]
  map_public_ip_on_launch = local.public-subnet-01["map_public_ip_on_launch"]

  tags = {
    Name = local.public-subnet-01["name"]
  }
}
resource "aws_subnet" "public-subnet-02" {
  vpc_id                  = aws_vpc.vpc-01.id
  cidr_block              = local.public-subnet-02["cidr"]
  availability_zone       = local.public-subnet-02["availability_zone"]
  map_public_ip_on_launch = local.public-subnet-02["map_public_ip_on_launch"]

  tags = {
    Name = local.public-subnet-02["name"]
  }
}

resource "aws_route_table" "public-rt-01" {
  vpc_id = aws_vpc.vpc-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-01.id
  }

  tags = {
    Name = "${local.public-subnet-01["name"]}-rt"
  }
}

resource "aws_route_table" "public-rt-02" {
  vpc_id = aws_vpc.vpc-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-01.id
  }

  tags = {
    Name = "${local.public-subnet-02["name"]}-rt"
  }
}

resource "aws_route_table_association" "public-rt-asa-01" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.public-rt-01.id
}

resource "aws_route_table_association" "public-rt-asa-02" {
  subnet_id      = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.public-rt-02.id
}

# private subnet
resource "aws_subnet" "private-subnet-01" {
  vpc_id                  = aws_vpc.vpc-01.id
  cidr_block              = local.private-subnet-01["cidr"]
  availability_zone       = local.private-subnet-01["availability_zone"]
  map_public_ip_on_launch = local.private-subnet-01["map_public_ip_on_launch"]

  tags = {
    Name = local.private-subnet-01["name"]
  }
}
resource "aws_subnet" "private-subnet-02" {
  vpc_id                  = aws_vpc.vpc-01.id
  cidr_block              = local.private-subnet-02["cidr"]
  availability_zone       = local.private-subnet-02["availability_zone"]
  map_public_ip_on_launch = local.private-subnet-02["map_public_ip_on_launch"]

  tags = {
    Name = local.private-subnet-02["name"]
  }
}

resource "aws_route_table" "private-rt-01" {
  vpc_id = aws_vpc.vpc-01.id

  tags = {
    Name = "${local.private-subnet-01["name"]}-rt"
  }
}

resource "aws_route_table" "private-rt-02" {
  vpc_id = aws_vpc.vpc-01.id

  tags = {
    Name = "${local.private-subnet-02["name"]}-rt"
  }
}

resource "aws_route_table_association" "private-rt-asa-01" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.private-rt-01.id
}

resource "aws_route_table_association" "private-rt-asa-02" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.private-rt-02.id
}
