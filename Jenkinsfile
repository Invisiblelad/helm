pipeline {
    agent any
    environment {
        DOCKER_USER = credentials('dockeruser') 
        DOCKER_PWD = credentials('dockerpwd')  
        COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }
    stages {
        stage('Git Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/Invisiblelad/helm.git']]
                ])
            }
        }
        stage('Get Commit Hash') {
            steps {
                script {
                    env.COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                }
            }
        }
        stage('Docker Login') {
            steps {
                script {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PWD}"
                }
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_USER}/app:${COMMIT_HASH} ."
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    sh "docker push ${DOCKER_USER}/app:${COMMIT_HASH}"
                }
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

                

