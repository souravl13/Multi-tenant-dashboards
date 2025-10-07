pipeline {
    agent any

    environment {
        IMAGE_NAME = "multi-tenant-dashboard"
        DEV_TAG = "dev"
        TEST_TAG = "test"
        PROD_TAG = "prod"
    }

    parameters {
        choice(name: 'ENV', choices: ['dev', 'test', 'prod'], description: 'Choose environment')
        string(name: 'TENANT', defaultValue: 'tenant1', description: 'Tenant name')
    }

   stage('Checkout') {
    steps {
        git credentialsId: 'github-creds', url: 'https://github.com/souravl13/Multi-tenant-dashboards.git', branch: 'main'
    }
}

        stage('Build Docker Image') {
            steps {
                script {
                    def tag = params.ENV == 'dev' ? DEV_TAG : params.ENV == 'test' ? TEST_TAG : PROD_TAG
                    docker.build("${IMAGE_NAME}-${params.TENANT}:${tag}")
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    def tag = params.ENV == 'dev' ? DEV_TAG : params.ENV == 'test' ? TEST_TAG : PROD_TAG
                    sh """
                        docker rm -f ${IMAGE_NAME}-${params.TENANT}-test || true
                        docker run --name ${IMAGE_NAME}-${params.TENANT}-test ${IMAGE_NAME}-${params.TENANT}:${tag} \
                        /bin/bash -c "pytest app/tests --maxfail=1 --disable-warnings"
                    """
                }
            }
        }

        stage('Deploy Tenant') {
            steps {
                script {
                    def tag = params.ENV == 'dev' ? DEV_TAG : params.ENV == 'test' ? TEST_TAG : PROD_TAG
                    def basePort = params.ENV == 'dev' ? 5000 : params.ENV == 'test' ? 5001 : 5002
                    def tenantPort = basePort + params.TENANT.hashCode().abs() % 1000

                    sh "docker rm -f ${IMAGE_NAME}-${params.TENANT}-${params.ENV} || true"
                    sh "docker run -d --name ${IMAGE_NAME}-${params.TENANT}-${params.ENV} -p ${tenantPort}:5000 ${IMAGE_NAME}-${params.TENANT}:${tag}"

                    echo "Tenant '${params.TENANT}' deployed on ${params.ENV} at port ${tenantPort}"
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up test containers...'
            sh "docker rm -f ${IMAGE_NAME}-${params.TENANT}-test || true"
        }
    }
}
