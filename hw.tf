# Provider Configuration
provider "aws" {
  region = "us-east-1"
}


# Resource Configuration
resource "aws_instance" "web_server" {
  ami           = "ami-005f9685cb30f234b"
  instance_type = "t2.micro"
  associate_public_ip_address = true

  # Network Configuration
  vpc_security_group_ids = [
    aws_security_group.web.id,
  ]
  subnet_id = aws_subnet.web.id

  # Block Device Configuration
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 1
    volume_type = "gp2"
    delete_on_termination = true
  }

  # User Data Script
  user_data = <<-EOF
              #!/bin/bash
              mkfs -t ext4 /dev/sdb
              mkdir /var/www/html
              echo "Hello GR World" > /var/www/html/index.html
              echo "/dev/sdb /var/www/html ext4 defaults,nofail 0 2" >> /etc/fstab
              mount -a
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              EOF
}

# Security Group Configuration
resource "aws_security_group" "web" {
  name_prefix = "web_sg_"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

# Subnet Configuration
resource "aws_subnet" "web" {
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "web_subnet"
  }
}

# Elastic IP Configuration
resource "aws_eip" "web" {
  vpc = true
}

