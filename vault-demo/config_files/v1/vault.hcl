storage "raft" {
  path    = "/opt/vault"
  node_id = "v1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

disable_mlock = true
cluster_addr = "http://172.20.20.10:8201"
api_addr = "http://172.20.20.10:8200"
ui = true