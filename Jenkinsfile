#!/usr/bin/env groovy

/**
 * Jenkinsfile
 */
pipeline {
    agent {
        dockerfile {
        label "dind"
        }
    }    
    options {
        buildDiscarder(
            logRotator(numToKeepStr:'10'))
    }
    environment {
        projectName = 'ProjectTemplate'
        emailTo = 'falak.ahmed@ge.com'
        emailFrom = 'AnalyticsCore@build.ge.com'
    }

    stages {

        stage ('Checkout') {
            steps {
                checkout scm
            }
        }

        stage ('Install_Requirements') {
            steps {
                pip install -r requirements.txt -r dev-requirements.txt
                make clean
            }
        }

        stage ('Unit Tests') {
            steps {
                make unittest || true
            }
            post {
                always {
                    junit keepLongStdio: true, testResults: 'report/nosetests.xml'
                    publishHTML target: [
                        reportDir: 'report/coverage',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report - Unit Test'
                    ]
                }
            }
        }

        stage ('System Tests') {
            steps {
                make systest || true
            }
            post {
                always {
                    junit keepLongStdio: true, testResults: 'report/nosetests.xml'
                    publishHTML target: [
                        reportDir: 'report/coverage',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report - System Test'
                    ]
                }
            }
        }

        stage ('Docs') {
            steps {
                PYTHONPATH=. pdoc --html --html-dir docs --overwrite env.projectName
            }

            post {
                always {
                    publishHTML target: [
                        reportDir: 'docs/*',
                        reportFiles: 'index.html',
                        reportName: 'Module Documentation'
                    ]
                }
            }
        }
    }

    post {
        failure {
            mail body: "${env.JOB_NAME} (${env.BUILD_NUMBER}) ${env.projectName} build error " +
                       "is here: ${env.BUILD_URL}\nStarted by ${env.BUILD_CAUSE}" ,
                 from: env.emailFrom,
                 //replyTo: env.emailFrom,
                 subject: "${env.projectName} ${env.JOB_NAME} (${env.BUILD_NUMBER}) build failed",
                 to: env.emailTo
        }
        success {
            mail body: "${env.JOB_NAME} (${env.BUILD_NUMBER}) ${env.projectName} build successful\n" +
                       "Started by ${env.BUILD_CAUSE}",
                 from: env.emailFrom,
                 //replyTo: env.emailFrom,
                 subject: "${env.projectName} ${env.JOB_NAME} (${env.BUILD_NUMBER}) build successful",
                 to: env.emailTo
        }
    }
}
