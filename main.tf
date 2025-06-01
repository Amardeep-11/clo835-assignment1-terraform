resource "aws_instance" "app_instance" {
  ami                    = "ami-051f7e7f6c2f40dc1" # Amazon Linux 2 in us-east-1
  instance_type          = "t2.micro"
  key_name               = "clo835-key"

  # Get a default public subnet in default VPC
  subnet_id              = data.aws_subnet.default_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -aG docker ec2-user
              chkconfig docker on
              EOF

  tags = {
    Name = "clo835-app-ec2"
  }
}

# Allow all traffic (insecure, but works for now)
resource "aws_security_group" "allow_all" {
  name        = "clo835-allow-all"
  description = "Allow all traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get default subnet (filter by AZ)
data "aws_subnet" "default_subnet" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}

    