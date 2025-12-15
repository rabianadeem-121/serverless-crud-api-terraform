resource "aws_ecr_repository" "api" {
  name = "serverless-crud-api-terraform"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Project = "Serverless CRUD API"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api.repository_url
}
