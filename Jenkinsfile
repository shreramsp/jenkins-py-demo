pipeline {
  agent any
  options { timestamps() }

  environment {
    IMAGE = 'shreramsp/jenkins-py-demo'
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
          def img = docker.build("${IMAGE}:${env.BUILD_NUMBER}")
          // stash the name for next stage
          env.BUILT_TAG = "${IMAGE}:${env.BUILD_NUMBER}"
        }
      }
    }

    stage('Push image') {
      when { branch 'main' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                          usernameVariable: 'DOCKERHUB_USER',
                                          passwordVariable: 'DOCKERHUB_TOKEN')]) {
          sh '''
            echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin
            docker push "${BUILT_TAG}"
            docker tag "${BUILT_TAG}" "${IMAGE}:latest"
            docker push "${IMAGE}:latest"
          '''
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
