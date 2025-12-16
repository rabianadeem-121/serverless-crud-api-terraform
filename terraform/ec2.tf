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
set -e

yum update -y
yum install -y docker unzip jq

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

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

ECR_REPO=${aws_ecr_repository.node_api.repository_url}

# Wait until the Docker image exists in ECR
echo "Waiting for Docker image to exist in ECR..."
until aws ecr describe-images --repository-name $(basename $ECR_REPO) --image-ids imageTag=latest --region ap-south-1; do
  echo "Image not found yet, retrying in 10 seconds..."
  sleep 10
done

# Login to ECR
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin $ECR_REPO

# Pull and run Docker container
docker pull $ECR_REPO:latest || echo "Docker pull failed"
docker run -d \
  -p 3000:3000 \
  --restart unless-stopped \
  --name node-api \
  -e DB_HOST=$DB_HOST \
  -e DB_PORT=$DB_PORT \
  -e DB_USER=$DB_USER \
  -e DB_PASS=$DB_PASS \
  -e DB_NAME=$DB_NAME \
  -e PORT=$PORT \
  $ECR_REPO:latest || echo "Docker run failed"

EOF


  tags = {
    Name = "node-api-server"
  }
}
