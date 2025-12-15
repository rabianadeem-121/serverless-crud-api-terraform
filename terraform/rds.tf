resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}


resource "aws_db_instance" "postgres" {
  identifier              = "node-api-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.t3.micro"
  db_name                    = "mydb"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
}
