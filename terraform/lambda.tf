# terraform/lambda.tf
data "archive_file" "subscribe_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/subscribe"
  output_path = "${path.module}/subscribe.zip"
}

data "archive_file" "create_event_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/create_event"
  output_path = "${path.module}/create_event.zip"
}

resource "aws_lambda_function" "subscribe" {
  filename         = data.archive_file.subscribe_zip.output_path
  function_name    = "${var.project_name}-subscribe"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.subscribe_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN     = aws_sns_topic.event_topic.arn
      SUBSCRIBERS_TABLE = aws_dynamodb_table.subscribers.name
    }
  }
}

resource "aws_lambda_function" "create_event" {
  filename         = data.archive_file.create_event_zip.output_path
  function_name    = "${var.project_name}-create-event"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.create_event_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_topic.arn
      TABLE_NAME    = aws_dynamodb_table.event_history.name
    }
  }
}
