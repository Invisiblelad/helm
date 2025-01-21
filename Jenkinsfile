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
                    branches: [[name: '*/test']],
                    userRemoteConfigs: [[url: 'https://github.com/Invisiblelad/helm.git']]
                ])
            }
        }
        stage('Check Commit Source') {
            steps {
                script {
                    def lastCommit = sh(script: "git log -1 --format=%H", returnStdout: true).trim()
                    def commitAuthor = sh(script: "git log -1 --format=%an", returnStdout: true).trim()
                    if (lastCommit == COMMIT_HASH && commitAuthor == 'Jenkins') {
                        echo "This commit was made by Jenkins. Skipping build."
                        return
                    }
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
                    def hasChanges = sh(script: "git status --porcelain", returnStdout: true).trim()
                    if (hasChanges) {
                        sh "docker build -t ${DOCKER_USER}/app:${COMMIT_HASH} ."
                    } else {
                        echo "No changes detected for Docker build."
                    }
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    def hasChanges = sh(script: "git status --porcelain", returnStdout: true).trim()
                    if (hasChanges) {
                        sh "docker push ${DOCKER_USER}/app:${COMMIT_HASH}"
                    } else {
                        echo "No changes detected for Docker push."
                    }
                }
            }
        }
        stage('Update Helm Values') {
            steps {
                script {
                    def valuesFile = './nginx/values.yaml'
                    def helmValuesUpdated = sh(script: "grep -q 'tag: ${COMMIT_HASH}' ${valuesFile}", returnStatus: true)
                    if (helmValuesUpdated != 0) {
                        sh "sed -i 's|^\\(\\s*tag:\\).*|\\1 ${COMMIT_HASH}|' ${valuesFile}"
                    } else {
                        echo "Helm values already updated with the current commit."
                    }
                }
            }
        }
    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
}
