resource "aws_launch_configuration" "default" {
    image_id                    = "${var.aws_default_ec2_ami}"
    instance_type               = "m4.large"
    security_groups             = [
      "${aws_security_group.default.id}"
    ]
    key_name                    = "${aws_key_pair.default.key_name}"
    associate_public_ip_address = true

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "default" {
    name                      = "${var.environment}"
    max_size                  = 2
    min_size                  = 2
    desired_capacity          = 2
    health_check_grace_period = 300
    health_check_type         = "ELB"
    force_delete              = false
    vpc_zone_identifier       = [
      "${aws_subnet.default-a.id}",
      "${aws_subnet.default-c.id}",
      "${aws_subnet.default-d.id}"
    ]
    launch_configuration      = "${aws_launch_configuration.default.name}"

    tag {
        key                 = "Name"
        value               = "${var.project}-${var.environment}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Environment"
        value               = "${var.environment}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Project"
        value               = "${var.project}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Roles"
        value               = "api,admin"
        propagate_at_launch = true
    }
    tag {
        key                 = "Owner"
        value               = "admin"
        propagate_at_launch = true
    }
}
