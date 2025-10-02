pipeline {
  agent any
  options { timestamps() }

  environment {
    IMAGE = 'shreramsp/jenkins-py-demo'   // your Docker Hub repo
  }

  stages {
    stage('Test (in container)') {
      steps {
        script {
          docker.image('python:3.13.7-alpine3.22').inside {
            sh '''
              python -m venv .venv
              . .venv/bin/activate
              python -m pip install --upgrade pip
              pip install -r requirements.txt
              mkdir -p reports
              pytest -q --junitxml=reports/junit.xml
            '''
          }
        }
      }
    }

    stage('Build image') {
      steps {
        script {
          img = docker.build("${IMAGE}:${env.BUILD_NUMBER}")
        }
      }
    }

    stage('Push image') {
      when { branch 'main' }
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
            img.push()            // :BUILD_NUMBER
            img.push('latest')    // :latest
          }
        }
      }
    }
  }

  post {
    always {
      junit 'reports/junit.xml'
      archiveArtifacts 'reports/**'
    }
  }
}
