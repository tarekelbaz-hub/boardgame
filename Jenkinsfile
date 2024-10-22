def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]
pipeline {
	agent any
	tools {
		jdk 'jdk17'
		maven 'maven3'
	}
	environment {
		SCANNER_HOME= tool 'sonar-scanner'
	}
	stages {
		stage('Git Checkout') {
			steps {
				git branch: 'main', credentialsId: 'git-cred', url:'https://github.com/tarekelbaz-hub/boardgame.git'
			}
		}
		stage('Compile') {
			steps {
				sh "mvn compile"
			}
		}
		stage('Test') {
			steps {
				sh "mvn test"
			}
		}
		stage('File System Scan') {
		steps {
				sh "trivy fs --format table -o trivy-fs-report.html ."
		 	}
		 }
		 stage('SonarQube Analsyis') {
		 	steps {
		 		withSonarQubeEnv('sonar-scanner') {
		 			sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=BoardGame -Dsonar.projectKey=BoardGame \
		 			-Dsonar.java.binaries=. '''
		 		}
		 	}
		 }
		stage('Quality Gate') {
			steps {
				script {
					waitForQualityGate abortPipeline: false, credentialsId: 'sonar-scanner'
				}
			}
		}
		stage('Build') {
			steps {
				sh "mvn package"
			}
		}
		stage('Publish To Nexus') {
            steps {
                    withMaven(globalMavenSettingsConfig: 'global-settingss', jdk: 'jdk17',maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                        sh "mvn deploy"
                    }
        	}
        }
		stage('Build & Tag Docker Image') {
			steps {
				script {
					withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker') {
						sh "docker build -t tarekelbaz/boardshack:latest ."
					}
				}
			}
		}
// 		stage('Docker Image Scan') {
// 			steps {
// 				sh "trivy image --format table -o trivy-image-report.html tarekelbaz/boardshack:latest"
// 			}
// 		}
		stage('Push Docker Image') {
			steps {
				script {
					withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker') {
						sh "docker push tarekelbaz/boardshack:latest"
					}
				}
			}
		}
		stage('Deploy To Kubernetes') {
			steps {
				withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '',
				credentialsId: 'kubernetes-admin', namespace: 'webapps', restrictKubeConfigAccess: false,
				serverUrl: 'https://192.168.10.150:6443') {
					sh "kubectl apply -f deployment-service.yaml"
				}
			}
		}
		stage('Verify the Deployment') {
			steps {
				withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '',
				credentialsId: 'kubernetes-admin', namespace: 'webapps', restrictKubeConfigAccess: false,
				serverUrl: 'https://192.168.10.150:6443') {
					sh "kubectl get pods -n webapps"
					sh "kubectl get svc -n webapps"
				}
			}
		}
	}
	post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#boardgame',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}