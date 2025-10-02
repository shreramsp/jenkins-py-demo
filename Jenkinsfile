pipeline {
  agent any
  options { timestamps() }

  environment {
    IMAGE = 'shreramsp/jenkins-py-demo'
  }

  stages {
    stage('Test (in container)') {
      options { timeout(time: 5, unit: 'MINUTES') }
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
          env.BUILT_TAG = "${IMAGE}:${env.BUILD_NUMBER}"
        }
      }
    }

    stage('Push image') {
      when { branch 'main' }
      steps {
        retry(2) {
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
  }

  post {
    always {
      junit 'reports/junit.xml'
      archiveArtifacts 'reports/**'
      echo 'One way or another, I have finished'
      deleteDir()  // cleanup workspace
    }
    success {
      echo "I succeeded! Image pushed as ${IMAGE}:${env.BUILD_NUMBER} and :latest"
      // emailext(...) or slackSend(...) can go here if you install those plugins
    }
    unstable {
      echo 'I am unstable :/'
    }
    failure {
      echo 'I failed :('
    }
    changed {
      echo 'The pipeline state changed compared to the previous run.'
    }
  }
}
