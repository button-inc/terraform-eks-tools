resource "kubernetes_namespace" "this" {
  for_each = { for v in var.namespaces : v => v }

  metadata {
    labels = {
      name = each.value
    }

    name = each.value
  }
}
