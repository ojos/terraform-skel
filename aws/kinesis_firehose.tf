data "aws_iam_policy_document" "kinesis-firehose-elasticsearch" {
  statement =[
    {
      actions = [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ]
      resources = [
        "arn:aws:s3:::${data.aws_s3_bucket.resource.bucket}",
        "arn:aws:s3:::${data.aws_s3_bucket.resource.bucket}/*"
      ]
    },
    {
      actions = [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
      ]
      resources = [
        "arn:aws:lambda:${var.aws_default_region}:${var.aws_account_id}:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
      ]
    },
    {
      actions = [
        "es:DescribeElasticsearchDomain",
        "es:DescribeElasticsearchDomains",
        "es:DescribeElasticsearchDomainConfig",
        "es:ESHttpPost",
        "es:ESHttpPut"
      ]
      resources = [
        "${aws_elasticsearch_domain.default.arn}",
        "${aws_elasticsearch_domain.default.arn}/*"
      ]
    },
    {
      actions = [
        "es:ESHttpGet"
      ]
      resources = [
          "${aws_elasticsearch_domain.default.arn}/_all/_settings",
          "${aws_elasticsearch_domain.default.arn}/_cluster/stats",
          "${aws_elasticsearch_domain.default.arn}/_nodes",
          "${aws_elasticsearch_domain.default.arn}/_nodes/stats",
          "${aws_elasticsearch_domain.default.arn}/_nodes/*/stats",
          "${aws_elasticsearch_domain.default.arn}/_stats",
          "${aws_elasticsearch_domain.default.arn}/wish*/_mapping/japan",
          "${aws_elasticsearch_domain.default.arn}/wish*/_stats",
          "${aws_elasticsearch_domain.default.arn}/simple-wish*/_mapping/japan",
          "${aws_elasticsearch_domain.default.arn}/simple-wish*/_stats",
          "${aws_elasticsearch_domain.default.arn}/log*/_mapping/message",
          "${aws_elasticsearch_domain.default.arn}/log*/_stats"
      ]
    },
    {
      actions = [
        "logs:PutLogEvents"
      ]
      resources = [
          "arn:aws:logs:${var.aws_default_region}:${var.aws_account_id}:log-group:/aws/kinesisfirehose/${var.environment}-wish:log-stream:*",
          "arn:aws:logs:${var.aws_default_region}:${var.aws_account_id}:log-group:/aws/kinesisfirehose/${var.environment}-simple-wish:log-stream:*",
          "arn:aws:logs:${var.aws_default_region}:${var.aws_account_id}:log-group:/aws/kinesisfirehose/${var.environment}-log:log-stream:*"
      ]
    },
    {
      actions = [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords"
      ]
      resources = [
          "arn:aws:kinesis:${var.aws_default_region}:${var.aws_account_id}:stream/%FIREHOSE_STREAM_NAME%"
      ]
    },
    {
      actions = ["kms:Decrypt"]
      resources = [
        "arn:aws:kms:region:accountid:key/%SSE_KEY_ARN%"
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "kms:ViaService"
          values = [
            "kinesis.%REGION_NAME%.amazonaws.com"
          ]
        },
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:kinesis:arn"
          values = [
            "arn:aws:kinesis:%REGION_NAME%:${var.aws_account_id}:stream/%FIREHOSE_STREAM_NAME%"
          ]
        }
      ]
    }
  ]
}

resource "aws_iam_policy" "kinesis-firehose-elasticsearch" {
  name   = "${var.year}-${var.environment}-kinesis-firehose-elasticsearch"
  path   = "/"
  policy = "${data.aws_iam_policy_document.kinesis-firehose-elasticsearch.json}"
}

resource "aws_iam_policy_attachment" "kinesis-firehose" {
  name       = "kinesis-firehose"
  roles      = ["${aws_iam_role.kinesis-firehose.name}"]
  policy_arn = "${aws_iam_policy.kinesis-firehose-elasticsearch.arn}"
}

data "aws_iam_policy_document" "kinesis-firehose-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    condition = {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${var.aws_account_id}"
      ]
    }
  }
}

resource "aws_iam_role" "kinesis-firehose" {
  name               = "${var.environment}-kinesis-firehose"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.kinesis-firehose-assume-role.json}"
}

resource "aws_kinesis_firehose_delivery_stream" "default" {
  name        = "${var.environment}"
  destination = "elasticsearch"

  s3_configuration {
    role_arn           = "${aws_iam_role.kinesis-firehose.arn}"
    bucket_arn         = "arn:aws:s3:::${data.aws_s3_bucket.resource.bucket}"
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "UNCOMPRESSED"
    prefix             = "kinesis-firehose/${var.environment}/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${var.environment}"
      log_stream_name = "S3Delivery"
    }
  }

  elasticsearch_configuration {
    domain_arn = "${aws_elasticsearch_domain.default.arn}"
    role_arn   = "${aws_iam_role.kinesis-firehose.arn}"

    index_name            = "index"
    index_rotation_period = "OneDay"
    type_name             = "type"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${var.environment}"
      log_stream_name = "ElasticsearchDelivery"
    }

    processing_configuration = [
      {
        enabled = "false"
        # processors = [
        #   {
        #     type = "Lambda"
        #     parameters = [
        #       {
        #         parameter_name = "LambdaArn"
        #         parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        #       }
        #     ]
        #   }
        # ]
      }
    ]
  }
}
