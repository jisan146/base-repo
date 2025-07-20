

pipeline {

    agent any


    triggers {

    }


    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }


    parameters {

        string(name: 'BRANCH_NAME', defaultValue: 'master', description: 'Branch to build')
    }


    stages {
        stage('Checkout Source') {
            steps {
                echo "Checking out source code from branch: ${params.BRANCH_NAME}"

                git branch: "${params.BRANCH_NAME}", url: 'https://github.com/jisan146/base-repo.git' 
            }
        }

        stage('Build Application') {
            steps {
                echo "Building the application..."
                script {
                    sh 'docker build -t my-html-app:latest .'
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
    }


    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "Pipeline succeeded!"

        }
        failure {
            echo "Pipeline failed!"

        }
    }
}
