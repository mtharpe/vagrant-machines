storage "raft" {
  path    = "/opt/vault"
  node_id = "v3"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

disable_mlock = true
cluster_addr = "http://172.20.20.12:8201"
api_addr = "http://172.20.20.12:8200"
ui = true