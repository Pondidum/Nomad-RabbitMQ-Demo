job "rabbit" {

  datacenters = ["dc1"]
  type = "service"

  group "cluster" {
    count = 3

    update {
      max_parallel = 1
    }

    migrate {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "5s"
      healthy_deadline = "30s"
    }

    task "rabbit" {
      driver = "docker"

      config {
        image = "pondidum/rabbitmq:consul"
        hostname = "${attr.unique.hostname}"
        port_map {
          amqp = 5672
          ui = 15672
          discovery = 4369
          clustering = 25672
        }
      }

      env {
        RABBITMQ_ERLANG_COOKIE = "rabbitmq"
        CONSUL_HOST = "${attr.unique.network.ip-address}"
      }

      resources {
        network {
          port "amqp" { static = 5672 }
          port "ui" { static = 15672 }
          port "discovery" { static = 4369 }
          port "clustering" { static = 25672 }
        }
      }

      service {
        name = "rabbitmq"
        port = "ui"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
