resource "aws_db_subnet_group" "main" {
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "postgres" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "cruddb"
  username = "admin"
  password = var.db_password

  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}
