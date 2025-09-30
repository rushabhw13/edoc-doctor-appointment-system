pipeline {
  agent any

  environment {
    IMAGE_NAME = "edoc-app"
    BUILD_TAG  = "${env.BUILD_ID}"
    NETWORK    = "edoc-net"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/rushabhw13/edoc-doctor-appointment-system.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh """
            docker build -t ${IMAGE_NAME}:${BUILD_TAG} .
          """
        }
      }
    }

    stage('Prepare Network & Clean old containers') {
      steps {
        script {
          sh """
            docker network inspect ${env.NETWORK} >/dev/null 2>&1 || docker network create ${env.NETWORK}
            docker rm -f edoc-app || true
            docker rm -f edoc-db  || true
          """
        }
      }
    }

    stage('Start MariaDB') {
      steps {
        script {
          sh """
            docker run -d --name edoc-db --network ${env.NETWORK} \\
              -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=edoc \\
              -v "${env.WORKSPACE}/SQL_Database_edoc.sql":/docker-entrypoint-initdb.d/init.sql \\
              mariadb:10.5

            echo "Waiting for MariaDB to be ready..."
            SECONDS=0
            until docker logs edoc-db 2>&1 | grep -i "ready for connections" >/dev/null; do
              sleep 2
              SECONDS=\$((SECONDS+2))
              if [ \$SECONDS -gt 120 ]; then
                echo "Timeout waiting for MariaDB" >&2
                docker logs edoc-db || true
                exit 1
              fi
            done
            echo "MariaDB ready."
          """
        }
      }
    }

    stage('Run Web Container') {
      steps {
        script {
          sh """
            docker run -d --name edoc-app --network ${env.NETWORK} --network-alias db -p 8080:80 ${IMAGE_NAME}:${BUILD_TAG}
            sleep 5
            HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo "000")
            echo "HTTP status: \$HTTP_CODE"
            if [ "\$HTTP_CODE" = "000" ] || [ "\$HTTP_CODE" = "502" ] || [ "\$HTTP_CODE" = "503" ]; then
              echo "App not responding yet, tailing logs..."
              docker logs edoc-app --tail 100
              exit 1
            fi
          """
        }
      }
    }

    stage('Cleanup old images') {
      steps {
        script {
          sh """
            docker image prune -f || true
          """
        }
      }
    }
  } // stages

  post {
    success {
      echo "Deployment succeeded. App should be available at http://<EC2_PUBLIC_IP>:8080"
    }
    failure {
      script {
        sh 'docker logs edoc-app --tail 200 || true'
        sh 'docker logs edoc-db --tail 200 || true'
      }
    }
  }
}
