output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "api_url" {
  value = "http://${aws_instance.api_server.public_ip}:3000/users"
}
