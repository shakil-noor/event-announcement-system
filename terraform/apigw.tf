# terraform/apigw.tf
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda Integration: Subscribe
resource "aws_apigatewayv2_integration" "subscribe_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.subscribe.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "subscribe_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /subscribe"
  target    = "integrations/${aws_apigatewayv2_integration.subscribe_integration.id}"
}

resource "aws_lambda_permission" "apigw_subscribe" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/subscribe"
}

# Lambda Integration: Create Event
resource "aws_apigatewayv2_integration" "event_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.create_event.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "event_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /events"
  target    = "integrations/${aws_apigatewayv2_integration.event_integration.id}"
}

resource "aws_lambda_permission" "apigw_event" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_event.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/events"
}
