FROM docker.io/bitnami/jenkins:2

USER 0

RUN apt-get update

RUN apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update

RUN apt-get -y install docker-ce

RUN apt-get -y install docker-compose
