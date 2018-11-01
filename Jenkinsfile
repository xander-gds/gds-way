pipeline {
    agent none

    stages {
        stage('BuildNDeploy') {

            agent {
                label 'ruby-way'
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'cflogin', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh 'bundle ; bundle exec middleman build'
                    sh 'cf api https://api.cloud.service.gov.uk'
                    sh 'cf login -u $USER -p $PASS -s re-build-sandbox -o gds-tech-ops'
                    sh 'cf push'
                }
            }
        }
    }
}
