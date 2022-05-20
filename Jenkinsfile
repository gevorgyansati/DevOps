pipeline {
  agent any
  environment {
    COMMIT_SHA_AFTER_TEST = ""
    TAG_NAME = ""
    COMMIT_SHA = ""
    REPO_LINK = ""
  }
  stages {
    stage("Initialize Variables") {
      steps {
        script {
          TAG_NAME = sh returnStdout: true, script: """ /bin/bash readDevData.sh TAG """
          TAG_NAME = TAG_NAME.trim();
          COMMIT_SHA = sh returnStdout: true, script: """ /bin/bash readDevData.sh COMMIT """
          COMMIT_SHA = COMMIT_SHA.trim();
          REPO_LINK = sh returnStdout: true, script: """ /bin/bash readDevData.sh LINK """
          REPO_LINK = REPO_LINK.trim();
        }
      }
    }
    stage("Compare TAG Before test & TAG after test") {
      steps {
        script {
          COMMIT_SHA_AFTER_TEST = sh returnStdout: true, script: """/bin/bash GetCommitHash.sh "${REPO_LINK}" "${TAG_NAME}" """
          COMMIT_SHA_AFTER_TEST = COMMIT_SHA_AFTER_TEST.trim();
          echo COMMIT_SHA_AFTER_TEST
          if("${COMMIT_SHA_AFTER_TEST}" != "${COMMIT_SHA}") {
            error("Commit hashes are not equal each other")
          }
          
            sh """git clone --depth 1 --branch "${TAG_NAME}" "${REPO_LINK}" """
        }
      }
    }
    stage("Build Image of Developer Repo application") {
      steps {
        sh "docker build -f ./DevRepo/Dockerfile -t my-app:${TAG_NAME} ."
      }
    }
  }
  post {
    always {
      sh "rm -rf DevRepo" 
    }
  }
}
