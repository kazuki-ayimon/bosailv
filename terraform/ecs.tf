####################################################
# ECS Cluster
####################################################

resource "aws_ecs_cluster" "this" {
  name               = "${local.app_name}-app-cluster"
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

####################################################
# ECS IAM Role
####################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

resource "aws_iam_role_policy" "kms_decrypt_policy" {
  name = "${local.app_name}_ecs_task_execution_role_policy_kms"
  role               = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt"
        ],
        "Resource": [
          data.aws_ssm_parameter.database_password.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_scheduled_tasks_role" {
  name               = "${local.app_name}_ecs_scheduled_tasks_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_scheduled_tasks_role_attach" {
  role       = aws_iam_role.ecs_scheduled_tasks_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

####################################################
# ECS Task Container Log Groups
####################################################

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.app_name}/frontend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "backend_middleware" {
  name              = "/ecs/${local.app_name}/backend/middleware"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "backend_app" {
  name              = "/ecs/${local.app_name}/backend/app"
  retention_in_days = 30
}

####################################################
# ECR data source
####################################################

locals {
  ecr_frontend_repository_name           = "bosailv-frontend"
  ecr_backend_middleware_repository_name = "bosailv-backend-nginx"
  ecr_backend_app_repository_name        = "bosailv-backend-rails"
}

#todo refactor
data "external" "ecr_image_frontend_newest" {
  program = [
    "aws", "ecr", "describe-images",
    "--repository-name", local.ecr_frontend_repository_name,
    "--query", "{\"tags\": to_string(sort_by(imageDetails,& imagePushedAt)[-1].imageTags)}",
  ]
}

locals {
  ecr_frontend_repository_newest_tags = jsondecode(data.external.ecr_image_frontend_newest.result.tags)
}

data "external" "ecr_image_backend_middleware_newest" {
  program = [
    "aws", "ecr", "describe-images",
    "--repository-name", local.ecr_backend_middleware_repository_name,
    "--query", "{\"tags\": to_string(sort_by(imageDetails,& imagePushedAt)[-1].imageTags)}",
  ]
}

locals {
  ecr_backend_middleware_repository_newest_tags = jsondecode(data.external.ecr_image_backend_middleware_newest.result.tags)
}

data "external" "ecr_image_backend_app_newest" {
  program = [
    "aws", "ecr", "describe-images",
    "--repository-name", local.ecr_backend_app_repository_name,
    "--query", "{\"tags\": to_string(sort_by(imageDetails,& imagePushedAt)[-1].imageTags)}",
  ]
}

locals {
  ecr_backend_app_repository_newest_tags = jsondecode(data.external.ecr_image_backend_app_newest.result.tags)
}


data "aws_ecr_repository" "frontend" {
  name = local.ecr_frontend_repository_name
}

data "aws_ecr_repository" "backend_middleware" {
  name = local.ecr_backend_middleware_repository_name
}

data "aws_ecr_repository" "backend_app" {
  name = local.ecr_backend_app_repository_name
}

####################################################
# ECS Task Definition
####################################################

locals {
  frontend_task_name = "${local.app_name}-app-task-frontend"
  backend_task_name = "${local.app_name}-app-task-backend"
  frontend_task_container_name = "${local.app_name}-app-container-frontend"
  backend_task_middleware_container_name = "${local.app_name}-app-container-nginx-backend"
  backend_task_app_container_name = "${local.app_name}-app-container-rails-backend"
}

data "aws_ssm_parameter" "app_env" {
  name = "${local.ssm_parameter_store_base}/app_env"
}

data "aws_ssm_parameter" "app_key" {
  name = "${local.ssm_parameter_store_base}/app_key"
}

data "aws_ssm_parameter" "google_api_key" {
  name = "${local.ssm_parameter_store_base}/google_api_key"
}

data "aws_ssm_parameter" "aws_access_key" {
  name = "${local.ssm_parameter_store_base}/aws_access_key"
}

data "aws_ssm_parameter" "aws_secret_key" {
  name = "${local.ssm_parameter_store_base}/aws_secret_key"
}

data "aws_ssm_parameter" "gmail_account_password" {
  name = "${local.ssm_parameter_store_base}/gmail_account_password"
}

data "aws_ssm_parameter" "guest_user_password" {
  name = "${local.ssm_parameter_store_base}/guest_user_password"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = local.frontend_task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = local.frontend_task_container_name
      image            = "${data.aws_ecr_repository.frontend.repository_url}:${local.ecr_frontend_repository_newest_tags[0]}"
      portMappings     = [{ containerPort : 3000 }]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.frontend.name
          awslogs-stream-prefix : "ecs"
        }
      }
      secrets = [
        {
          name: "GOOGLE_API_KEY"
          valueFrom: data.aws_ssm_parameter.google_api_key.arn
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = local.backend_task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = local.backend_task_middleware_container_name
      image            = "${data.aws_ecr_repository.backend_middleware.repository_url}:${local.ecr_backend_middleware_repository_newest_tags[0]}"
      portMappings     = [{ containerPort : 80 }]
      volumesFrom = [{
        sourceContainer: local.backend_task_app_container_name
        readOnly: null
      }]
      dependsOn = [{
        containerName: local.backend_task_app_container_name
        condition: "START"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.backend_middleware.name
          awslogs-stream-prefix : "ecs"
        }
      }
    },
    {
      name             = local.backend_task_app_container_name
      image            = "${data.aws_ecr_repository.backend_app.repository_url}:${local.ecr_backend_app_repository_newest_tags[0]}"
      secrets = [
        {
          name: "APP_ENV"
          valueFrom: data.aws_ssm_parameter.app_env.arn
        },
        {
          name: "SECRET_KEY_BASE"
          valueFrom: data.aws_ssm_parameter.app_key.arn
        },
        {
          name: "DB_DATABASE"
          valueFrom: data.aws_ssm_parameter.database_name.arn
        },
        {
          name: "DB_USERNAME"
          valueFrom: data.aws_ssm_parameter.database_user.arn
        },
        {
          name: "DB_PASSWORD"
          valueFrom: data.aws_ssm_parameter.database_password.arn
        },
        {
          name: "DB_HOST"
          valueFrom: aws_ssm_parameter.database_url.arn
        },
        {
          name: "AWS_ACCESS_KEY_ID"
          valueFrom: data.aws_ssm_parameter.aws_access_key.arn
        },
        {
          name: "AWS_SECRET_ACCESS_KEY"
          valueFrom: data.aws_ssm_parameter.aws_secret_key.arn
        },
        {
          name: "GMAIL_ACCOUNT_PASSWORD"
          valueFrom: data.aws_ssm_parameter.gmail_account_password.arn
        },
        {
          name: "GUEST_USER_PASSWORD"
          valueFrom: data.aws_ssm_parameter.guest_user_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.backend_app.name
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])
}

####################################################
# ECS CloudWatch Event Target
####################################################

resource "aws_cloudwatch_event_rule" "guest_user_destroy_schedule" {
  name                = "${local.app_name}_guest_user_destroy_schedule"
  schedule_expression = "cron(0 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "guest_user_destroy" {
  target_id = "${local.app_name}_guest_user_destroy_schedule"
  rule      = aws_cloudwatch_event_rule.guest_user_destroy_schedule.name
  arn       = aws_ecs_cluster.this.arn
  role_arn  = aws_iam_role.ecs_scheduled_tasks_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.backend.arn

    network_configuration {
      assign_public_ip = true
      subnets          = [
        aws_subnet.public_1c.id
      ]
      security_groups = [
        aws_security_group.app.id
      ]
    }
  }
  input = <<DOCUMENT
{
  "containerOverrides": [
    {
      "name": "${local.backend_task_app_container_name}",
      "command": ["bundle", "exec", "rails", "user:destroy", "RAILS_ENV=production", "--trace"]
    }
  ]
}
DOCUMENT
}

####################################################
# ECS Cluster Service
####################################################

resource "aws_ecs_service" "frontend" {
  name                               = "${local.app_name}-frontend"
  cluster                            = aws_ecs_cluster.this.id
  platform_version                   = "LATEST"
  task_definition                    = aws_ecs_task_definition.frontend.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "SERVICE"
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 60
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    assign_public_ip = true
    subnets          = [
      aws_subnet.public_1a.id,
    ]
    security_groups = [
      aws_security_group.app.id,
    ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = local.frontend_task_container_name
    container_port   = 3000
  }
}

resource "aws_lb_target_group" "frontend" {
  name                 = "${local.app_name}-service-tg-frontend"
  vpc_id               = aws_vpc.this.id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  health_check { path = "/" }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  condition {
    host_header {
      values = [local.app_domain_name]
    }
  }
}

resource "aws_ecs_service" "backend" {
  name                               = "${local.app_name}-backend"
  cluster                            = aws_ecs_cluster.this.id
  platform_version                   = "LATEST"
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "SERVICE"
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 60
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    assign_public_ip = true
    subnets          = [
      aws_subnet.public_1c.id,
    ]
    security_groups = [
      aws_security_group.app.id,
    ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = local.backend_task_middleware_container_name
    container_port   = 80
  }
}

resource "aws_lb_target_group" "backend" {
  name                 = "${local.app_name}-service-tg-backend"
  vpc_id               = aws_vpc.this.id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  health_check { path = "/api/health_check" }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    host_header {
      values = [local.api_domain_name]
    }
  }
}

resource "aws_lb_listener_rule" "maintenance" {
  listener_arn = aws_lb_listener.https.arn
  priority = 100
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = local.maintenance_body
      status_code = "503"
    }
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
