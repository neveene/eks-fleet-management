################################################################################
# Tagging Subents for Loadbalancer configuration and CNI discovery
################################################################################
resource "aws_ec2_tag" "private_subnets" {
  count       = length(data.aws_subnets.private_subnets.ids)
  resource_id = data.aws_subnets.private_subnets.ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnets_lb" {
  count       = length(data.aws_subnets.private_subnets.ids)
  resource_id = data.aws_subnets.private_subnets.ids[count.index]
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "owned"
}

resource "aws_ec2_tag" "public_subnets" {
  count       = length(data.aws_subnets.public_subnets.ids)
  resource_id = data.aws_subnets.public_subnets.ids[count.index]
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "owned"
}

resource "aws_ec2_tag" "publicsubnets" {
  count       = length(data.aws_subnets.public_subnets.ids)
  resource_id = data.aws_subnets.public_subnets.ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "intra_subnets_worker" {
  count       = length(data.aws_subnets.intra_subnets.ids)
  resource_id = data.aws_subnets.intra_subnets.ids[count.index]
  key         = "kubernetes.io/role/cni"
  value       = "1"
}

resource "aws_ec2_tag" "intra_subnets_worker_karpenter" {
  count       = length(data.aws_subnets.intra_subnets.ids)
  resource_id = data.aws_subnets.intra_subnets.ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = local.cluster_name
}

