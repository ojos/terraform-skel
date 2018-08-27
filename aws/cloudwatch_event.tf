resource "aws_cloudwatch_event_rule" "batch" {
  name                = "batch"
  description         = "Batch for put stats"
  schedule_expression = "cron(0 19 * * ? *)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "batch" {
  target_id = "${var.environment}-batch"
  rule      = "${aws_cloudwatch_event_rule.batch.name}"
  arn       = "${aws_lambda_function.batch.arn}"
  input     =<<EOF
{
  "image_id": "${var.aws_default_ec2_ami}",
  "key_name": "${aws_key_pair.default.key_name}",
  "security_group_ids": ["${aws_security_group.default.id}"],
  "subnet_id": "${aws_subnet.default-c.id}",
  "tags": [
    {
      "Key": "Name",
      "Value": "${var.project}-${var.environment}"
    },
    {
      "Key": "Project",
      "Value": "${var.project}"
    },
    {
      "Key": "Owner",
      "Value": "${var.owner}"
    },
    {
      "Key": "Environment",
      "Value": "${var.environment}"
    },
    {
      "Key": "Roles",
      "Value": "batch"
    }
  ]
}
EOF
}
