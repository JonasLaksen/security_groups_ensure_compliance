data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${var.root}/src"
  output_path = "${var.root}/dist/index.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  filename         = "${var.root}/dist/index.zip"
  role             = aws_iam_role.this.arn
  handler          = "index.handler"
  runtime          = var.runtime
  source_code_hash = data.archive_file.this.output_base64sha256
  depends_on       = [aws_iam_role_policy_attachment.this]
  environment {
    variables = var.environment_variables
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name   = "${var.name}-policy"
  path   = "/"
  policy = var.role_policy
}