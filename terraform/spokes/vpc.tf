module "vpc" {
  count   = local.vpc_name != "" ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                  = var.vpc_name
  cidr                  = local.vpc_cidr
  secondary_cidr_blocks = [local.secondary_vpc_cidr]
  azs                   = local.azs
  private_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  intra_subnets         = [for k, v in local.azs : cidrsubnet(local.secondary_vpc_cidr, 4, k)]
  public_subnets        = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 4)]


  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.vpc_name}-default" }

  public_subnet_tags = merge(local.tags, {
    "Name" = "public-${local.vpc_name}"
  })
  intra_subnet_tags = merge(local.tags, {
    "Name" = "intra-${local.vpc_name}"
  })
  private_subnet_tags = merge(local.tags, {
    "Name" = "private-${local.vpc_name}"
  })

  tags = local.tags
}

# private nat gateway
resource "aws_nat_gateway" "private_nat" {
  count             = local.vpc_name != "" ? 1 : 0
  connectivity_type = "private"
  subnet_id         = try(module.vpc[0].private_subnets[0], "")
}

#route for intra subnets
# resource "aws_route" "intra_subnets_default_gateway" {
#   count                  = local.vpc_name != "" ? 1 : 0
#   route_table_id         = try(module.vpc[0].intra_route_table_ids[0], "")
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = try(aws_nat_gateway.private_nat[0].id, "")
#   depends_on             = [aws_nat_gateway.private_nat]
# }
