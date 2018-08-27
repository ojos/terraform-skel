resource "aws_cognito_user_pool" "default" {
  name = "${var.environment}"

  # auto_verified_attributes = ["email"]
  mfa_configuration        = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = true
    unused_account_validity_days = 90
    invite_message_template {
      email_subject = " ${var.project} ${var.environment} 環境 Kibanaの仮パスワード"
      email_message = " ユーザー名は {username}、仮パスワードは {####} です。"
      sms_message   = " ユーザー名は {username}、仮パスワードは {####} です。"
    }
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = false
  }

  schema {
    name                     = "email"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    attribute_data_type      = "String"
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  tags {
    Name        = "${var.environment}"
    Environment = "${var.environment}"
    Year        = "${var.year}"
  }
}

resource "aws_cognito_user_pool_domain" "default" {
  domain = "${var.environment}"
  user_pool_id = "${aws_cognito_user_pool.default.id}"
}

# cognito管理画面から設定した aws_cognito_user_pool_client が import 後に
# 同じ値で設定しても置き換えが発生するためesでログインができなくなるのでコメントアウト
# resource "aws_cognito_user_pool_client" "default" {
#   # name         = "AWSElastic${element(split(".", "${aws_elasticsearch_domain.default.endpoint}"), 0)}"
#   # name         = "${var.year}-${var.environment}"
#   # name         = "AWSElasticsearch-${var.environment}-${var.aws_default_region}-${local.es_id}"
#   name         = "AWSElasticsearch-current-2018-ap-northeast-1-vgwitvg2jqyw2ju6ouanacrbb4"
#   user_pool_id = "${aws_cognito_user_pool.default.id}"
#
#   allowed_oauth_flows = ["code"]
#   allowed_oauth_flows_user_pool_client = true
#
#   allowed_oauth_scopes = [
#     "openid",
#     "email"
#   ]
#
#   callback_urls = ["https://${aws_elasticsearch_domain.default.kibana_endpoint}app/kibana"]
#   logout_urls   = ["https://${aws_elasticsearch_domain.default.kibana_endpoint}app/kibana"]
#
#   supported_identity_providers = ["COGNITO"]
# }

# 上記 aws_cognito_user_pool_client がうまくいかないので直接ID設定（上記改善し次第こちらは破棄）
# variable "cognito_user_pool_client_id" {
#     default = "xxx"
# }

resource "aws_cognito_identity_pool" "default" {
  identity_pool_name               = "${var.environment} ${var.year}"
  allow_unauthenticated_identities = false

  # cognito_identity_providers {
  #   client_id               = "${var.cognito_user_pool_client_id}"
  #   provider_name           = "cognito-idp.${var.aws_default_region}.amazonaws.com/${aws_cognito_user_pool.default.id}"
  #   server_side_token_check = true
  # }
}

data "aws_iam_policy_document" "cognito-authenticated" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition = [
      {
        test     = "StringEquals"
        variable = "cognito-identity.amazonaws.com:aud"
        values = [
          "${aws_cognito_identity_pool.default.id}"
        ]
      },
      {
        test     = "ForAnyValue:StringLike"
        variable = "cognito-identity.amazonaws.com:amr"
        values = [
          "authenticated"
        ]
      }
    ]
  }
}

resource "aws_iam_role" "cognito-authenticated" {
  name               = "${var.environment}-cognito-authenticated"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.cognito-authenticated.json}"
}

data "aws_iam_policy_document" "cognito-unauthenticated" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition = [
      {
        test     = "StringEquals"
        variable = "cognito-identity.amazonaws.com:aud"
        values = [
          "${aws_cognito_identity_pool.default.id}"
        ]
      },
      {
        test     = "ForAnyValue:StringLike"
        variable = "cognito-identity.amazonaws.com:amr"
        values = [
          "unauthenticated"
        ]
      }
    ]
  }
}

resource "aws_iam_role" "cognito-unauthenticated" {
  name               = "${var.environment}-cognito-unauthenticated"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.cognito-unauthenticated.json}"
}

resource "aws_cognito_identity_pool_roles_attachment" "default" {
  identity_pool_id = "${aws_cognito_identity_pool.default.id}"

  roles {
    "authenticated" = "${aws_iam_role.cognito-authenticated.arn}"
    "unauthenticated" = "${aws_iam_role.cognito-unauthenticated.arn}"
  }
}
