provider "aws" {
  region = "us-east-2"
}

variable "name" {}
variable "vpc_id" {
  default = "vpc-0ce7889ae8fafd3f6"
}
locals {
  tags = {
    Name            = var.name
    node_group_name = "${var.name}-ng1"
  }
  node_group_name = "${var.name}-ng1"
}

data "aws_security_group" "sg" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["kul"]
  }
}

module "create_subnet" {
  source         = "kmayer10/create_subnet/aws"
  version        = "1.0.0"
  name           = var.name
  vpc_id         = var.vpc_id
  subnet_type    = "public"
  subnet_counter = "10"
}

resource "aws_eks_cluster" "cluster" {
  name     = var.name
  version  = "1.25"
  role_arn = "arn:aws:iam::554660509057:role/kul-eksClusterRole"
  tags     = local.tags
  vpc_config {
    subnet_ids             = module.create_subnet.subnet_ids
    security_group_ids     = [data.aws_security_group.sg.id]
    endpoint_public_access = true
  }
}

resource "aws_eks_node_group" "linux" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = "arn:aws:iam::554660509057:role/kul-eksNodeGroupRole"
  labels = {
    nodeGroup = local.node_group_name
  }
  tags           = local.tags
  instance_types = ["t3.medium"]
  disk_size      = 10
  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }
  subnet_ids = module.create_subnet.subnet_ids
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "kubernetes_namespace" {
  metadata {
    name = local.node_group_name
  }
}

data "kubernetes_all_namespaces" "namespaces" {
  depends_on = [
    kubernetes_namespace.kubernetes_namespace
  ]
}

output "namespaces" {
  value = data.kubernetes_all_namespaces.namespaces.namespaces
}
resource "aws_ec2_tag" "tagSubnets" {
  for_each = toset(module.create_subnet.subnet_ids)
  resource_id = each.value
  key = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
  value = "shared"
}

resource "kubernetes_service" "tomcat" {
  depends_on = [
    aws_ec2_tag.tagSubnets
  ]
  metadata {
    name = var.name
  }
  spec {
    selector = {
      app = "tomcat"
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}