pipeline {
    agent any
    environment {
        COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }
    stages {
        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Invisiblelad/helm.git']])
            }
        }
        stage('Docker Login') {
            steps {
                withCredentials([string(credentialsId: 'dockerpwd', variable: 'dockerpwd')]) {
                    sh "docker login -u ${dockeruser} -p ${dockerpwd}"
                }
            }
        }
        stage('Docker Build') {
            steps {
                sh "docker build -t ${dockeruser}/app:${COMMIT_HASH} ."
            }
        }
        stage('Docker Push') {
            steps {
                sh "docker push ${dockeruser}/app:${COMMIT_HASH}"
            }
        }
        stage('Update Helm Values') {
            steps {
                script {
                    def valuesFile = 'values.yaml'
                    sh """
                    sed -i 's|tag:.*|tag: ${COMMIT_HASH}|g' ${valuesFile}
                    """
                }
            }
        }
    }
}

