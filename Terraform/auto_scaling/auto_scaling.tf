//// LAUNCH TEMPLATE ////
resource "aws_launch_template" "foobar" {

  name_prefix   = "Web-server"
  image_id      = local.versions[var.ami_version]
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.group.id}"]
  }

}

#Auto Scaling Group
resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "autoscalingGroup"
  load_balancers            = [aws_elb.elb.name]

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "${aws_launch_template.foobar.latest_version}"
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