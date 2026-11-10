resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_sns_policy" {
  name = "${var.project_name}-lambda-sns"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sns:Subscribe",
        "sns:Publish"
      ]
      Resource = aws_sns_topic.event_topic.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

#Grant Lambda Permissions to Write to DynamoDB
resource "aws_iam_role_policy" "lambda_subscribers_dynamodb_policy" {
  name = "lambda_subscribers_dynamodb_policy"
  role = aws_iam_role.lambda_exec.id # Match your subscribe Lambda role ID

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.subscribers.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_exec.id # Match your existing Lambda execution role resource name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.event_history.arn
      }
    ]
  })
}
