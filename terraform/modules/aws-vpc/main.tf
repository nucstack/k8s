resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = {
    Name        = "${var.environment}-vpc"
    environment = var.environment
  }
}

resource "aws_flow_log" "flow_log" {
  iam_role_arn    = "arn"
  log_destination = "log"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}
