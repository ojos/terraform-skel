resource "aws_security_group" "default" {
    name        = "default"
    description = "default VPC security group"
    vpc_id      = "${aws_vpc.default.id}"

    tags {
      Environment = "${var.environment}"
      Year        = "${var.year}"
    }
}

resource "aws_security_group_rule" "allow_in_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_in_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_in_https" {
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_in_mysql" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  cidr_blocks     = ["122.221.180.194/32"]

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_in_group" {
  type            = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  self            = true

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "allow_out_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.default.id}"
}
