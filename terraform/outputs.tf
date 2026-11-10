output "cloudfront_domain" {
  description = "Cloud Front Domain name"
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
}

output "api_gateway_url" {
  description = "API gateway url"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "s3_bucket_name" {
  description = "The name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}
