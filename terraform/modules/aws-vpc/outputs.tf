output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "default_sg_id" {
  value = aws_security_group.default.id
}