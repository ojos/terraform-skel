resource "aws_sns_topic" "notification" {
  "name"         = "notification"
  "display_name" = "通知"
}

resource "aws_sns_topic" "critical" {
  "name"         = "critical"
  "display_name" = "クリティカル"
}

resource "aws_sns_topic" "recovery" {
  "name"         = "recovery"
  "display_name" = "復帰"
}
