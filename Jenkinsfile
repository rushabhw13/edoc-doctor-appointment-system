pipeline {
    agent any

    stages {
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/rushabhw13/edoc-doctor-appointment-system.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t edoc-app .'
                }
            }
        }

        stage('Run Containers') {
            steps {
                script {
                    sh 'docker compose down || true'
                    sh 'docker compose up -d --build'
                }
            }
        }
    }
}
