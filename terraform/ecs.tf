locals {
  container_image = var.container_image != "" ? var.container_image : "${data.aws_ecr_repository.app.repository_url}:latest"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.app_name}-${var.environment}-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    python-service = {
      desired_count = 2
      cpu           = 256
      memory        = 512

      create_task_exec_iam_role = true
      create_tasks_iam_role     = true

      container_definitions = {
        python-container = {
          cpu                      = 256
          memory                   = 512
          essential                = true
          image                    = local.container_image
          readonly_root_filesystem = true

          enable_cloudwatch_logging = true
          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "/ecs/${var.app_name}-${var.environment}"
              awslogs-region        = var.aws_region
              awslogs-stream-prefix = "python-container"
            }
          }

          health_check = {
            command      = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)\""]
            interval     = 30
            timeout      = 5
            retries      = 3
            start_period = 30
          }

          environment = [
            {
              name  = "ALLOWED_ORIGINS"
              value = ""
            }
          ]

          port_mappings = [
            {
              name          = "app"
              containerPort = 8000
              hostPort      = 8000
              protocol      = "tcp"
            }
          ]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["python-app-tg"].arn
          container_name   = "python-container"
          container_port   = 8000
        }
      }

      subnet_ids = module.vpc.private_subnets

      security_group_rules = {
        ingress_alb = {
          type                     = "ingress"
          from_port                = 8000
          to_port                  = 8000
          protocol                 = "tcp"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
