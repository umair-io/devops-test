#Required iam role to give ec2 instances access to s3 bucket which holds code
resource "aws_iam_role" "ec2-s3-access-role" {
  name               = "s3-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "profile" {      
  name  = "instance-profile"                         
  role = aws_iam_role.ec2-s3-access-role.name
}

resource "aws_iam_role_policy" "s3-admin-access-policy" {
  name = "s3-admin-access-policy"
  role = aws_iam_role.ec2-s3-access-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}