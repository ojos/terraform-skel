# data "aws_iam_policy_document" "elasticsearch-cognito" {
#   statement =[
#     {
#       actions = [
#           "cognito-idp:DescribeUserPool",
#           "cognito-idp:CreateUserPoolClient",
#           "cognito-idp:DeleteUserPoolClient",
#           "cognito-idp:DescribeUserPoolClient",
#           "cognito-idp:AdminInitiateAuth",
#           "cognito-idp:AdminUserGlobalSignOut",
#           "cognito-idp:ListUserPoolClients",
#           "cognito-identity:DescribeIdentityPool",
#           "cognito-identity:UpdateIdentityPool",
#           "cognito-identity:SetIdentityPoolRoles",
#           "cognito-identity:GetIdentityPoolRoles"
#       ]
#       resources = [
#         "*",
#       ]
#     },
#     {
#       actions = ["iam:PassRole"]
#       resources = [
#         "*",
#       ]
#       condition = {
#         test     = "StringLike"
#         variable = "ciam:PassedToService"
#         values = [
#           "cognito-identity.amazonaws.com"
#         ]
#       }
#     }
#   ]
# }
#
# resource "aws_iam_policy" "elasticsearch-cognito" {
#   name   = "AmazonESCognitoAccess"
#   path   = "/"
#   policy = "${data.aws_iam_policy_document.elasticsearch-cognito.json}"
# }

# resource "aws_iam_policy_attachment" "elasticsearch-cognito" {
#   name       = "elasticsearch-cognito"
#   roles      = ["${aws_iam_role.elasticsearch-cognito.name}"]
#   policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
# }

# data "aws_iam_policy_document" "elasticsearch-assume-role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#
#     principals {
#       type        = "Service"
#       identifiers = ["es.amazonaws.com"]
#     }
#   }
# }
#
# resource "aws_iam_role" "elasticsearch-cognito" {
#   name               = "${var.year}-${var.environment}-elasticsearch-cognito"
#   path               = "/"
#   assume_role_policy = "${data.aws_iam_policy_document.elasticsearch-assume-role.json}"
# }

data "aws_iam_policy_document" "elasticsearch-access" {
  statement = [
    {
      actions = ["es:*"]
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      condition = {
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = "${var.allow_ip_address}"
      }
      resources = [
        "arn:aws:es:${var.aws_default_region}:${var.aws_account_id}:domain/${var.environment}/*",
      ]
    },
    {
      actions = ["es:*"]
      principals {
        type        = "AWS"
        identifiers = [
          "arn:aws:iam::${var.aws_account_id}:user/admin"
        ]
      }
      resources = [
        "arn:aws:es:${var.aws_default_region}:${var.aws_account_id}:domain/${var.environment}/*",
      ]
    },
    {
      actions = ["es:ESHttp*"]
      principals {
        type        = "AWS"
        identifiers = [
          "${aws_iam_role.cognito-authenticated.arn}",
        ]
      }
      resources = [
        "arn:aws:es:${var.aws_default_region}:${var.aws_account_id}:domain/${var.environment}/*",
      ]
    }
  ]
}

resource "aws_elasticsearch_domain" "default" {
  domain_name           = "${var.environment}"
  elasticsearch_version = "6.2"
  cluster_config {
    instance_type          = "m4.large.elasticsearch"
    instance_count         = 2
    zone_awareness_enabled = "true"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 20
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = "${data.aws_iam_policy_document.elasticsearch-access.json}"

  snapshot_options {
    automated_snapshot_start_hour = 19
  }

  tags {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
    Year        = "${var.year}"
  }
}
