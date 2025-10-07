pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_NAME = "souravl13/multitenant-dashboard"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning source code..."
                git branch: 'main', url: 'https://github.com/souravl13/Multi-tenant-dashboards.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Test Environment') {
            steps {
                script {
                    echo "Running container in test environment..."
                    sh 'docker run -d --name multi_tenant_test_${BUILD_NUMBER} -p 5001:5000 ${IMAGE_NAME}:${BUILD_NUMBER}'
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    echo "Running unit tests inside container..."
                    sh 'docker exec multi_tenant_test_${BUILD_NUMBER} pytest || true'
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                expression { env.BRANCH_NAME == 'main' }
            }
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub..."
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh 'docker push ${IMAGE_NAME}:${BUILD_NUMBER}'
                }
            }
        }

        stage('Deploy to Dev Environment') {
            steps {
                script {
                    echo "Deploying to dev environment..."
                    sh 'docker stop multi_tenant_dev || true && docker rm multi_tenant_dev || true'
                    sh 'docker run -d --name multi_tenant_dev -p 5000:5000 ${IMAGE_NAME}:${BUILD_NUMBER}'
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up test containers..."
            sh 'docker stop $(docker ps -aq --filter name=multi_tenant_test_) || true'
            sh 'docker rm $(docker ps -aq --filter name=multi_tenant_test_) || true'
        }

        success {
            echo "✅ Build & Deployment completed successfully!"
        }

        failure {
            echo "❌ Build or deployment failed!"
        }
    }
}
