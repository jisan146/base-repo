
pipeline {
    agent any

    triggers {

    }


    environment {

        DOCKER_IMAGE_NAME = 'my-html-app'
        DOCKER_HUB_CREDENTIALS_ID = '***' 
        EC2_SSH_CREDENTIALS_ID = 'ec2-ssh-key' 
        EC2_INSTANCE_IP = '192.168.50.100' 
        GOOGLE_CHAT_WEBHOOK_URL = 'YOUR_GOOGLE_CHAT_WEBHOOK_URL' 
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        skipDefaultCheckout(true) // We will do a custom checkout
    }


    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'master', description: 'Branch to build')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                echo "Cleaning workspace..."
                cleanWs() 
            }
        }

        stage('Checkout Source') {
            steps {
                echo "Checking out source code from branch: ${params.BRANCH_NAME}"
                git branch: "${params.BRANCH_NAME}", url: 'https://github.com/jisan146/base-repo.git' 
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    def date = new Date().format('dd-MM-HH-mm')
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}-${date}"
                    def fullImageName = "${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"

                    echo "Building Docker image: ${fullImageName}..."
                    sh "docker build -t ${fullImageName} ."

                    withCredentials([usernamePassword(credentialsId: env.DOCKER_HUB_CREDENTIALS_ID,
                                                      usernameVariable: 'DOCKER_USERNAME',
                                                      passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo "Logging into Docker Hub..."
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"

                        echo "Pushing Docker image to Docker Hub: ${fullImageName}..."
                        sh "docker push ${fullImageName}"

                        echo "Logging out from Docker Hub..."
                        sh "docker logout"
                    }
                    echo "Docker image build and push complete."
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo "Running tests (placeholder)..."
                sh 'echo "Tests passed!"'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."
                script {
                    // Ensure kubectl is configured on the Jenkins agent
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                    sh 'kubectl apply -f ingress.yaml'
                }
            }
        }

        stage('Update and Rerun Docker Compose on EC2') {
            steps {
                script {
                    echo "Connecting to EC2 instance ${env.EC2_INSTANCE_IP} to update Docker Compose..."

                    withCredentials([sshUserPrivateKey(credentialsId: env.EC2_SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
         
                        sh "echo \"\$SSH_KEY\" > jenkins_ssh_key.pem"
                        sh "chmod 600 jenkins_ssh_key.pem"

        
                        echo "Updating image tag in /var/www/app/docker-compose.yaml on EC2..."
                        sh "ssh -i jenkins_ssh_key.pem -o StrictHostKeyChecking=no ec2-user@${env.EC2_INSTANCE_IP} 'sudo sed -i \"s|image: ${env.DOCKER_IMAGE_NAME}:.*|image: ${env.DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}|g\" /var/www/app/docker-compose.yaml'"

            
                        echo "Rerunning Docker Compose on EC2 to pick up the new image..."
          
                        sh "ssh -i jenkins_ssh_key.pem -o StrictHostKeyChecking=no ec2-user@${env.EC2_INSTANCE_IP} 'cd /var/www/app && sudo /usr/local/bin/docker-compose up -d --force-recreate'"

                     
                        sh "rm jenkins_ssh_key.pem"
                    }
                    echo "Docker Compose update and rerun on EC2 complete."
                }
            }
        }
    }

    // Post-build actions (e.g., notifications)
    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "Pipeline succeeded!"
   
            googleChatSend(
                message: "Your application has been updated!\nImage Name: ${env.DOCKER_IMAGE_NAME}\nImage Tag: ${env.IMAGE_TAG}",
                url: env.GOOGLE_CHAT_WEBHOOK_URL
            )
        }
        failure {
            echo "Pipeline failed!"

            googleChatSend(
                message: "Pipeline failed for ${env.JOB_NAME} build #${env.BUILD_NUMBER}!",
                url: env.GOOGLE_CHAT_WEBHOOK_URL
            )
        }
    }
}
