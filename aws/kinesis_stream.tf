resource "aws_kinesis_stream" "default" {
  name             = "${var.environment}"
  shard_count      = 2
  retention_period = 24

  # shard_level_metrics = [
  #   "IncomingBytes",
  #   "OutgoingBytes",
  # ]

  tags {
    Environment = "${var.environment}"
  }
}
