variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "subnet_a_cidr" {
  default = "172.31.16.0/20"
}

variable "subnet_c_cidr" {
  default = "172.31.0.0/20"
}

variable "subnet_d_cidr" {
  default = "172.31.32.0/20"
}

variable "subnet_map_public_ip_on_launch" {
  default = true
}

resource "aws_vpc" "default" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
      Name        = "${var.year}-${var.environment}"
      Environment = "${var.environment}"
      Year        = "${var.year}"
    }
}

resource "aws_subnet" "default-a" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "${var.subnet_a_cidr}"
    availability_zone       = "${var.aws_default_region}a"
    map_public_ip_on_launch = "${var.subnet_map_public_ip_on_launch}"

    tags {
      Name        = "${var.year}-${var.environment}-a"
      Environment = "${var.environment}"
      Year        = "${var.year}"
    }
}

resource "aws_subnet" "default-c" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "${var.subnet_c_cidr}"
    availability_zone       = "${var.aws_default_region}c"
    map_public_ip_on_launch = "${var.subnet_map_public_ip_on_launch}"

    tags {
      Name        = "${var.year}-${var.environment}-c"
      Environment = "${var.environment}"
      Year        = "${var.year}"
    }
}

resource "aws_subnet" "default-d" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "${var.subnet_d_cidr}"
    availability_zone       = "${var.aws_default_region}d"
    map_public_ip_on_launch = "${var.subnet_map_public_ip_on_launch}"

    tags {
      Name        = "${var.year}-${var.environment}-d"
      Environment = "${var.environment}"
      Year        = "${var.year}"
    }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name        = "${var.year}-${var.environment}"
    Environment = "${var.environment}"
    Year        = "${var.year}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
    Name        = "${var.year}-${var.environment}"
    Environment = "${var.environment}"
    Year        = "${var.year}"
  }
}

# resource "aws_route" "default" {
#   route_table_id            = "${aws_route_table.default.id}"
#   destination_cidr_block    = "0.0.0.0/0"
# }

resource "aws_main_route_table_association" "default" {
  vpc_id         = "${aws_vpc.default.id}"
  route_table_id = "${aws_route_table.default.id}"
}
