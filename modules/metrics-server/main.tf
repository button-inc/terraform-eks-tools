# see https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.4.4
locals {
  name      = "metrics-server"
  namespace = "kube-system"
  image     = "k8s.gcr.io/metrics-server/metrics-server:v${var.tool_version}"
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
    name      = local.name
    namespace = local.namespace
  }
}

resource "kubernetes_cluster_role" "aggregated_metrics_reader" {
  metadata {
    name = "system:aggregated-metrics-reader"

    labels = {
      "app.kubernetes.io/name"                       = local.name
      "app.kubernetes.io/version"                    = var.tool_version
      "app.kubernetes.io/managed-by"                 = "terraform"
      "rbac.authorization.k8s.io/aggregate-to-view"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
    }
  }
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "system:metrics-server"

    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  rule {
    api_groups = [""]
    resources = [
      "pods",
      "nodes",
      "nodes/stats",
      "namespaces",
      "configmaps"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
}

resource "kubernetes_role_binding" "metrics_server_auth_reader" {
  metadata {
    name      = "metrics-server-auth-reader"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "auth_delegator" {
  metadata {
    name = "metrics-server:system:auth-delegator"
    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }

  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "system:metrics-server"

    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = local.name
    namespace = local.namespace

    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = local.name
    }
    port {
      port        = 443
      protocol    = "TCP"
      target_port = "https"
    }
  }
}

resource "kubernetes_api_service" "this" {
  metadata {
    name = "v1beta1.metrics.k8s.io"

    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    service {
      name      = kubernetes_service.this.metadata[0].name
      namespace = kubernetes_service.this.metadata[0].namespace
    }
    group                    = "metrics.k8s.io"
    version                  = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum   = 100
    version_priority         = 100
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = local.name
    namespace = local.namespace

    labels = {
      "app.kubernetes.io/name"       = local.name
      "app.kubernetes.io/version"    = var.tool_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.name
      }
    }

    strategy {
      rolling_update {
        max_unavailable = 0
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"       = local.name
          "app.kubernetes.io/version"    = var.tool_version
          "app.kubernetes.io/managed-by" = "terraform"
        }
      }

      spec {
        dns_policy     = "ClusterFirst"
        restart_policy = "Always"

        container {
          name              = local.name
          image             = local.image
          image_pull_policy = "IfNotPresent"

          args = [
            "--cert-dir=/tmp",
            "--secure-port=4443",
            "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
            "--kubelet-use-node-status-port"
          ]

          port {
            name           = "https"
            container_port = 4443
            protocol       = "TCP"
          }

          security_context {
            read_only_root_filesystem = true
            run_as_non_root           = true
            run_as_user               = 1000
          }

          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        priority_class_name              = "system-node-critical"
        service_account_name             = kubernetes_service_account.this.metadata[0].name
        termination_grace_period_seconds = 60

        volume {
          name = "tmp-dir"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.auth_delegator,
    kubernetes_role_binding.metrics_server_auth_reader,
    kubernetes_cluster_role_binding.this
  ]
}
