provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"

  user_data     = file("user_data.sh")

  tags = {
    Name = "Instance 1"
  }
}
