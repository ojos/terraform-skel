data "aws_cloudwatch_log_group" "fluentd-reciever" {
  name = "/var/log/supervisord/fluentd_reciever.log"
}

data "aws_cloudwatch_log_group" "fluentd-producer" {
  name = "/var/log/supervisord/fluentd_producer.log"
}

data "aws_cloudwatch_log_group" "fluentd-sender" {
  name = "/var/log/supervisord/fluentd_sender.log"
}

resource "aws_cloudwatch_log_metric_filter" "fluentd-reciever-error" {
  name           = "fluentd-reciever-error"
  pattern        = "error"
  log_group_name = "${data.aws_cloudwatch_log_group.fluentd-reciever.name}"

  metric_transformation {
    name      = "fluentd-reciever-error"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "fluentd-producer-error" {
  name           = "fluentd-producer-error"
  pattern        = "error"
  log_group_name = "${data.aws_cloudwatch_log_group.fluentd-producer.name}"

  metric_transformation {
    name      = "fluentd-producer-error"
    namespace = "LogMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "fluentd-sender-error" {
  name           = "fluentd-sender-error"
  pattern        = "error"
  log_group_name = "${data.aws_cloudwatch_log_group.fluentd-sender.name}"

  metric_transformation {
    name      = "fluentd-sender-error"
    namespace = "LogMetrics"
    value     = "1"
  }
}
