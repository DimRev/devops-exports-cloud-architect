provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "dokuwiki-sg" {
  name        = "dokuwiki-sg"
  description = "Allow HTTP from anywhere"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_security_group" "default" {
  name = "default"
  vpc_id = "vpc-06b54d8a01d6a5a48"
}

resource "aws_launch_template" "dokuwiki_lt" {
  name_prefix   = "dokuwiki-"
  image_id      = "ami-05b10e08d247fb927"  # Amazon Linux with free tier
  instance_type = "t2.micro"

  user_data = base64encode(<<EOF
#!/usr/bin/bash
yum install docker -y
systemctl enable docker
systemctl start docker
docker run -d -p 80:80 --name dokuwiki bitnami/dokuwiki:latest
EOF
  )

  vpc_security_group_ids = [
    aws_security_group.dokuwiki-sg.id,
    data.aws_security_group.default.id
  ]
}


resource "aws_autoscaling_group" "dokuwiki-asg" {
  name              = "dokuwiki-asg"
  max_size          = 1
  min_size          = 1
  desired_capacity  = 1

  launch_template {
    id      = aws_launch_template.dokuwiki_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    "subnet-0fee188b2c81f6f68"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "dokuwiki-asg"
    propagate_at_launch = true
  }
}

