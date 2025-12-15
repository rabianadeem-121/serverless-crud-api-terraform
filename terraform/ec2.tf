// ...existing code...
variable "key_name" {
  description = "Name of the EC2 key pair to attach to the instance (must exist in the AWS region)"
  type        = string
}

resource "aws_instance" "api_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name
  key_name = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    aws ecr get-login-password --region ap-south-1 \
      | docker login --username AWS --password-stdin ${aws_ecr_repository.node_api.repository_url}

    docker pull ${aws_ecr_repository.node_api.repository_url}:latest

    docker run -d \
      -p 3000:3000 \
      --name node-api \
      ${aws_ecr_repository.node_api.repository_url}:latest
  EOF

  tags = {
    Name = "node-api-server"
  }
}
