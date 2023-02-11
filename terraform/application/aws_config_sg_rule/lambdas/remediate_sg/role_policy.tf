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
        Action   = "ec2:RevokeSecurityGroupIngress",
        Resource = "arn:aws:ec2:*:350321346034:security-group/*"
      },
      {
        Sid      = "VisualEditor1",
        Effect   = "Allow",
        Action   = "ec2:DescribeSecurityGroupRules",
        Resource = "*"
      }
    ]
  })
}