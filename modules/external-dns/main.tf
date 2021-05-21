locals {
  name      = "external-dns"
  namespace = "kube-system"
}

data "aws_iam_policy_document" "dns_policy" {
  count = var.create ? 1 : 0

  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "oidc_assume_role" {
  count = var.create ? 1 : 0

  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${local.namespace}:${local.name}"
      ]
    }

    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_policy" "this" {
  count = var.create ? 1 : 0

  name        = "${var.cluster_name}-dns-iam-policy"
  description = "Policy required by the Kubernetes AWS External DNS"
  policy      = data.aws_iam_policy_document.dns_policy[0].json
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name                  = "${var.cluster_name}-dns-iam-role"
  description           = "Role required by the Kubernetes AWS External DNS"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.oidc_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create ? 1 : 0

  policy_arn = aws_iam_policy.this[0].arn
  role       = aws_iam_role.this[0].name
}

resource "kubernetes_service_account" "this" {
  count = var.create ? 1 : 0

  automount_service_account_token = true

  metadata {
    name      = local.name
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this[0].arn
    }
  }
}

resource "kubernetes_cluster_role" "this" {
  count = var.create ? 1 : 0

  metadata {
    name = local.name
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  count = var.create ? 1 : 0

  metadata {
    name = local.name
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this[0].metadata[0].name
    namespace = kubernetes_service_account.this[0].metadata[0].namespace
  }

  depends_on = [kubernetes_cluster_role.this]
}

resource "kubernetes_deployment" "this" {
  count = var.create ? 1 : 0

  metadata {
    name      = local.name
    namespace = kubernetes_service_account.this[0].metadata[0].namespace
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = local.name
        }
      }

      spec {
        service_account_name = kubernetes_service_account.this[0].metadata[0].name

        container {
          name              = local.name
          image             = "registry.opensource.zalan.do/teapot/external-dns:latest"
          image_pull_policy = "Always"

          args = [
            "--source=service",
            "--source=ingress",
            "--provider=aws",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-prefix=extdns-",
            "--txt-owner-id=my-hostedzone-identifier",
          ]
        }

        security_context {
          fs_group = 65534
        }
      }
    }
  }

  depends_on = [kubernetes_cluster_role_binding.this]
}
