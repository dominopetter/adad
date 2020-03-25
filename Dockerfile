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

# Dependencies of various R packages
RUN \
    apt-get install -y libcairo2-dev  libxt-dev libgmp3-dev jags libgsl0-dev libx11-dev mesa-common-dev libglu1-mesa-dev libmpfr-dev libfftw3-dev libtiff5-dev libiodbc2-dev libudunits2-dev libopenmpi-dev libmysqlclient-dev -y

# Required for rJava
RUN \
    export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server && \
    echo "export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server:\${LD_LIBRARY_PATH:-}" >> /home/ubuntu/.domino-defaults && \
    R CMD javareconf

# Install R packages required by Domino
RUN \
    R -e 'options(repos=structure(c(CRAN="http://cran.us.r-project.org"))); install.packages(c( "plumber","yaml", "shiny"))'

# Install R packages
RUN \
    apt-get install libgdal-dev -y && \
    R -e "install.packages('rgdal',repos='https://cran.revolutionanalytics.com/')" && \
    R -e 'options(repos=structure(c(CRAN="http://cran.us.r-project.org"))); install.packages(c( "devtools", "stringi", "httpuv","RJSONIO", "Cairo", "jsonlite","RJDBC"))' && \
    R --no-save -e "install.packages(c('tidyverse','domino','feather','choroplethr', 'choroplethrMaps','DT','ggvis'), repos='https://cran.revolutionanalytics.com/',clean=TRUE,Ncpus = getOption('Ncpus', 4L))" && \
    R --no-save -e 'install.packages(c("keras","sparklyr","mongolite","forecast","abind", "acepack", "ade4", "akima", "alr3","ape", "argparse", "assertthat", "aws.s3", "aws.signature", "backports", "base64", "base64enc", "BH", "bibtex", "biglm", "bit", "bit64", "bitops", "BradleyTerry2", "brew", "brglm", "BTYD", "bvls", "car", "caret"),repos="https://cran.revolutionanalytics.com/",clean=TRUE,Ncpus = getOption("Ncpus", 4L))' && \
    R --no-save -e 'install.packages(c("caTools",  "chron", "circular", "clue", "clusterGeneration", "coda", "coin", "colorRamps", "colorspace", "combinat", "contfrac", "corpcor", "corrgram", "corrplot", "crayon", "curl", "data.table", "DBI", "deldir", "dendextend", "DEoptimR", "deSolve", "devtools", "dichromat", "digest", "diptest", "dmt", "doMC", "doParallel", "doRedis"),repos="https://cran.revolutionanalytics.com/",clean=TRUE,Ncpus = getOption("Ncpus", 4L))' && \
    R --no-save -e 'install.packages(c("doRNG", "dynlm", "e1071", "earth", "elasticnet", "ellipse", "elliptic", "evaluate", "expm", "extrafont", "extrafontdb", "fastICA", "fastmatch", "fBasics", "ff", "findpython", "flexmix", "FMStable", "foreach", "forecast", "formatR", "Formula", "fpc", "fracdiff", "gains", "gam", "gbm", "gclus", "gdata", "gee"),repos="https://cran.revolutionanalytics.com/",clean=TRUE,Ncpus = getOption("Ncpus", 4L))' && \
    rm -rf /usr/local/lib/R/site-library/XLConnect/unitTests/resources/testBug61.xlsx && \
    chown -R ubuntu:ubuntu /usr/local/lib/R/site-library