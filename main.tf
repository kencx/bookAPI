terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.14.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = var.ec2_key_name
}

resource "aws_db_instance" "postgres" {
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = "db.t3.micro"

  db_name  = "postgres"
  username = "postgres"
  password = "postgres"

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.private.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [aws_subnet.private.id, aws_subnet.rds1.id]
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "rds1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr_block_secondary
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    gateway_id = aws_nat_gateway.nat.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table" "custom_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    gateway_id = aws_internet_gateway.ig.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.custom_route_table.id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_security_group" "public" {
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.public_ingress_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # ingress {
  #   protocol        = "ICMP"
  #   from_port       = 0
  #   to_port         = 0
  #   security_groups = ["0.0.0.0/0"]
  # }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "db_ingress_sg" {
  security_group_id        = aws_security_group.private.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = aws_db_instance.postgres.port
  to_port                  = aws_db_instance.postgres.port
  source_security_group_id = aws_security_group.public.id
}

# resource "aws_key_pair" "generated_key" {
#   key_name   = "test_key"
#   public_key = tls_private_key.key.public_key_openssh
#
#   provisioner "local-exec" {
#     command = <<-EOF
# 		echo "${tls_private_key.key.private_key_pem}" > ./test_key.pem
# 		chmod 400 ./test_key.pem
# 	EOF
#   }
# }
#
# resource "tls_private_key" "key" {
#   algorithm = "ED25519"
# }
