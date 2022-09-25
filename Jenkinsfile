pipeline {
    agent any
        stages{
            stage('TF State'){
                steps{
                    script{
                        def props = readProperties file: '.sandbox'
                        props.each { key, value ->
                            env."$key"="$value"
                        }

                        env.PROFILE="${APP_NAME}-${DEPLOYMENT_ENVIRONMENT}"
                        env.PROFILE_STATEMENT = "--profile ${PROFILE}"
                        env.STATE_BUCKET="${APP_NAME}-${DEPLOYMENT_ENVIRONMENT}-tfstate"
                        env.STATE_BUCKET_KEY="${APP_NAME}-${DEPLOYMENT_ENVIRONMENT}.tfstate"

                        withAWS(credentials:"${PROFILE}") {
                            sh '''
                                if aws s3 ls "s3://${STATE_BUCKET}" 2>&1 | grep -q "NoSuchBucket"
                                then
                                aws s3api create-bucket --bucket ${STATE_BUCKET} --region ${AWS_REGION}
                                aws s3api put-bucket-versioning --bucket ${STATE_BUCKET} --versioning-configuration Status=Enabled
                                else
                                    echo "bucket exist"
                                fi
                            '''
                        }

                        withAWS(credentials:"${PROFILE}") {
                            sh '''
                                LOCKED=$(aws s3 ls s3://${STATE_BUCKET} | grep ${STATE_BUCKET_KEY}.lock | wc -l | xargs)
                                echo "$LOCKED" > "is_locked.txt"
                                if [ "$LOCKED" != "0" ] ; then
                                echo "Someone else is terraforming this environment. Stopping."
                                else
                                    touch $STATE_BUCKET_KEY.lock
                                    aws s3 cp ${STATE_BUCKET_KEY}.lock \
                                        s3://${STATE_BUCKET}/${STATE_BUCKET_KEY}.lock
                                    rm ${STATE_BUCKET_KEY}.lock
                                fi
                            '''
                        }

                        if (readFile('is_locked.txt').contains('1')) {
                            currentBuild.result = 'ABORTED'
                            error('Someone else is terraforming this environment. Stopping.')
                        }

                        sh 'rm is_locked.txt'
                    }
                }
            }
            stage('TF Apply'){
                steps{
                    script{
                        def props = readProperties file: '.sandbox'
                        props.each { key, value ->
                            env."$key"="$value"
                        }

                        env.STATE_BUCKET="${APP_NAME}-${DEPLOYMENT_ENVIRONMENT}-tfstate"
                        env.STATE_BUCKET_KEY="${APP_NAME}-${DEPLOYMENT_ENVIRONMENT}.tfstate"
                        
                        sh "cp ./variables/${DEPLOYMENT_ENVIRONMENT}/*_override.tf ."

                        withAWS(credentials:"${PROFILE}") {
                            sh '''
                                aws s3 rm s3://${STATE_BUCKET}/${STATE_BUCKET_KEY}.lock
                                
                                echo no | ${TERRAFORM_HOME}/terraform init -backend=true -input=true \
                                -backend-config "bucket=${STATE_BUCKET}" \
                                -backend-config "key=${STATE_BUCKET_KEY}" \
                                -backend-config "profile=$PROFILE" \
                                -backend-config "region=${AWS_REGION}"

                                ${TERRAFORM_HOME}/terraform plan -var "aws_key_path=${AWS_KEY_PATH}" -out=tfplan -input=false

                                ${TERRAFORM_HOME}/terraform get
                                TF_VAR_aws_region=${AWS_REGION} \
                                TF_VAR_environment=${DEPLOYMENT_ENVIRONMENT} \
                                TF_VAR_app_name=${APP_NAME} \
                                TF_VAR_company_name=${COMPANY_NAME} \
                                TF_VAR_aws_key_path=${AWS_KEY_PATH} \
                                ${TERRAFORM_HOME}/terraform destroy -auto-approve
                                
                            '''
                        }
                    }
                }
            }
        }
    //     stages {
    //         stage('Git checkout') {
    //            steps{
    //                 git branch: 'master', credentialsId: 'Github', url: 'https://bitbucket.org/compunnel-terraform-modules/terraform-templates.git'
    //             }
    //         }
    //         stage('terraform format check') {
    //             steps{
    //                 sh 'terraform fmt'
    //             }
    //         }
    //         stage('terraform Init') {
    //             steps{
//                 sh 'terraform init'
//             }
//         }
//         stage('terraform plan') {
//             steps{
//                 sh 'terraform plan'
//             }
//         }
//         stage('terraform apply') {
//             steps{
//                 sh 'terraform apply --auto-approve'
//             }
//         }
//     }

    
// }
//      stages {
//          steps {
//             withCredentials([usernamePassword(credentialsId: 'eb1092d1-0f06-4bf9-93c7-32e5f7b9ef76', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                 sh 'echo $AWS_ACCESS_KEY_ID'
//                 sh 'echo $AWS_SECRET_ACCESS_KEY'
//             }
//       }
//          }
// }
