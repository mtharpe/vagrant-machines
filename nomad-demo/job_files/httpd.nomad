job "httpd" {
  datacenters = ["dc1"]
  type = "service"

  group "httpd_server" {
    count = 1
    task "start_httpd" {
      driver = "docker"
      config {
        image = "httpd:latest"
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10
          port  "http"  {
            static = 80
          }
        }
      }
    }
  }
}