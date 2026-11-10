resource "aws_dynamodb_table" "subscribers" {
  name         = "subscribers"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name = "SubscribersTable"
  }
}

resource "aws_dynamodb_table" "event_history" {
  name         = "event-history"
  billing_mode = "PAY_PER_REQUEST" # Serverless on-demand pricing
  hash_key     = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }

  tags = {
    Name = "EventHistoryTable"
  }
}
