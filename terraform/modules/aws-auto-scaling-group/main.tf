
data "aws_ami" "image" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.image_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["self"]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// ssh key pair
resource "aws_key_pair" "ssh-key-pair" {
  key_name   = "${var.application_name}-${var.environment}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

// bootstrap script
data "template_file" "bootstrap-script" {  
  template = file("${path.module}/scripts/bootstrap-${var.application_name}.sh.tmpl")
  vars = var.bootstrap_vars
}

// instance launch template
resource "aws_launch_template" "instance-template" {
  name_prefix   = var.application_name
  image_id      = data.aws_ami.image.id
  instance_type = var.instance_type
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }
  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = var.subnet_id
    security_groups             = [aws_autoscaling_group.auto-scaling-group.id]
  }
  key_name = aws_key_pair.ssh-key-pair.key_name
  user_data = base64encode(data.template_file.bootstrap-script.rendered)

  tag_specifications {
    resource_type = "instance"
    tags                 = {
      Name             = "${var.application_name}-instance-template"      
    }
  }
}

// auto scaling group for k3s instances
resource "aws_autoscaling_group" "auto-scaling-group" {
  name               = var.application_name
  availability_zones = var.availability_zones
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size

  launch_template {
    id      = aws_launch_template.instance-template.id
    version = "$Latest"
  }
  tags = [
    {
      "key" = "application_name"
      "value" = var.application_name
      "propagate_at_launch" = true
    },
    {
      "key" = "environment"
      "value" = var.environment
      "propagate_at_launch" = true
    }        
  ]
}

resource "aws_security_group" "default" {
  name        = "${var.environment}-default-security-group"
  description = "Default security group to allow inbound/outbound from the VPC"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags                 = {
    Name        = "${var.environment}-default-sg"
    environment = var.environment
  }
}
