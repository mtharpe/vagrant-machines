# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad-server"

# Enable the server
server {
    enabled = true
    bootstrap_expect = 3
    server_join {
      retry_join = [ "172.20.20.100:4648", "172.20.20.101:4648", "172.20.20.102:4648" ]
  }
}

# Enable the client
client {
    enabled = true
    servers = ["172.20.20.100", "172.20.20.101", "172.20.20.102"]
    network_interface = "eth1"
}

# Enable raw exec
plugin "raw_exec" {
  config {
    enabled = true
  }
}