resource "aws_lambda_function" "crud_api" {
  function_name = "node-crud-api"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = aws_ecr_repository.api.repository_url  # ← Terraform ECR repo

  timeout = 30
  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.postgres.address
      DB_USER     = "admin"
      DB_PASSWORD = var.db_password
      DB_NAME     = "cruddb"
    }
  }
}

