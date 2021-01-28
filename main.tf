terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = "= 0.13.4"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.25.0"
    }
  }
}

###
# Security Groups
###

resource "aws_security_group" "elb_in" {
  name      = var.app_name
  description = "Allow specified traffic ingress to ELB"

  #tags = local.tag_list

  dynamic "ingress" {
    for_each = var.elb_ports_in
    content {
      from_port   = ingress.port
      to_port     = ingress.port
      cidr_blocks = ingress.prefix
      protocol    = ingress.protocol
    }
  }

}

resource "aws_security_group" "elb_out" {
  name      = var.app_name
  description = "Allow specified traffic egress from ELB"

  #tags = local.tag_list

    dynamic "egress" {
    for_each = var.elb_ports_out
    content {
      from_port   = egress.port
      to_port     = egress.port
      cidr_blocks = egress.prefix
      protocol    = egress.protocol
    }
  }

}

resource "aws_security_group" "backend_in" {
  name      = var.app_name
  description = "Allow specified trffic ingress to Backend"

  #tags = local.tag_list

  dynamic "ingress" {
    for_each = var.backend_ports_in
    content {
      from_port   = ingress.port
      to_port     = ingress.port
      cidr_blocks = ingress.prefix
      protocol    = ingress.protocol
    }
  }

}

resource "aws_security_group" "backend_out" {
  name      = var.app_name
  description = "Allow specified trffic egress from Backend"

  #tags = local.tag_list

  dynamic "egress" {
    for_each = var.backend_ports_out
    content {
      from_port   = egress.port
      to_port     = egress.port
      cidr_blocks = egress.prefix
      protocol    = egress.protocol
    }
  }
}

###
# Extra Security Group Rules
###

## Ingress to Backend
# SSH
resource "aws_security_group_rule" "allow-ssh" {
  
  count = var.enable_ssh ? 1 : 0
  type = "ingress"
  from_port = var.enable_ssh_port
  to_port = var.enable_ssh_port
  protocol = "tcp"
  cidr_blocks = [ var.enable_ssh_prefix ]

  security_group_id = aws_security_group.backend_in.id
}


###
# Autoscale Group
###

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  
  name = var.app_name

  # Launch configuration
  lc_name = var.app_name

  image_id        = data.aws_ami.this.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.backend_in,aws_security_group.backend_out]

  # Auto scaling group
  asg_name                  = var.app_name
  vpc_zone_identifier       = data.aws_subnet_ids.private.ids
  health_check_type         = "ELB"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_size
  wait_for_capacity_timeout = 0
  
  #tags = local.tag_list

}

######
# ELB
######
module "elb" {
  source = "terraform-aws-modules/elb/aws"
  version = "~> 2.4.0"

  name = var.app_name

  subnets         = data.aws_subnet_ids.public.ids
  security_groups = [aws_security_group.elb_in,aws_security_group.elb_out]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = local.tag_list
  
}