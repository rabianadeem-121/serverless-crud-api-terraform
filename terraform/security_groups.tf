# Lambda Security Group
resource "aws_security_group" "lambda_sg1" {
  name   = "lambda-sg1"
  vpc_id = aws_vpc.main.id

  description = "SG for Lambda"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg1" {
  name   = "rds-sg1"
  vpc_id = aws_vpc.main.id

  description = "SG for RDS"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg1.id]  # Only RDS references Lambda SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
