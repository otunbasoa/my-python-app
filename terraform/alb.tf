module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = "${var.app_name}-${var.environment}-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group rules allowing public HTTP traffic from the internet
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  security_group_egress_rules = {
    all_egress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "python-app-tg"
      }
    }
  }

  target_groups = {
    python-app-tg = {
      backend_protocol              = "HTTP"
      backend_port                  = 8000
      target_type                   = "ip"
      deregistration_delay          = 5
      load_balancing_algorithm_type = "round_robin"

      health_check = {
        enabled             = true
        path                = "/health"
        port                = "8000"
        protocol            = "HTTP"
        matcher             = "200"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 10
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
