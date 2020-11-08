job "vault" {
  datacenters = ["dc1"]
  type = "service"

  group "vault_server" {
    count = 1
    task "start_vault" {
      driver = "docker"
      config {
        image = "vault:latest"
      }

      resources {
        cpu    = 1000
        memory = 512

        network {
          mbits = 10
          port  "http"  {
            static = 8200
          }
        }
      }
      
      env {
        VAULT_DEV_ROOT_TOKEN_ID = "password"
      }
    }
  }
}