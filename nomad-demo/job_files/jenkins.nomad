job "jenkins" {
  datacenters = ["dc1"]
  type = "service"

  group "jenkins_server" {
    count = 1
    task "start_jenkins" {
      driver = "docker"
      config {
        image = "jenkins/jenkins:lts"
      }

      resources {
        cpu    = 1000
        memory = 2048

        network {
          mbits = 100
          port  "http"  {
            static = 8080
          }
        }
      }
    }
  }
}