resource "aws_lambda_function" "batch" {
  function_name    = "batch"
  role             = "${data.aws_iam_role.lambda.arn}"
  handler          = "lambda-func/batch.lambda_function.lambda_handler"
  runtime          = "python3.6"
  description      = "run batch instance"
  timeout          = 30
  description      = "run batch instance"
}
