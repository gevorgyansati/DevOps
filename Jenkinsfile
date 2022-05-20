pipeline {
  agent any
  environment {
    COMMIT_SHA_AFTER_TEST = ""
    TAG_NAME = ""
    COMMIT_SHA = ""
    REPO_LINK = ""
  }
  stages {
    stage("Initialize Variables Describing Developer Repo") {
      steps {
        script {
          TAG_NAME = sh """ /bin/bash readDevData.sh TAG """
          COMMIT_SHA = sh """ /bin/bash readDevData.sh COMMIT """
          REPO_LINK = sh """ /bin/bash readDevData.sh LINK """
        }
      }
    }
    stage("Compare TAG Before test & TAG after test") {
      steps {
        script {
          COMMIT_SHA_AFTER_TEST = sh returnStdout: true, script: "/bin/bash GetCommitHash.sh ${REPO_LINK} ${TAG_NAME}"
          error("Commit hashes are not equal each other")
          dir('DevRepo') {
            git clone --depth 1 --branch ${TAG_NAME} ${REPO_LINK}
          }
        }
      }
    }
    stage("Build Image of Developer Repo application") {
      steps {
        sh "docker build -t my-app:${TAG_NAME} -f DevRepo/Dockerfile ."
      }
    }
  }
}
