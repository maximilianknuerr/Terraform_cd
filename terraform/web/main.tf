terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37"
    }
  }
}

variable "server_port" {
  type = number
  default = 8080
}

provider "aws" {
  region = "eu-central-1"
}


resource "aws_eip" "ip" {
  instance = aws_instance.web_server.id
}

resource "aws_instance" "web_server" {
  ami = "ami-0767046d1677be5a0"
  instance_type = "t3.micro"
  key_name = "fh"
  vpc_security_group_ids = [aws_security_group.web_server.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup ruby /home/ubuntu/app.rb ${var.server_port} ${aws_elasticache_cluster.redis.cache_nodes[0].address}
              EOF
}


resource "aws_security_group" "web_server" {
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "server" {
  length  = 8
  special = false
  number  = false
  upper   = false
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id = random_string.server.result
  node_type  = "cache.t2.micro"

  engine               = "redis"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.4"
  security_group_ids   = [aws_security_group.redis.id]
}

resource "aws_security_group" "redis" {
  ingress {
    protocol                 = "tcp"
    from_port                = 6379
    to_port                  = 6379
    security_groups = [aws_security_group.web_server.id]
  }
}

output "ip" {
  value = aws_eip.ip.public_ip
}

data "aws_ami" "my_ami"{
    most_recent = true
    owners = ["self"]
    filter{
        name = "name"
        values = ["my_base_image-*"]
    }
}

output "ami"{
    value = data.aws_ami.my_ami.arn
}