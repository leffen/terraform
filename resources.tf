## Digital Ocean
resource "digitalocean_kubernetes_cluster" "k8s" {
  name         = var.do_cluster_name
  region       = "sfo2"
  auto_upgrade = true
  version      = "1.18.6-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_spaces_bucket" "static-assets" {
  name   = var.do_space_name
  region = "sfo2"
}

## Keel

resource "helm_release" "keel" {
  name       = "keel"
  repository = "https://charts.keel.sh"
  chart      = "keel"
  namespace  = "kube-system"
  set {
    name  = "helmProvider.version"
    value = "v3"
  }
}

## Datadog 

resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }
}

resource "helm_release" "datadog" {
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "datadog"
  name       = "datadog"
  namespace  = "datadog"
  set {
    name  = "datadog.apiKey"
    value = var.dd_api_key
  }
}

## Nginx 

resource "helm_release" "ingress" {
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "nginx-ingress"
  name       = "ingress"
  set {
    name  = "controller.service.name"
    value = "nginx-ingress-controller"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

## docker-node-app

resource "kubernetes_namespace" "docker-node-app" {
  metadata {
    name = "docker-node-app"
  }
}

resource "helm_release" "docker-node-app" {
  repository = "https://jonfairbanks.github.io/helm-charts"
  chart      = "docker-node-app"
  name       = "docker-node-app"
  namespace  = "docker-node-app"
  set {
    name  = "ingress.hosts[0].host"
    value = "kube.bsord.dev"
  }
  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }
}

resource "cloudflare_record" "kube" {
  zone_id = var.cloudflare_zone_id
  name    = "kube"
  proxied = true
  value   = data.kubernetes_service.nginx-ingress-controller.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 1
}

## MongoDB

resource "kubernetes_namespace" "mongodb" {
  metadata {
    name = "mongodb"
  }
}

resource "helm_release" "mongodb" {
  name       = "mongodb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb-sharded"
  namespace  = "mongodb"
  set {
    name  = "mongodbRootPassword"
    value = var.mongo_root
  }
  set {
    name  = "mongodbUsername"
    value = var.mongo_user
  }
  set {
    name  = "mongodbPassword"
    value = var.mongo_pw
  }
  set {
    name  = "mongodbDatabase"
    value = var.do_cluster_name
  }
}

## MariaDB

resource "kubernetes_namespace" "mariadb" {
  metadata {
    name = "mariadb"
  }
}

resource "helm_release" "mariadb" {
  name       = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mariadb"
  namespace  = "mariadb"
}

## Tetris

resource "kubernetes_namespace" "tetris" {
  metadata {
    name = "tetris"
  }
}

resource "helm_release" "tetris" {
  repository = "https://bsord.github.io/helm-charts"
  chart      = "tetris"
  name       = "tetris"
  namespace  = "tetris"
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.hosts[0].host"
    value = "tetris.bsord.dev"
  }
  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }
}

resource "cloudflare_record" "tetris" {
  zone_id = var.cloudflare_zone_id
  name    = "tetris"
  proxied = true
  value   = data.kubernetes_service.nginx-ingress-controller.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 1
}

## React Register - bsord

resource "kubernetes_namespace" "rr-bsord" {
  metadata {
    name = "rr-bsord"
  }
}

resource "helm_release" "rr-bsord" {
  repository = "https://bsord.github.io/helm-charts"
  chart      = "rr-bsord"
  name       = "rr-bsord"
  namespace  = "rr-bsord"
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.hosts[0].host"
    value = "bsord.dev"
  }
  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }
}


resource "cloudflare_record" "at-bsord-dev" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  proxied = true
  value   = data.kubernetes_service.nginx-ingress-controller.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 1
}


## PayPal Sandbox Dashboard

/* resource "kubernetes_namespace" "paypal-sandbox-dashboard" {
  metadata {
    name = "paypal-sandbox-dashboard"
  }
}

resource "helm_release" "paypal-sandbox-dashboard" {
  repository = "https://fairbanks-io.github.io/helm-charts"
  chart      = "paypal-sandbox-dashboard"
  name       = "paypal-sandbox-dashboard"
  namespace  = "paypal-sandbox-dashboard"
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.hosts[0].host"
    value = "sandbox.bsord.dev"
  }
  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/"
  }
}

resource "cloudflare_record" "paypal-sandbox-dashboard" {
  zone_id = var.cloudflare_zone_id
  name    = "sandbox"
  proxied = true
  value   = data.kubernetes_service.nginx-ingress-controller.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 1
} */
