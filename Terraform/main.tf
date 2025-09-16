provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami="ami-0b09ffb6d8b58ca91"
    instance_type = "t3.micro"
    key_name = "Demo"
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.demo-public-subnet-01.id
    associate_public_ip_address = true
}

resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_security_group" "demo-sg" {
    name = "demo-sg"
    description = "Allow SSH access"
    vpc_id = aws_vpc.demo-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #All IP addresses
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "demo-sg"
    }   
}

resource "aws_subnet" "demo-public-subnet-01" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "demo-public-subnet-01"
    }
}

resource "aws_subnet" "demo-public-subnet-02" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "demo-public-subnet-02"
    }
}

resource "aws_internet_gateway" "demo-igw" {
    vpc_id = aws_vpc.demo-vpc.id

    tags = {
        Name = "demo-igw"
    }
}

resource "aws_route_table" "demo-public-rt" {
    vpc_id = aws_vpc.demo-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id
    }
}

resource "aws_route_table_association" "demo-public-rt-assoc-01" {
    subnet_id = aws_subnet.demo-public-subnet-01.id
    route_table_id = aws_route_table.demo-public-rt.id
}

resource "aws_route_table_association" "demo-public-rt-assoc-02" {
    subnet_id = aws_subnet.demo-public-subnet-02.id
    route_table_id = aws_route_table.demo-public-rt.id
}