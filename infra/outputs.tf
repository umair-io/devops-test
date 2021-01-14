output "lb-address" {
  value = aws_alb.wipro-alb.dns_name
}