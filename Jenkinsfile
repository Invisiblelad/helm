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
        stage('Check Commit') {
            steps {
                script {
                    def lastCommit = sh(script: "git log -1 --format=%H", returnStdout: true).trim()
                    if (lastCommit == COMMIT_HASH) {
                        echo "This commit has already been processed. Skipping build."
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
                    sed -i 's|^\\(\\s*tag:\\).*|\\1 ${COMMIT_HASH}|' ${valuesFile}
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
                        git fetch https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Invisiblelad/helm.git
                        git stash || echo "No changes to stash"
                        git checkout main
                        git pull https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Invisiblelad/helm.git main --rebase
                        git stash pop || echo "No stashed changes to apply"                
                        git add ./nginx/values.yaml
                        COMMIT_MESSAGE=\$(git log -1 --pretty=%B)
                        if [[ "\${COMMIT_MESSAGE}" != *"[ci skip]"* ]]; then
                            git commit -m "Updated Helm values.yaml with tag ${COMMIT_HASH} [ci skip]" || echo "No changes to commit"
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Invisiblelad/helm.git main --push-option=ci.skip
                        else
                            echo "Commit contains '[ci skip]', skipping push."
                        fi
                        """
                    }
                }
            }
        }
    }
}
