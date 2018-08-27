resource "aws_dynamodb_table" "user" {
  name           = "user"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "uid"

  attribute = [
    {
      name = "uid"
      type = "S"
    }
  ]

  tags {
    Name        = "user"
    Environment = "${var.environment}"
  }
}

data "aws_iam_role" "dynamodb_autoscaling" {
  name = "AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"
}

resource "aws_appautoscaling_target" "dynamodb_read" {
  max_capacity       = 50
  min_capacity       = "${aws_dynamodb_table.default.read_capacity}"
  resource_id        = "table/${aws_dynamodb_table.default.name}"
  role_arn           = "${data.aws_iam_role.dynamodb_autoscaling.arn}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_read" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_read.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_read.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_read.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_read.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "dynamodb_write" {
  max_capacity       = 50
  min_capacity       = "${aws_dynamodb_table.default.write_capacity}"
  resource_id        = "table/${aws_dynamodb_table.default.name}"
  role_arn           = "${data.aws_iam_role.dynamodb_autoscaling.arn}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_write" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_write.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_write.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_write.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_write.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_dynamodb_table" "message" {
  name           = "message"
  read_capacity  = "${aws_autoscaling_group.default.max_size * 5}"
  write_capacity = "${aws_autoscaling_group.default.max_size * 5}"
  hash_key       = "leaseKey"

  attribute = [
    {
      name = "leaseKey"
      type = "S"
    }
  ]

  tags {
    Environment = "${var.environment}"
  }
}
