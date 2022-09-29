pipeline {
    agent any

    parameters {
        string(name: 'environment', defaultValue: 'Sandbox', description: 'Workspace/environment file to use for deployment')
        string(name: 'version', defaultValue: '1.1', description: 'Version variable to pass to Terraform')
        booleanParam(name: 'autoApprove', defaultValue: true, description: 'Automatically run apply after generating plan?')
    }
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AKIARNLRGQ5BNU5LU6WX')
        AWS_SECRET_ACCESS_KEY = credentials('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')
        TF_IN_AUTOMATION      = '1'
    }

    stages {
        stage('Plan') {
            steps {
                script {
                    currentBuild.displayName = params.version
                }
                sh 'terraform init -input=false'
                sh 'terraform workspace select ${environment}'
                sh "terraform plan -input=false -out tfplan -var 'version=${params.version}' --var-file=environments/${params.environment}.tfvars"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan.txt'
        }
    }
}