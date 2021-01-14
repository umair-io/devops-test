data "aws_ami" "ubuntu-20-latest" {
 most_recent = true
 owners = ["099720109477"]
 filter {
   name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20*"]
 }
 filter {
      name   = "architecture"
      values = ["x86_64"]
  }
}

#Ensure that your ssh public access key exists under ~/.ssh/id_rsa.pub
resource "aws_key_pair" "auth" {
  key_name   = var.my_key_pair
  public_key = file("~/.ssh/id_rsa.pub")
}

#SG for EC2 - port 3000
resource "aws_security_group" "asg-sg" {
  name        = "wipro-asg-sg"
  description = "All traffic on port 3000 from alb-sg"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = var.wipro-app-local-port
    to_port     = var.wipro-app-local-port
    protocol    = "TCP"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    # HTTP
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG for LB - port 80
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id = aws_vpc.default.id

  ingress {
    # HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # HTTP
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "wipro-lt" {
  name_prefix   = "wipro-lt"
  image_id      = data.aws_ami.ubuntu-20-latest.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.key_name
  vpc_security_group_ids = [aws_security_group.asg-sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }
  user_data = filebase64("setup.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "wipro-tg" {
  name     = "wipro-tg"
  port     = var.wipro-app-local-port
  protocol = "HTTP"
  vpc_id = aws_vpc.default.id

  health_check {    
    healthy_threshold   = 2   
    unhealthy_threshold = 2    
    timeout             = 5    
    interval            = 6    
    path                = ""    
    port                = var.wipro-app-local-port  
  }
}

resource "aws_autoscaling_group" "wipro-asg" {
  vpc_zone_identifier = [ aws_subnet.az1.id, aws_subnet.az2.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2

  health_check_type    = "ELB"
  target_group_arns = [ aws_alb_target_group.wipro-tg.arn ]
  
  launch_template {
    id      = aws_launch_template.wipro-lt.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

resource "aws_alb" "wipro-alb" {
  name               = "wipro-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.az1.id, aws_subnet.az2.id]
}

resource "aws_alb_listener" "alb-listener" {  
  load_balancer_arn = aws_alb.wipro-alb.arn  
  port              = "80"
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = aws_alb_target_group.wipro-tg.arn
    type             = "forward"  
  }
}

resource "aws_autoscaling_attachment" "wipro-lb-asg-att" {
  alb_target_group_arn   = aws_alb_target_group.wipro-tg.arn
  autoscaling_group_name = aws_autoscaling_group.wipro-asg.id
}
