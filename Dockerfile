FROM ubuntu:18.04

LABEL maintainer="Petter Olsson <petter.olsson@dominodatalab.com>"
LABEL name="Accelerated Domino Analytics Distribution"

# Utilities required by Domino
ENV DEBIAN_FRONTEND noninteractive

# Create the Ubuntu User
RUN \
  groupadd -g 12574 ubuntu && \
  useradd -u 12574 -g 12574 -m -N -s /bin/bash ubuntu

# Update, Upgrade, and Add repositories
RUN \
  apt-get update -y && \
  apt-get -y install software-properties-common apt-utils && \
  apt-get -y upgrade

# Configure Locales
RUN \
  apt-get install -y locales && \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales

# Install common
RUN \
  apt-get -y install build-essential wget sudo curl apt-utils net-tools libzmq3-dev ed git ca-certificates iputils-ping dnsutils telnet apt-transport-https vim python3-pip jq && \
  apt-get install openjdk-8-jdk -y && \
  update-alternatives --config java && \
  echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/ubuntu/.domino-defaults && \
  apt-get -y install libssl-dev libxml2-dev libxt-dev libssh2-1-dev libcurl4-openssl-dev libsasl2-dev libssl-dev

# Install AWS Cli
RUN \
  apt-get install awscli -y

# Add ssh start script for ssh'ing to run container in Domino <v4.0
RUN \
  apt-get install openssh-server -y && \
  mkdir -p /scripts && \
  printf "#!/bin/bash\\nservice ssh start\\n" > /scripts/start-ssh && \
  chmod +x /scripts/start-ssh && \
  \
  echo 'export PYTHONIOENCODING=utf-8' >> /home/ubuntu/.domino-defaults && \
  echo 'export LANG=en_US.UTF-8' >> /home/ubuntu/.domino-defaults && \
  echo 'export JOBLIB_TEMP_FOLDER=/tmp' >> /home/ubuntu/.domino-defaults && \
  echo 'export LC_ALL=en_US.UTF-8' >> /home/ubuntu/.domino-defaults && \
  locale-gen en_US.UTF-8 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install R
RUN \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' && \
    apt-get update -y && \
    apt-get install r-base r-base-dev -y