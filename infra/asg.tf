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

resource "aws_launch_template" "wipro-lt" {
  name_prefix   = "wipro-lt"
  image_id      = data.aws_ami.ubuntu-20-latest.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.key_name
}

#create SG for LB - port 80
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    # HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "wipro-asg" {
  availability_zones = ["${var.region}a", "${var.region}b"]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2

  launch_template {
    id      = aws_launch_template.wipro-lt.id
    version = "$Latest"
  }
}