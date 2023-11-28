provider "google" {
  project = "study-406403"
  region      = "asia-northeast3"

}

resource "google_service_account" "default" {
  account_id   = "study-k8s-1127"
  display_name = "study Account"
}

resource "google_container_cluster" "primary" {
  name     = "study-cluster"
  location = "asia-northeast3"
  deletion_protection=false
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "asia-northeast3"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}