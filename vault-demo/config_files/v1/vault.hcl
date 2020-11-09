storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
  address = "172.20.20.10:8200"
  tls_disable = true
}

disable_mlock = true
cluster_addr = "http://172.20.20.10:8201"
api_addr = "http://172.20.20.10:8200"

ui = true