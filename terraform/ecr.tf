resource "aws_ecr_repository" "node_api" {
  name                 = "serverless-crud-api-terraform"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
output "ecr_repository_url" {
  value = aws_ecr_repository.node_api.repository_url
}
