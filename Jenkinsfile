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
          COMMIT_SHA = sh returnStdout: true, script: """ /bin/bash readDevData.sh COMMIT """
          REPO_LINK = sh returnStdout: true, script: """ /bin/bash readDevData.sh LINK """
        }
      }
    }
    stage("Compare TAG Before test & TAG after test") {
      steps {
        script {
          COMMIT_SHA_AFTER_TEST = sh returnStdout: true, script: "/bin/bash GetCommitHash.sh ${REPO_LINK} ${TAG_NAME}"
          if("${COMMIT_SHA_AFTER_TEST}" != "${COMMIT_SHA}") {
            error("Commit hashes are not equal each other")
          }
          
          dir('DevRepo') {
            sh """git clone --depth 1 --branch ${TAG_NAME} ${REPO_LINK}"""
          }
        }
      }
    }
    stage("Build Image of Developer Repo application") {
      steps {
        sh "docker build -f ./DevRepo/ -t my-app:${TAG_NAME} ."
      }
    }
  }
}