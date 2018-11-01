FROM ruby:2.5.1
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential nodejs && apt-get clean
RUN gem install foreman
RUN apt-get install apt-utils -y

# Install Java JDK for communication between agent and master
RUN apt-get update
RUN apt-get install default-jdk -y

# Install Cloud Foundry CLI
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
RUN echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN apt-get install apt-transport-https ca-certificates -y
RUN apt-get update
RUN apt-get install cf-cli

# Install Jenkins Agent - Master communication requirements
ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

USER root
ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}

ARG VERSION=3.20
ARG AGENT_WORKDIR=/home/${user}/agent
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}
VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

USER root
RUN curl --create-dirs -SLo /usr/local/bin/jenkins-slave https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/master/jenkins-slave \
  && chmod 755 /usr/local/bin/jenkins-slave


# Copy app source code and install dependancies
WORKDIR /usr/src/app
ADD Gemfile Gemfile.lock ./
RUN bundle install
ADD . $APP_HOME
COPY . .

RUN chown ${user} /usr/src/app
USER jenkins
WORKDIR /home/jenkins
