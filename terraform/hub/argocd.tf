
################################################################################
# AWS Secret Manager to read the secret for github repo application
################################################################################
data "aws_secretsmanager_secret" "git_data_addons" {
  name = var.git_creds_secret
}

data "aws_secretsmanager_secret_version" "git_data_version_addons" {
  secret_id = data.aws_secretsmanager_secret.git_data_addons.id
}

# Decode the JSON string into a map
locals {
  git_data = jsondecode(data.aws_secretsmanager_secret_version.git_data_version_addons.secret_string)
}

################################################################################
# GitOps Bridge: Private ssh keys for git
################################################################################
resource "kubernetes_namespace" "argocd" {
  depends_on = [local.cluster_info]

  metadata {
    name = local.argocd_namespace
  }
}
resource "kubernetes_secret" "git_secrets" {
  depends_on = [kubernetes_namespace.argocd]
  for_each = {
    git-addons = {
      type                    = "git"
      url                     = local.gitops_addons_repo_url
      githubAppID             = base64decode(local.git_data["github_app_id"])
      githubAppInstallationID = base64decode(local.git_data["github_app_installation_id"])
      githubAppPrivateKey     = base64decode(local.git_data["github_private_key"])
    }
    git-fleet = {
      type                    = "git"
      url                     = local.gitops_fleet_repo_url
      githubAppID             = base64decode(local.git_data["github_app_id"])
      githubAppInstallationID = base64decode(local.git_data["github_app_installation_id"])
      githubAppPrivateKey     = base64decode(local.git_data["github_private_key"])
    }
    git-resources = {
      type                    = "git"
      url                     = local.gitops_resources_repo_url
      githubAppID             = base64decode(local.git_data["github_app_id"])
      githubAppInstallationID = base64decode(local.git_data["github_app_installation_id"])
      githubAppPrivateKey     = base64decode(local.git_data["github_private_key"])
    }
    argocd-bitnami = {
      type      = "helm"
      url       = "charts.bitnami.com/bitnami"
      name      = "Bitnami"
      enableOCI = true
    }
    ecr-token-secret-0 = {
      type      = "helm"
      url       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com"
      name      = "ecr-charts"
      enableOCI = true
      username  = "AWS"
      password  = data.aws_ecr_authorization_token.token.password
    }
  }
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = each.value
}

################################################################################
# Creating parameter for argocd hub role for the spoke clusters to read
################################################################################
resource "aws_ssm_parameter" "argocd_hub_role" {
  name  = "/${local.cluster_name}/argocd-hub-role"
  type  = "String"
  value = module.argocd_hub_pod_identity.iam_role_arn
}

################################################################################
# Creating the Secret to have the same logic of enabling addons from the argo code 
# instead of running Terraform
################################################################################
resource "aws_secretsmanager_secret" "hub_cluster_secret" {
  name                    = "hub/${local.cluster_name}"
  recovery_window_in_days = 0
}

# Example of Having the Secret on the Spoke Account and Allow Access from HUB external Secrets to pull it
resource "aws_secretsmanager_secret_version" "hub_cluster_secret_version" {
  secret_id = aws_secretsmanager_secret.hub_cluster_secret.id
  secret_string = jsonencode({
    cluster_name = local.cluster_info.cluster_name
    metadata     = local.addons_metadata
    # Not merging the addons to external secrets to be able to conttol that from argo
    # If we add the addons the default versions will be constantly overwriten but we still deploy them to the secret
    addons = {}
    server = local.cluster_info.cluster_endpoint
    config = {
      tlsClientConfig = {
        insecure = false,
      },
    }
  })
}

################################################################################
# Install ArgoCD
################################################################################
resource "helm_release" "argocd" {
  name             = try(local.argocd.name, "argo-cd")
  description      = try(local.argocd.description, "A Helm chart to install the ArgoCD")
  namespace        = try(local.argocd.namespace, "argocd")
  create_namespace = try(local.argocd.create_namespace, true)
  chart            = try(local.argocd.chart, "argo-cd")
  version          = try(local.argocd.chart_version, "6.6.0")
  repository       = try(local.argocd.repository, "https://argoproj.github.io/argo-helm")
  values           = try(local.argocd.values, [])

  timeout                    = try(local.argocd.timeout, null)
  repository_key_file        = try(local.argocd.repository_key_file, null)
  repository_cert_file       = try(local.argocd.repository_cert_file, null)
  repository_ca_file         = try(local.argocd.repository_ca_file, null)
  repository_username        = try(local.argocd.repository_username, null)
  repository_password        = try(local.argocd.repository_password, null)
  devel                      = try(local.argocd.devel, null)
  verify                     = try(local.argocd.verify, null)
  keyring                    = try(local.argocd.keyring, null)
  disable_webhooks           = try(local.argocd.disable_webhooks, null)
  reuse_values               = try(local.argocd.reuse_values, null)
  reset_values               = try(local.argocd.reset_values, null)
  force_update               = try(local.argocd.force_update, null)
  recreate_pods              = try(local.argocd.recreate_pods, null)
  cleanup_on_fail            = try(local.argocd.cleanup_on_fail, null)
  max_history                = try(local.argocd.max_history, null)
  atomic                     = try(local.argocd.atomic, null)
  skip_crds                  = try(local.argocd.skip_crds, null)
  render_subchart_notes      = try(local.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(local.argocd.disable_openapi_validation, null)
  wait                       = try(local.argocd.wait, true)
  wait_for_jobs              = try(local.argocd.wait_for_jobs, null)
  dependency_update          = try(local.argocd.dependency_update, null)
  replace                    = try(local.argocd.replace, null)
  lint                       = try(local.argocd.lint, null)

  dynamic "postrender" {
    for_each = length(try(local.argocd.postrender, {})) > 0 ? [local.argocd.postrender] : []

    content {
      binary_path = postrender.value.binary_path
      args        = try(postrender.value.args, null)
    }
  }

  dynamic "set" {
    for_each = try(local.argocd.set, [])

    content {
      name  = set.value.name
      value = set.value.value
      type  = try(set.value.type, null)
    }
  }

  dynamic "set_sensitive" {
    for_each = try(local.argocd.set_sensitive, [])

    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
      type  = try(set_sensitive.value.type, null)
    }
  }
  depends_on = [kubernetes_secret.git_secrets]
}

resource "kubernetes_secret_v1" "cluster" {
  metadata {
    name        = local.argocd.name
    namespace   = local.argocd.namespace
    annotations = local.argocd_annotations
    labels      = local.argocd_labels
  }
  data = local.stringData

  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "bootstrap" {
  for_each = local.argocd_apps

  name      = each.key
  namespace = try(local.argocd.namespace, "argocd")
  chart     = "${path.module}/../../charts/resources"
  version   = "1.0.0"

  values = [
    <<-EOT
    resources:
      - ${indent(4, each.value)}
    EOT
  ]

  depends_on = [resource.kubernetes_secret_v1.cluster]
}