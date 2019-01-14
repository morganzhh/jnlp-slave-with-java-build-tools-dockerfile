FROM cloudbees/java-build-tools

USER root

#change start
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    apt-utils \
    libprotoc-dev \
    protobuf-compiler \
    libprotobuf-java \
    rpm \
    docker \
    gradle \
    file
#change end

#DOCKER
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN usermod -aG docker jenkins
VOLUME /var/run/docker.sock
RUN groupmod -g 992 docker

RUN npm install -g bower

ARG JENKINS_REMOTING_VERSION=3.23

# See https://github.com/jenkinsci/docker-slave/blob/master/Dockerfile#L31
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

#Maven requires java executable in /bin, create a soft link
RUN ln -s /usr/bin/java /bin/java

RUN chmod a+rwx /home/jenkins
WORKDIR /home/jenkins
USER jenkins

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]

