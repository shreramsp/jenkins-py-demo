pipeline {
  agent { docker { image 'python:3.13.7-alpine3.22' } }
  options { timestamps() }

  stages {
    stage('Install') {
      steps {
        sh 'python -m pip install --upgrade pip'
        sh 'pip install -r requirements.txt'
      }
    }
    stage('Test') {
      steps {
        sh 'mkdir -p reports'
        sh 'pytest -q --junitxml=reports/junit.xml'
      }
    }
  }

  post {
    always {
      junit 'reports/junit.xml'
    }
  }
}
