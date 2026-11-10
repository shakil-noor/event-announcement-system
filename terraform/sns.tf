# terraform/sns.tf
resource "aws_sns_topic" "event_topic" {
  name = "${var.project_name}-topic"
}
