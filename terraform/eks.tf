resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    # Ноды в приватных подсетях
    subnet_ids = aws_subnet.private[*].id

    # API server доступен публично — для kubectl с локальной машины
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Кластер создаётся только после того как IAM роль и политики готовы
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  # Ноды запускаются в приватных подсетях
  subnet_ids = aws_subnet.private[*].id

  instance_types = [var.node_instance_type]
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_capacity
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Аналог updateConfig.maxUnavailable: 1 в eksctl
  # При обновлении — не более 1 ноды выходит из строя одновременно
  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read,
  ]

  tags = {
    Name = "${var.cluster_name}-workers"
  }
}