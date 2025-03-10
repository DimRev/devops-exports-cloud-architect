# Provider Configuration for AWS
provider "aws" {
  region = "us-east-1"
}

# Local SSH Key Configuration
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your local public key
}

# VPC 1 Configuration
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC1"
  }
}

# VPC 2 Configuration
resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "VPC2"
  }
}

# Subnets for VPC 1
resource "aws_subnet" "vpc1_public_subnet" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true  # Enable public IP assignment on launch
  tags = {
    Name = "VPC1 Public Subnet"
  }
}

# Subnets for VPC 2
resource "aws_subnet" "vpc2_public_subnet" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true  # Enable public IP assignment on launch
  tags = {
    Name = "VPC2 Public Subnet"
  }
}

# Internet Gateway for VPC 1
resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "VPC1 IGW"
  }
}

# Internet Gateway for VPC 2
resource "aws_internet_gateway" "vpc2_igw" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "VPC2 IGW"
  }
}

# Route Table for VPC 1 Public Subnet
resource "aws_route_table" "vpc1_public_rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }

  tags = {
    Name = "VPC1 Public Route Table"
  }
}

resource "aws_route_table_association" "vpc1_public_rt_assoc" {
  subnet_id      = aws_subnet.vpc1_public_subnet.id
  route_table_id = aws_route_table.vpc1_public_rt.id
}

# Route Table for VPC 2 Public Subnet
resource "aws_route_table" "vpc2_public_rt" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc2_igw.id
  }

  tags = {
    Name = "VPC2 Public Route Table"
  }
}

resource "aws_route_table_association" "vpc2_public_rt_assoc" {
  subnet_id      = aws_subnet.vpc2_public_subnet.id
  route_table_id = aws_route_table.vpc2_public_rt.id
}

# Security Group for VPC 1 - Allow ALL Traffic
resource "aws_security_group" "vpc1_sg" {
  vpc_id = aws_vpc.vpc1.id

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow to anywhere
  }

  tags = {
    Name = "VPC1-SG"
  }
}

# Security Group for VPC 2 - Allow ALL Traffic
resource "aws_security_group" "vpc2_sg" {
  vpc_id = aws_vpc.vpc2.id

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow to anywhere
  }

  tags = {
    Name = "VPC2-SG"
  }
}

# EC2 Instance in VPC 1
resource "aws_instance" "vpc1_ec2" {
  ami           = "ami-0fff1b9a61dec8a5f"  # Use an Ubuntu or Amazon Linux AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.vpc1_public_subnet.id
  vpc_security_group_ids = [aws_security_group.vpc1_sg.id]  # Use vpc_security_group_ids for VPCs
  key_name      = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true  # Explicitly assign public IP

  tags = {
    Name = "VPC1-EC2"
  }
}

# EC2 Instance in VPC 2
resource "aws_instance" "vpc2_ec2" {
  ami           = "ami-0fff1b9a61dec8a5f"  # Use an Ubuntu or Amazon Linux AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.vpc2_public_subnet.id
  vpc_security_group_ids = [aws_security_group.vpc2_sg.id]  # Use vpc_security_group_ids for VPCs
  key_name      = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true  # Explicitly assign public IP

  tags = {
    Name = "VPC2-EC2"
  }
}

# VPC Peering between VPC1 and VPC2
resource "aws_vpc_peering_connection" "vpc1_vpc2" {
  vpc_id        = aws_vpc.vpc1.id
  peer_vpc_id   = aws_vpc.vpc2.id
  auto_accept   = true

  tags = {
    Name = "VPC1-to-VPC2 Peering"
  }
}

# Add a route in VPC 1 route table to VPC 2
resource "aws_route" "vpc1_to_vpc2" {
  route_table_id         = aws_route_table.vpc1_public_rt.id
  destination_cidr_block = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2.id
}

# Add a route in VPC 2 route table to VPC 1
resource "aws_route" "vpc2_to_vpc1" {
  route_table_id         = aws_route_table.vpc2_public_rt.id
  destination_cidr_block = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2.id
}

# Output key details
output "vpc1_id" {
  value = aws_vpc.vpc1.id
}

output "vpc2_id" {
  value = aws_vpc.vpc2.id
}

output "vpc1_ec2_public_ip" {
  value = aws_instance.vpc1_ec2.public_ip
}

output "vpc2_ec2_public_ip" {
  value = aws_instance.vpc2_ec2.public_ip
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.vpc1_vpc2.id
}