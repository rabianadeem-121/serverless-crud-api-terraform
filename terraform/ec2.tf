resource "aws_instance" "api_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name
  key_name = var.key_name

  # <-- THIS IS WHERE THE EC2 CONNECTS TO RDS VIA USER DATA
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Environment variables for RDS
    export DB_HOST=${aws_db_instance.postgres.address}
    export DB_PORT=5432
    export DB_USER=${var.db_username}
    export DB_PASS=${var.db_password}
    export DB_NAME=mydb
    export PORT=3000

    # Login to ECR and run Docker container
    aws ecr get-login-password --region ap-south-1 \
      | docker login --username AWS --password-stdin ${aws_ecr_repository.node_api.repository_url}

    docker pull ${aws_ecr_repository.node_api.repository_url}:latest
    docker run -d \
      -p 3000:3000 \
      --name node-api \
      -e DB_HOST=$DB_HOST \
      -e DB_PORT=$DB_PORT \
      -e DB_USER=$DB_USER \
      -e DB_PASS=$DB_PASS \
      -e DB_NAME=$DB_NAME \
      -e PORT=$PORT \
      ${aws_ecr_repository.node_api.repository_url}:latest
  EOF

  tags = {
    Name = "node-api-server"
  }
}
