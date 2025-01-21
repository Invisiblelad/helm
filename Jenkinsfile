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
                    def valuesFile = './nginx/values.yaml'
                    sh """
                    echo "File path verification:"
                    ls -la ${valuesFile}
                    echo "Contents before update:"
                    cat ${valuesFile}
                    sed -i 's|^\\(\\s*tag:\\).*|\\1 ${COMMIT_HASH}|' ${valuesFile}
                    echo "Contents after update:"
                    cat ${valuesFile}
                    """
                }
            }
        }
        stage('Commit and Push Changes') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'git_creds_id', 
                                                     usernameVariable: 'GIT_USERNAME', 
                                                     passwordVariable: 'GIT_PASSWORD')]) {
                        sh """
                        git fetch origin main
                        git rebase origin/main || git rebase --abort
                        git add ./nginx/values.yaml
                        git commit -m "Updated Helm values.yaml with tag ${COMMIT_HASH} [ci skip]" || echo "No changes to commit"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Invisiblelad/helm.git main
                        """
                    }
                }
            }
        }
    }
}

                

