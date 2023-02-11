locals {
  role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow"
      },
      {
        Effect   = "Allow",
        Action   = "ec2:CreateTags",
        Resource = "arn:aws:ec2:${var.region}:${var.account_id}:security-group/*"
      },
      {
        Effect   = "Allow",
        Action   = "tag:TagResources",
        Resource = "*"
      }
    ]
  })
}