resource "aws_efs_file_system" "efs-eks" {
  count            = local.aws_resources.enable_efs ? 1 : 0
  creation_token   = "efs-${local.cluster_name}"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "EfsEKS"
  }
}

resource "aws_efs_mount_target" "efs-eks" {
  for_each = local.enable_efs ? toset(data.aws_subnets.private_subnets.ids) : []
  file_system_id  = aws_efs_file_system.efs-eks[0].id
  subnet_id       = each.value
  security_groups = [local.cluster_info.node_security_group_id, local.cluster_info.cluster_security_group_id]
  depends_on = [ module.vpc ]
}
