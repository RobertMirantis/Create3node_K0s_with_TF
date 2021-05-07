
data "aws_availability_zones" "available" {
  state = "available"
}

######################################
## VPC
######################################
resource "aws_vpc" "RoHa_VPC3" {
  cidr_block       = "10.8.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "RoHa_VPC"
    Owner = "Robert Hartevelt"
  }
  enable_dns_hostnames = "true"
}

# SG
resource "aws_security_group" "RoHa_K0s_SG" {
  name        = "RoHa_K0s_SG"
  description = "Allow everything within SG"
  vpc_id      = aws_vpc.RoHa_VPC3.id

  ingress {
    description = "Allow all within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.RoHa_VPC3.cidr_block]
    self        = true
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow access to HTTPS GUI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow access for Lens"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RoHa_K0s_SG"
  }
}

######################################
## Internet Gateway 
######################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.RoHa_VPC3.id

  tags = {
    Name = "RoHa_IGW3"
  }
}

######################################
## Route tables public
######################################
resource "aws_route_table" "public_routes" {
  vpc_id     = aws_vpc.RoHa_VPC3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_routes"
    Owner = "Robert Hartevelt"
  }
}

# Public Subnet 1
resource "aws_subnet" "RoHa_VPC_sub1_pub" {
  vpc_id     = aws_vpc.RoHa_VPC3.id
  cidr_block = "10.8.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "RoHa_VPC_sub1_pub"
    nukeignore = "true"
  }
}

# Public Subnet 1 route table
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.RoHa_VPC_sub1_pub.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_instance" "server1" {
  ami           = "ami-0e0102e3ff768559b"
  instance_type = "t3.2xlarge"
  key_name = "rohaMirantis"
  associate_public_ip_address = true
  security_groups =  [aws_security_group.RoHa_K0s_SG.id]
  subnet_id      = aws_subnet.RoHa_VPC_sub1_pub.id

  tags          = {
    Name        = "RoHa K0s server1"
    Environment = "test"
  }

  root_block_device {
    delete_on_termination = "true"
    volume_size = "200"
  }
}


resource "aws_instance" "server2" {
  ami           = "ami-0e0102e3ff768559b"
  instance_type = "t3.2xlarge"
  key_name = "rohaMirantis"
  security_groups =  [aws_security_group.RoHa_K0s_SG.id]
  associate_public_ip_address = true
  subnet_id      = aws_subnet.RoHa_VPC_sub1_pub.id

  tags          = {
    Name        = "RoHa K0s server2"
    Environment = "test"
  }

   root_block_device {
    delete_on_termination = "true"
    volume_size = "200"
  }

}

resource "aws_instance" "server3" {
  ami           = "ami-0e0102e3ff768559b"
  instance_type = "t3.2xlarge"
  key_name = "rohaMirantis"
  associate_public_ip_address = true
  security_groups =  [aws_security_group.RoHa_K0s_SG.id]
  subnet_id      = aws_subnet.RoHa_VPC_sub1_pub.id

  tags          = {
    Name        = "RoHa K0s server3"
    Environment = "test"
  }

  root_block_device {
    delete_on_termination = "true"
    volume_size = "200"
  }
}

resource "null_resource" "launchpad" {

  provisioner "local-exec" {
    command = "cd scripts ; ./create_cluster.ksh ${aws_instance.server1.public_ip} ${aws_instance.server2.public_ip} ${aws_instance.server3.public_ip}"
  }
}
