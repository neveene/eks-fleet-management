hub_account_id = "058264385461"
external_secrets_cross_account_role = ""
# amp_prometheus_crossaccount_role = ""

#cluster config
tenant = "tenant1"
cluster_type = "tenant"
hub_cluster_name = "hub-cluster-live"
deployment_environment = "live"
kubernetes_version = "1.32"
enable_automode = true
enable_ack_pod_identity = false
domain_name = ""
remote_spoke_secret = false
environment_prefix = "live"

#infrastructure
vpc_name = "spokevpc"
route53_zone_name = ""
kms_key_admin_roles = []
ami_release_version = ""
eks_cluster_endpoint_public_access = true

aws_resources = {
  enable_aws_cloudwatch_observability = true
  enable_cni_metrics_helper           = true
  enable_metrics_server               = true
  enable_external_secrets             = true
  enable_argocd                       = true
  enable_ack_iam                      = true
  enable_ack_eks                      = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  enable_argocd_ingress               = true
}