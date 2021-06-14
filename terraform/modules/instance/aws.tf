
data "aws_ami" "k3s-image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["k3s-*"]
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

resource "aws_key_pair" "ssh-key" {
  key_name   = var.name
  public_key = var.ssh_authorized_key != "" ? var.ssh_authorized_key : tls_private_key.ssh_key.public_key_openssh
}

data "template_file" "bootstrap" {
  template = file("${path.module}/scripts/k3s-bootstrap.sh.tmpl")
  vars = {
    TAILSCALE_AUTH_KEY = var.tailscale_auth_key
  }
}

resource "aws_security_group" "ssh" {
  name   = "allow-ssh"
  description = "Allow TLS inbound traffic"  
  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }
  egress {
    description      = "All egress access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_launch_template" "k3s" {
  name_prefix   = var.name
  image_id      = data.aws_ami.k3s-image.id
  instance_type = "t2.micro"
  instance_market_options {
    market_type = "spot"
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.ssh.id
    ]
  }
  key_name = aws_key_pair.ssh-key.key_name
  user_data = base64encode(data.template_file.bootstrap.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
}

resource "aws_autoscaling_group" "k3s" {
  name               = var.name
  availability_zones = ["us-east-2a"]
  desired_capacity   = length(var.instances)
  max_size           = length(var.instances)
  min_size           = 1

  launch_template {
    id      = aws_launch_template.k3s.id
    version = "$Latest"
  }
}