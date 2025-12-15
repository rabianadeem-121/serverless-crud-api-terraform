# terraform/security_groups.tf

# Lambda security group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id   # replace with your VPC resource

  # Outbound to anywhere (for now)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rules (if Lambda needs to receive traffic from VPC resources)
  ingress {
    from_port   = 5432        # RDS PostgreSQL port
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]  # allow Lambda → RDS
  }

  tags = {
    Project = "Serverless CRUD API"
  }
}

# RDS security group
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id] # allow Lambda → RDS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "Serverless CRUD API"
  }
}
