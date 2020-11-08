storage "raft" {
  path    = "/opt/vault"
  node_id = "v2"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

disable_mlock = true
cluster_addr = "http://172.20.20.11:8201"
api_addr = "http://172.20.20.11:8200"
ui = true