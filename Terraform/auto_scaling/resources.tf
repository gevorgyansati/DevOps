locals {
    az = [
        "eu-central-1a",
        "eu-central-1b",
        "eu-central-1c"
    ]

    versions = {
        "v1" = "ami-0bfd16de7506e3880",
        "v2" = "ami-00cb23038b52783a2"
    }

}

variable "ami_version" {
  description = "Version:"
validation {
  condition = var.ami_version == "v1" || var.ami_version == "v2"
  error_message = "Unknown key !!! <3."
}
}

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

//// ROUTE TABLE /////
resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Route"
  }
}

resource "aws_route_table_association" "rt_ass" {
  count = 3
  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.my_route.id
}

///// IGW //////
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Nginx_igw"
  }
}

//// LOAD BALANCER /////

resource "aws_elb" "elb" {
  name               = "terraform-elb"
  security_groups = [aws_security_group.group.id]
  subnets = aws_subnet.my_subnet[*].id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}

#Auto Scaling Group
resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "autoscalingGroup"
  load_balancers            = [aws_elb.elb.name]

  launch_template {
    id      = aws_launch_template.foobar.id
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = [""]
  }

  vpc_zone_identifier       = [for i in aws_subnet.my_subnet : i.id]
  min_size                  = 1
  max_size                  = 6
  desired_capacity          = 2
  health_check_grace_period = 120
  health_check_type         = "EC2"
}

#Auto Scaling Policy Scale UP
resource "aws_autoscaling_policy" "autoscaling_policy_scaleup" {
  name                   = "autoscalingPolicyScaleUp"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 10
  policy_type            = "SimpleScaling"
}

#CPU metrics Up
resource "aws_cloudwatch_metric_alarm" "cpu_metric_scaleup" {
  alarm_name          = "cpuUpThreshold"
  threshold           = 50
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average" 
  metric_name         = "CPUUtilization"
  evaluation_periods  = 2 

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.autoscaling_policy_scaleup.arn]
}

#Auto Scaling Policy Scale DOWN
resource "aws_autoscaling_policy" "autoscaling_policy_scaledown" {
  name                   = "autoscalingPolicyScaleDown"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 10
  policy_type            = "SimpleScaling"
}

#CPU metrics Down
resource "aws_cloudwatch_metric_alarm" "cpu_metric_scaledown" {
  alarm_name          = "cpuUpThreshold"
  threshold           = 50
  comparison_operator = "LessThanThreshold"
  namespace           = "AWS/EC2"
  period              = 60        
  statistic           = "Average" 
  metric_name         = "CPUUtilization"
  evaluation_periods  = 2

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.autoscaling_policy_scaledown.arn]
}

//// LAUNCH TEMPLATE ////
resource "aws_launch_template" "foobar" {

  name_prefix   = "Web-server"
  image_id      = local.versions[var.ami_version]
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
  }
  vpc_security_group_ids = [aws_security_group.group.id]
}