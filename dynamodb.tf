#--------------------------------------------------------------
# Log table
#--------------------------------------------------------------
resource "aws_dynamodb_table" "log_table" {
  name           = format("%s_%s", var.object_prefix, "google_log_table")
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "task_id"
  range_key      = "task_ts"

  attribute {
    name = "task_id"
    type = "S"
  }

  attribute {
    name = "task_ts"
    type = "S"
  }

}
