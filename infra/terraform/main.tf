resource "aws_vpc" "tatiana_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tatiana-vpc"
  }
}

resource "aws_subnet" "tatiana_subnet_public" {
  vpc_id                  = aws_vpc.tatiana_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "tatiana-public-subnet"
  }
}

resource "aws_security_group" "tatiana_sg" {
  name        = "tatiana-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.tatiana_vpc.id

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
