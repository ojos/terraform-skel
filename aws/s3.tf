resource "aws_s3_bucket" "default" {
  bucket = "example"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["Origin", "Authorization", "Accept", "Content-Type"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# resource "aws_s3_bucket_policy" "default" {
#   bucket = "${aws_s3_bucket.default.id}"
#   policy =<<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "*"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::${aws_s3_bucket.default.id}/*"
#         }
#     ]
# }
# POLICY
# }
