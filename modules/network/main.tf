data "aws_availability_zones" "available" {
  state = "available"
}


# Creating a VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = { Name = "${var.naming_prefix}-vpc" }
}


# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.naming_prefix}-igw"
  }
}


# Creating Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  # availability_zone       = element(data.aws_availability_zones.available.names)

  tags = {
    Name = "${var.naming_prefix}-public-subnet"
  }
}

#  Private Subnets
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr_block
  map_public_ip_on_launch = false
  # availability_zone       = element(data.aws_availability_zones.available.names)

  tags = {
    Name = "${var.naming_prefix}-private-subnet"
  }
}



# Route Table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.naming_prefix}-rt"
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id 
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.naming_prefix}-ec2-sg"
  vpc_id = aws_vpc.vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["20.223.228.255/32"]
    description = "Allow HTTP traffic JD IP"
    self        = true # allow access from the same security group
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["20.223.228.255/32"]
    description = "Allow HTTPS traffic JD IP"
    self        = true # allow access from the same security group
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["20.223.228.255/32"] # Replace with your IP address
    description = "Allow SSH traffic from JD address only"
    self        = true # allow access from the same security group
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


