pipeline {
    agent any 
 stages {
    stage('git-pull') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/eks-infra.git'
                echo "git pull successful"
            }
        }
  stage('terraform-init') {
            steps {
                sh 'terraform init'
                echo "terraform init successful"
            }
        }
   stage('terraform-plan') {
            steps {
                sh 'terraform plan'
                echo "terraform plan successful"
            }
        }
    stage('Approval') {
            steps {
               input message: "Approve Terraform Apply for EKS Cluster?", ok: "Approve"
            }
        }

        stage('terraform-apply') {
            steps {
                sh 'terraform apply -auto-approve'
                echo "terraform apply successful"
            }
        }
    stage('deploy') {
            steps {
                echo "Deploy stage completed"
            }
        }
    }
}
