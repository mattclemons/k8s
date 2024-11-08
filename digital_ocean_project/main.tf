provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  config_path = "${pathexpand("~/.kube/config")}"
}

provider "helm" {
  kubernetes {
    config_path = "${pathexpand("~/.kube/config")}"
  }
}

# DigitalOcean Kubernetes Cluster

resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "do-k8s-cluster"
  region  = "nyc1"
  version = "1.31.1-do.4"  # Replace this with the chosen version slug
  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    node_count = 3
  }
}

# Fetch Kubernetes config from DigitalOcean
resource "null_resource" "get_kubeconfig" {
  provisioner "local-exec" {
    command = "doctl kubernetes cluster kubeconfig save ${digitalocean_kubernetes_cluster.k8s.name}"
  }
}

# Helm Deployment for Jenkins
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  values     = [file("jenkins-values.yaml")]
  depends_on = [null_resource.get_kubeconfig]
}

# Helm Deployment for SonarQube
resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  values     = [file("sonarqube-values.yaml")]
  depends_on = [null_resource.get_kubeconfig]
}

resource "null_resource" "fetch_load_balancer_urls" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Fetching Load Balancer IPs with doctl..."
      doctl compute load-balancer list --format ID,IP,ForwardingRules --no-header | awk '
      {
          ip = $2;
          n = split($3, rules, ",");
          for (i = 1; i <= n; i++) {
              if (rules[i] ~ /entry_port:/) {
                  port = substr(rules[i], index(rules[i], ":") + 1);
                  printf "http://%s:%s\\n", ip, port;
              }
          }
      }' > load_balancer_urls.txt
    EOT
  }
  depends_on = [
    helm_release.jenkins,
    helm_release.sonarqube
  ]
}
