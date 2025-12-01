resource "aws_dynamodb_table" "labels" {
  name         = "ImageLabels"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "image_name"

  attribute {
    name = "image_name"
    type = "S"
  }
}
