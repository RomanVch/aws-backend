resource "aws_ecr_repository" "backend" {
  name                 = "devops-backend-api"
  image_tag_mutability = "MUTABLE"  # позволяет перезаписывать тег latest

  image_scanning_configuration {
    scan_on_push = true  # ECR сканирует образы на CVE при каждом push
  }

  tags = {
    Name = "devops-backend-api"
  }
}