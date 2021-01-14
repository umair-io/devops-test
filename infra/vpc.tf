resource "aws_vpc" "default" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true

    tags = {
        Name = "Prod"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "az1" {
    vpc_id = aws_vpc.default.id

    cidr_block = var.subnet_a_cidr
    availability_zone = "${var.region}a"

    map_public_ip_on_launch = "true"

    tags = {
        Name = "Subnet A"
    }
}

resource "aws_route_table" "az1" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
        Name = "Subnet A"
    }
}

resource "aws_route_table_association" "az1" {
    subnet_id = aws_subnet.az1.id
    route_table_id = aws_route_table.az1.id
}

resource "aws_subnet" "az2" {
    vpc_id = aws_vpc.default.id

    cidr_block = var.subnet_b_cidr
    availability_zone = "${var.region}b"

    tags = {
        Name = "Subnet B"
    }
}

resource "aws_route_table" "az2" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
        Name = "Subnet B"
    }
}

resource "aws_route_table_association" "az2" {
    subnet_id = aws_subnet.az2.id
    route_table_id = aws_route_table.az2.id
}
