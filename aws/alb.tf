resource "aws_alb" "default" {
  name                       = "${var.environment}"
  subnets                    = [
    "${aws_subnet.default-a.id}",
    "${aws_subnet.default-c.id}",
    "${aws_subnet.default-d.id}"
  ]
  security_groups            = [
    "${aws_security_group.default.id}"
  ]
  internal                   = false
  enable_deletion_protection = false

  tags {
      Name = "${var.environment}"
  }
}

resource "aws_alb_target_group" "default" {
  name     = "${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    interval            = 30
    path                = "/health_check"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = 200
  }

  tags {
      Name = "${var.environment}"
  }
}

resource "aws_autoscaling_attachment" "default" {
  autoscaling_group_name = "${aws_autoscaling_group.default.id}"
  alb_target_group_arn   = "${aws_alb_target_group.default.arn}"
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = "${aws_alb.default.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.arn}"
    type             = "forward"
  }
}
