///// VPC ///////
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.2.0.0/16"
  tags = {
    Name = "VPC"
  }
}

/////// SUBNET //////
resource "aws_subnet" "my_subnet" {
  count = 3
  vpc_id     = aws_vpc.my_vpc.id
  availability_zone = local.az[count.index]
  cidr_block = "172.2.${count.index}.0/24"
  tags = {
    Name = "Nginx_subnet"
  }
}

///// SECURITY GROUP /////
resource "aws_security_group" "group" {
  
  name   = "Security group"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security group"
  }
}



