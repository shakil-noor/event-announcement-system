#!/bin/bash

# Exit immediately if a command exits with a non-zero status (stops script on errors)
set -e

echo "🚀 Starting frontend deployment..."

# 1. Automatically fetch the S3 bucket name and API Gateway URL from Terraform
cd terraform
S3_BUCKET=$(terraform output -raw s3_bucket_name)
API_URL=$(terraform output -raw api_gateway_url)
CLOUDFRONT_DIST_ID=$(terraform output -raw cloudfront_distribution_id)
cd ..

FRONTEND_DIR="./frontend"

# 2. Inject the live API URL into frontend/app.js
echo "==> Injecting API URL into frontend..."
sed -i.bak "s|YOUR_API_GATEWAY_URL|$API_URL|g" "$FRONTEND_DIR/app.js"
rm -f "$FRONTEND_DIR/app.js.bak"

# 3. Sync files to S3
echo "📦 Syncing files to S3 bucket ($S3_BUCKET)..."
aws s3 sync "$FRONTEND_DIR" "s3://$S3_BUCKET" --delete

# 4. Invalidate CloudFront cache
echo "🔄 Invalidating CloudFront cache ($CLOUDFRONT_DIST_ID)..."
aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DIST_ID" \
    --paths "/*"
    
echo "✨ Deployment completed successfully!"