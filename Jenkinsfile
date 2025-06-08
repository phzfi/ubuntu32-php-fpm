def CHANGELOG
def PROJECT_NAME = "ubuntu32-php-fpm"
def SLACK_CHANNEL = "#marketing"
pipeline {
  agent {
    label 'slave && docker'
  }

  environment {
    BRANCH_NAME = "${GIT_BRANCH}"
    BUILD_ENV = [master: 'prod', develop: 'stg'].get(GIT_BRANCH, 'dev')
    VERSION = "${currentBuild.number}"
    SERVICE_NAME = "${PROJECT_NAME}-${BUILD_ENV}"
  }

  options {
    ansiColor('xterm')
    gitLabConnection('ubuntu32')
    //skipDefaultCheckout(true)
    //set default pipeline timeout to 3hours if there is a jam, it will abort automatically
    timeout(time: 180, unit: 'MINUTES')
  }

  triggers {
    gitlab(triggerOnPush: true, triggerOnMergeRequest: true, branchFilterType: 'All')
    //TODO scheduled builds every month or week does the security updates + promotes activity
    //pollSCM('H/5 8-20 1-6 * *')
  }

  stages {
    stage("Prepare") {
      steps {
        script {
          echo "Parse changelog"
          def changeLogSets = currentBuild.rawBuild.changeSets
          CHANGELOG = ""
          for (int i = 0; i < changeLogSets.size(); i++) {
            def entries = changeLogSets[i].items
            for (int j = 0; j < entries.length; j++) {
              def entry = entries[j]
              CHANGELOG = CHANGELOG + "${entry.author}: ${entry.msg}\n"
            }
          }

          //prevent Jenkins double builds, check if changelog is empty, skip
          if (CHANGELOG && CHANGELOG.trim().length() == 0) {
            currentBuild.result = 'SUCCESS'
            return
          }
        }
        echo "Changelog:\n${CHANGELOG}"

        echo "Debug branch name"
        echo "env.gitlabBranch: " + env.gitlabBranch
        echo "scm.branches[0].name: " + scm.branches[0].name
        echo "{GIT_BRANCH}: " + "${GIT_BRANCH}"
        echo "BRANCH_NAME is set to: " + "${BRANCH_NAME}"

        checkout scm
        updateGitlabCommitStatus name: 'Clean', state: 'success'
      }
    }

    stage("Clean") {
      steps {
        script {
          sh "./down.sh > /dev/null 2>&1 || true"
          sh "./clean.sh > /dev/null 2>&1 || true"
          sh "sudo chown -R jenkins:jenkins ."
        }
      }
    }

    stage("Provision") {
      steps {
        echo "Provision Branch ${BRANCH_NAME} with Env ${BUILD_ENV}"
        timeout(30) {
          echo "Start provisioning"
        }

        updateGitlabCommitStatus name: 'Provision', state: 'success'
      }
    }

    stage("Build") {
      when {
        expression {[master: true, develop: true].get(BRANCH_NAME, false)}
      }
      steps {
        withCredentials([
          [$class: 'UsernamePasswordMultiBinding', credentialsId: 'DOCKER_HUB', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD']
        ]) {
          timeout(400) {
            sh script:"./docker/build.sh prod 7.4 ${VERSION} ${DOCKER_HUB_USERNAME} ${DOCKER_HUB_PASSWORD}", returnStatus:true
            sh script:"./docker/build.sh prod 8.0 ${VERSION} ${DOCKER_HUB_USERNAME} ${DOCKER_HUB_PASSWORD}", returnStatus:true
            sh script:"./docker/build.sh prod 8.1 ${VERSION} ${DOCKER_HUB_USERNAME} ${DOCKER_HUB_PASSWORD}", returnStatus:true
          }
        }

        updateGitlabCommitStatus name: 'Build & Publish', state: 'success'
      }
    }

    stage("Quality") {
      steps {
        echo "Running Code Quality checks"
        timeout(15) {
          sh script:"docker-compose -f docker-compose.prod.yml up -d", returnStatus:true
          //sh script:"./up.sh", returnStatus:true
          //sh script:"docker exec -it ubuntu32-php-fpm_master_app_1 /opt/syntax-check.sh", returnStatus:true
        }

        updateGitlabCommitStatus name: 'Quality', state: 'success'
      }
    }

    stage("Unit Test") {
      steps {
        echo "Running unit tests"
        timeout(15) {
          sh script:"docker-compose -f docker-compose.prod.yml run test", returnStatus:true
          junit 'reports/TEST-default.xml'
        }

        updateGitlabCommitStatus name: 'Unit Test', state: 'success'
      }
    }

    stage("Acceptance Test") {
      when {
        expression {[master: true, develop: true].get(BRANCH_NAME, false)}
      }
      steps {
        echo "Running Acceptance Tests"
//        build job: 'another-job', propagate: false

        updateGitlabCommitStatus name: 'Acceptance Test', state: 'success'
      }
    }

    stage("Tag") {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'git-ssh-ci', keyFileVariable: 'SSH_KEY')]) {
          script {
            if (env.BUILD_ENV != 'dev') {
              sshagent(credentials: ['git-ssh-ci']) {
                sh('set +x && '
                + 'TAG_NAME="' + env.BUILD_ENV + '-' + env.VERSION + '" && '
                + 'git tag -d $TAG_NAME || true && ' // delete 'exists' tag from local git repository. (if previous push failed)
                + 'git tag -a $TAG_NAME -m Jenkins && '   // create new tag.
                + 'git push origin $TAG_NAME --no-verify' // push the new tag.
                )
              }
            } else {
              echo "Skipping Git Tag for git development branches..."
            }
          }
        }
      }
    }

  }
  post {
    always {
      script {
        sh "./down.sh || true"
        sh "sudo chown -R jenkins:jenkins ."
      }
    }
    success {
      script {
          //slackSend channel: "${SLACK_CHANNEL}", color: "green", message: "${PROJECT_NAME} ${env.BUILD_ENV}-${env.BUILD_NUMBER} build succeeded! Please download container for Smoke Testing: ${PROJECT_LOCATION}). After Smoke Tests (see README.md #4.1), please Add Reaction thumbsup or thumbsdown depending whether Smoke Test cases pass or not.\n${CHANGELOG}", notifyCommitters: true
        }
      }
    }
    unstable {
        slackSend channel: "${SLACK_CHANNEL}", color: "yellow", message: "UNSTABLE: ${PROJECT_NAME} ${env.BUILD_ENV}-${env.BUILD_NUMBER} See (${env.RUN_DISPLAY_URL}) - more unit tests and code coverage needed for branch ${BRANCH_NAME}", notifyCommitters: true

        emailext (
          subject: "Unstable: ${PROJECT_NAME} ${env.BUILD_ENV}-${env.BUILD_NUMBER}",
          body: """${PROJECT_NAME} build become unstable (test coverage is not enough): '${env.BUILD_ENV}-${env.BUILD_NUMBER}':
            Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.BUILD_ENV}-${env.BUILD_NUMBER}</a>&QUOT;""",
          recipientProviders: [[$class: 'DevelopersRecipientProvider']]
        )
    }
    failure {
        slackSend channel: "${SLACK_CHANNEL}", color: "red", message: "FAIL: ${PROJECT_NAME} ${env.BUILD_ENV}-${env.BUILD_NUMBER} See (${env.RUN_DISPLAY_URL}) for the reason and please fix the branch ${BRANCH_NAME} and code to pass again", notifyCommitters: true

        emailext (
          subject: "FAIL: ${PROJECT_NAME} ${env.BUILD_ENV}-${env.BUILD_NUMBER}",
          body: """${PROJECT_NAME} build failed: '${env.JOB_NAME} [${env.BUILD_NUMBER}]':
            Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.BUILD_ENV}-${env.BUILD_NUMBER}</a>&QUOT;""",
          recipientProviders: [[$class: 'DevelopersRecipientProvider']]
        )
    }
  }
}

