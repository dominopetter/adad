FROM ubuntu:18.04

LABEL maintainer="Domino Data Lab <support@dominodatalab.com>"

#### Utilities required by Domino ####
ENV DEBIAN_FRONTEND noninteractive

#create a Ubuntu User
RUN \
  groupadd -g 12574 ubuntu && \
  useradd -u 12574 -g 12574 -m -N -s /bin/bash ubuntu && \

  # UPDATE, UPGRADE, ADD repositories
  apt-get update -y && \
  apt-get -y install software-properties-common && \
  apt-get -y upgrade && \
  # CONFIGURE locales
  apt-get install -y locales && \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales && \
  # INSTALL common
  apt-get -y install build-essential wget sudo curl apt-utils net-tools libzmq3-dev ed git ca-certificates iputils-ping dnsutils telnet apt-transport-https vim python3-pip jq && \
  apt-get install openjdk-8-jdk -y && \
  update-alternatives --config java && \
  echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/ubuntu/.domino-defaults && \
  apt-get -y --no-install-recommends install libssl-dev libxml2-dev libxt-dev libssh2-1-dev libcurl4-openssl-dev libsasl2-dev libssl-dev && \
  #apt AWS CLI
  apt-get install awscli -y  && \
  # ADD SSH start script for ssh'ing to run container in Domino <v4.0
  apt-get install openssh-server -y && \
  mkdir -p /scripts && \
  printf "#!/bin/bash\\nservice ssh start\\n" > /scripts/start-ssh && \
  chmod +x /scripts/start-ssh && \
  
  echo 'export PYTHONIOENCODING=utf-8' >> /home/ubuntu/.domino-defaults && \
  echo 'export LANG=en_US.UTF-8' >> /home/ubuntu/.domino-defaults && \
  echo 'export JOBLIB_TEMP_FOLDER=/tmp' >> /home/ubuntu/.domino-defaults && \
  echo 'export LC_ALL=en_US.UTF-8' >> /home/ubuntu/.domino-defaults && \
  locale-gen en_US.UTF-8 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
    
ENV LANG en_US.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

###### Install R #####
###### 4.0.1 should be out 2020-06-08 #####
ENV R_BASE_VERSION 4.0.1

RUN \ 
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/' && \
    apt-get update -y && \
    apt-get install \ 
    r-base=${R_BASE_VERSION}-* \
  r-base-dev=${R_BASE_VERSION}-* -y && \
#dependencies of various R packages
    apt-get install -y libcairo2-dev  libxt-dev libgmp3-dev jags libgsl0-dev libx11-dev mesa-common-dev libglu1-mesa-dev libmpfr-dev libfftw3-dev libtiff5-dev libiodbc2-dev libudunits2-dev libopenmpi-dev libmysqlclient-dev -y && \
#required for rJava
    export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server && \
    echo "export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server:\${LD_LIBRARY_PATH:-}" >> /home/ubuntu/.domino-defaults && \
    R CMD javareconf && \
# INSTALL R packages required by Domino
    R -e 'options(repos=structure(c(CRAN="http://cran.us.r-project.org"))); install.packages(c( "plumber","yaml", "shiny"))' && \
#install R packages
    apt-get install libgdal-dev -y && \
    R -e "install.packages('rgdal',repos='https://cran.revolutionanalytics.com/')" && \
    R -e 'options(repos=structure(c(CRAN="http://cran.us.r-project.org"))); install.packages(c( "devtools", "stringi", "httpuv","RJSONIO", "Cairo", "jsonlite","RJDBC"))' && \
    R --no-save -e 'install.packages(c("keras","sparklyr","mongolite","forecast","abind", "acepack", "ade4", "akima", "alr3","ape", "argparse", "assertthat", "aws.s3", "aws.signature", "backports", "base64", "base64enc", "BH", "bibtex", "biglm", "bit", "bit64", "bitops", "BradleyTerry2", "brew", "brglm", "BTYD", "bvls", "car", "caret", "caTools",  "chron", "circular", "clue", "clusterGeneration", "coda", "coin", "colorRamps", "colorspace", "combinat", "contfrac", "corpcor", "corrgram", "corrplot", "crayon", "curl", "data.table", "DBI", "deldir", "dendextend", "DEoptimR", "deSolve", "devtools", "dichromat", "digest", "diptest", "dmt", "doMC", "doParallel", "doRedis", "doRNG", "dynlm", "e1071", "earth", "elasticnet", "ellipse", "elliptic", "evaluate", "expm", "extrafont", "extrafontdb", "fastICA", "fastmatch", "fBasics", "ff", "findpython", "flexmix", "FMStable", "foreach", "forecast", "formatR", "Formula", "fpc", "fracdiff", "gains", "gam", "gbm", "gclus", "gdata", "gee", "geepack", "geiger", "getopt", "ggfortify", "git2r", "glmnet", "gmp", "gplots", "googlesheets","gridExtra", "gss", "gtable", "gtools", "h2o", "hexbin", "hflights", "highlight", "highr", "Hmisc", "htmltools", "htmlwidgets", "httpuv", "httr", "hypergeo", "igraph", "igraphdata", "inline", "intervals", "ipred", "IRdisplay", "IRkernel", "iterators", "itertools", "jpeg", "jsonlite", "kernlab", "KFAS", "klaR", "knitr", "labeling", "Lahman", "lars", "lasso2", "lattice", "latticeExtra", "lava", "lazyeval", "lda", "LDPD", "leaflet","leaps", "LearnBayes", "lme4", "lmtest", "locfit", "logspline", "lokern", "lpSolve", "lubridate", "magrittr", "mailR", "mapproj", "maps", "maptools", "markdown", "MARSS", "MatrixModels", "matrixStats", "mclust", "mda", "memoise", "mgcv", "mice", "microbenchmark", "mime", "miniUI", "minqa", "misc3d", "mix", "mixtools", "mlbench", "mnormt", "modeltools", "msm", "multcomp", "munsell", "mvtnorm", "ncbit", "nleqslv", "nloptr", "NLP", "nnls", "nor1mix", "numDeriv", "nws", "OAIHarvester", "openssl", "pander", "party", "pbkrtest", "PerformanceAnalytics", "permute", "phangorn", "pheatmap", "phylobase", "picante", "pipeR", "pixmap", "pkgmaker", "plotly", "plotmo", "plotrix", "pls", "plyr", "png", "polspline", "PortfolioAnalytics", "ppcor", "prabclus", "pROC", "prodlim", "profileModel", "proto", "proxy", "psych", "qap", "quadprog", "Quandl", "quantmod", "quantreg", "R2jags", "R2WinBUGS", "R6", "randomForest", "RANN", "rbenchmark", "R.cache", "RColorBrewer", "Rcpp", "RcppArmadillo", "RcppEigen", "RcppGSL", "RcppRoll", "RCurl", "R.devices", "registry", "relations", "repr", "reshape", "reshape2", "R.filesets", "RGCCA", "rgl", "RGraphics", "R.huge", "ridge", "rjags", "rJava", "rjson", "RJSONIO", "rlecuyer", "rmarkdown", "R.methodsS3", "Rmpfr", "Rmpi", "rms", "rngtools", "robustbase", "ROCR", "R.oo", "Rook", "roxygen2", "RPMM", "rprojroot", "rredis", "R.rsp", "Rserve", "RSQLite", "rstan", "rstudioapi", "Rttf2pt1", "RUnit", "R.utils", "rversions", "rzmq", "sandwich", "scales", "scatterplot3d", "segmented", "seriation", "sets", "sfsmisc", "shinydashboard", "shinyjs", "sitools", "sjmisc", "sjPlot", "slackr", "slam", "sm", "snow", "SnowballC", "snowfall", "sourcetools", "sp", "spam", "SparseM", "spdep", "spls", "stabledist", "stargazer", "statmod", "stringi", "strucchange", "subplex", "survey", "tables", "TeachingDemos", "testthat", "TH.data", "tiff", "timeDate", "timeSeries", "tm", "topicmodels", "trimcluster", "tripack", "tseries", "TSP", "TTR", "tweedie", "uuid", "vcd", "vegan", "VGAM", "VGAMdata", "viridis", "whisker", "xgboost", "XLConnect", "XLConnectJars", "xlsx", "xlsxjars", "XML", "xml2", "xtable", "xts", "zoo", "base", "boot", "class", "cluster", "codetools", "compiler", "datasets", "foreign", "graphics", "grDevices", "grid", "KernSmooth", "lattice", "MASS", "Matrix", "methods", "mgcv", "nlme", "nnet", "parallel", "rpart", "spatial", "splines", "stats", "stats4", "survival", "tcltk", "tools", "utils"),repos="https://cran.revolutionanalytics.com/",clean=TRUE,Ncpus = getOption("Ncpus", 4L))' && \
    R --no-save -e "install.packages(c('tidyverse','domino','feather','choroplethr', 'choroplethrMaps','DT','ggvis'), repos='https://cran.revolutionanalytics.com/',clean=TRUE,Ncpus = getOption('Ncpus', 4L))" && \
    rm -rf /usr/local/lib/R/site-library/XLConnect/unitTests/resources/testBug61.xlsx && \
    chown -R ubuntu:ubuntu /usr/local/lib/R/site-library && \
#Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /tmp/*


######Install Python 3.8 and Miniconda######
#Inspriration: https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile

# https://repo.continuum.io/miniconda/
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH 
ENV MINICONDA_VERSION py38_4.8.2     
ENV MINICONDA_MD5 cbda751e713b5a95f187ae70b509403f
ENV PYTHON_VER 3.8

#set env variables so they are available in Domino runs/workspaces
RUN \
    echo 'export CONDA_DIR=/opt/conda' >> /home/ubuntu/.domino-defaults && \
    echo 'export PATH=$CONDA_DIR/bin:$PATH' >> /home/ubuntu/.domino-defaults && \
    echo 'export PATH=/home/ubuntu/.local/bin:$PATH' >> /home/ubuntu/.domino-defaults && \

#Install Python and Mini-conda
    cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
#Specify the python version
    conda install python=${PYTHON_VER} && \
#make conda folder permissioned for ubuntu user
    chown ubuntu:ubuntu -R $CONDA_DIR && \
# Use Mini-conda's pip
    ln -s $CONDA_DIR/bin/pip /usr/bin/pip && \
# Use Mini-conda's python   
    ln -s $CONDA_DIR/bin/python /usr/local/bin/python && \
    ln -s $CONDA_DIR/anaconda/bin/python /usr/local/bin/python3  && \
#Set permissions
    chown -R ubuntu:ubuntu  $CONDA_DIR && \
#Upgrade Pip
    pip install --upgrade pip && \

#Add various package dependencies and useful libraries
    apt-get update && \
    apt-get install -y --no-install-recommends libhdf5-dev libyaml-dev pkg-config libfuse-dev cups libcups2-dev python-gi python-gi-cairo python3-gi python3-gi-cairo gir1.2-gtk-3.0 python-mvpa2 libsmbclient-dev libcups2-dev python-debian python-igraph swig  && \

###Install Domino Dependencies ####  
#packages used for model APIs and Apps
    $CONDA_DIR/bin/conda install -c conda-forge uWSGI==2.0.18 && \
    pip install Flask==1.0.2 Flask-Compress==1.4.0 Flask-Cors==3.0.6 jsonify==0.5 && \

### Install packages used in Domino quick-start project
    pip install git+https://github.com/dominodatalab/python-domino.git && \

## Additional packages in full anaconda 5.3.1 but not mini-conda 4.7.12.1
    pip install \
    alabaster==0.7.12 \
    appdirs==1.4.3 \
    astroid==2.3.3 \
    astropy==3.2.3 \
    atomicwrites==1.3.0 \
    Automat==0.8.0 \
    Babel==2.8.0 \
    backports.shutil-get-terminal-size==1.0.0 \
    beautifulsoup4==4.8.2 \
    bitarray==0.9.3 \
    bkcharts==0.2 \
    # 0.11.3 not on pypi so reverting to 0.10.1
    blaze==0.10.1 \
    bokeh==1.4.0 \
    boto==2.49.0 \
    Bottleneck==1.3.2 \
    click==6.7 \
    cloudpickle==0.8.1 \
    # 1.2.2 not on pypi so reverting to 1.2.1
    clyent==1.2.1 \
    colorama==0.4.3 \
    #not required
    constantly==15.1.0 \
    contextlib2==0.6.0 \
    cycler==0.10.0 \
    Cython==0.29.15 \
    cytoolz==0.10.1 \
    dask==2.12.0 \
    #0.5.4 not on pypi so reverting to 0.5.2
    datashape==0.5.2 \
    distributed==1.28.1 \
    docutils==0.16 \
    et-xmlfile==1.0.1 \
    fastcache==1.1.0 \
    filelock==3.0.12 \
    gevent==1.4.0 \
    glob2==0.7 \
    greenlet==0.4.15 \
    h5py==2.10.0 \
    heapdict==1.0.1 \
    html5lib==1.0.1 \
    hyperlink==18.0.0 \
    imageio==2.8.0 \
    imagesize==1.2.0 \
    incremental==17.5.0 \
    isort==4.3.21 \
    itsdangerous==0.24 \
    jdcal==1.4.1 \
    jeepney==0.4.3 \
    keras==2.3.1 \
    keyring==13.2.1 \
    kiwisolver==1.1.0 \
    lazy-object-proxy==1.4.3 \
    llvmlite==0.31.0 \
    locket==0.2.0 \
    lxml==4.5.0 \
    matplotlib==2.2.5 \
    mccabe==0.6.1 \
    #1.0.4 not available using 1.0.5
    mpmath==1.0.0 \
    msgpack==0.6.2 \
    multipledispatch==0.6.0 \
    #not required. Only used with anaconda
    networkx==2.4 \
    nltk==3.4.5 \
    nose==1.3.7 \
    numba==0.48.0 \
    numexpr==2.7.1 \
    numpy==1.18.2 \
    numpydoc==0.9.2 \
    # # 0.5.1 not on pypi so reverting to 0.5.0
    odo==0.5.0 \
    olefile==0.46 \
    openpyxl==2.6.4 \
    packaging==17.1 \
    pandas==0.25.3 \
    partd==0.3.10 \
    path.py==11.5.2 \
    pathlib2==2.3.5 \
    patsy==0.5.1 \
    pep8==1.7.1 \
    Pillow==5.4.1 \
    pkginfo==1.5.0 \
    pluggy==0.13.1 \
    ply==3.11 \
    psutil==5.7.0 \
    py==1.6.0 \
    pyasn1==0.4.8 \
    pyasn1-modules==0.2.8 \
    pycodestyle==2.5.0 \
    pycrypto==2.6.1 \
    pycurl==7.43.0.5 \
    pyflakes==2.1.1 \
    pylint==2.4.4 \
    pyparsing==2.4.6 \
    pytest==3.10.0 \
    pytest-arraydiff==0.3 \
    pytest-astropy==0.8.0 \
    pytest-doctestplus==0.5.0 \
    pytest-openfiles==0.3.0 \
    pytest-remotedata==0.3.2 \
    pytz==2018.9 \
    PyWavelets==1.1.1 \
    PyYAML==3.13 \
    QtAwesome==0.7.0 \
    QtPy==1.9.0 \
    rope==0.16.0 \
    scikit-image==0.16.2 \
    scikit-learn==0.22.2 \
    scipy==1.4.1 \
    seaborn==0.10.0 \
    SecretStorage==3.1.2 \
    service-identity==17.0.0 \
    simplegeneric==0.8.1 \
    singledispatch==3.4.0.3 \
    snowballstemmer==1.9.1 \
    sortedcollections==1.1.2 \
    sortedcontainers==2.1.0 \
    Sphinx==1.8.5 \
    sphinxcontrib-websupport==1.2.0 \
    spyder==4.1.1 \
    spyder-kernels==1.9.0 \
    SQLAlchemy==1.3.15 \
    statsmodels==0.11.1 \
    sympy==1.5.1 \
    tables==3.6.1 \
    tblib==1.6.0 \
    tensorflow-gpu \
    toolz==0.10.0 \
    Twisted==18.9.0 \
    unicodecsv==0.14.1 \
    Werkzeug==0.16.1 \
    wrapt==1.12.1 \
    xlrd==1.2.0 \
    XlsxWriter==1.2.8 \
    xlwt==1.3.0 \
    zict==0.1.4 \
    zope.interface==4.7.2 \
    ###Install addition useful Data Science Python Packages
    cairocffi==1.1.0 \
    jaydebeapi==1.1.1 \
    jpype1==0.7.2 \
    bson==0.5.9 \
    pypandoc==1.4 \
    ggplot==0.11.5 \
    mpltools==0.2.0 \
    websocket==0.2.1 && \     
    notebook==5.7.5 && \
    #jupyter-console==5.2.0 && \
    apt-get install libgmp-dev libmpfr-dev libmpc-dev -y && \
    pip install gmpy2==2.0.8 && \

    $CONDA_DIR/bin/conda install mkl_fft==1.0.6 mkl_random && \
    
    apt-get install unixodbc-dev -y && \
    pip install pyodbc==4.0.30 && \
    
    apt-get install -y pandoc && \
#configure matplotlib
    mkdir -p /home/ubuntu/.config/matplotlib && \
    echo "backend : Cairo" > /home/ubuntu/.config/matplotlib/matplotlibrc  && \
    sed -i 's/backend      : TkAgg/backend      : Cairo/g' /opt/conda/lib/python3.8/site-packages/matplotlib/mpl-data/matplotlibrc && \

#Kerberos
    apt-get install krb5-kdc krb5-admin-server -y && \
#clean up
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    $CONDA_DIR/bin/conda clean -afy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /tmp/*

### Install drivers for common data source connections #####
#MSSql Native Drivers 
# Install the SQL Server command-line tools
# Import the public repository GPG keys.
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Register the Microsoft Ubuntu repository.
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

# Update the sources list and run the installation command with the unixODBC developer package.
RUN apt-get update 
RUN ACCEPT_EULA=Y apt-get install -y --no-install-recommends libodbc1 unixodbc freetds-common freetds-dev mssql-tools unixodbc-dev

# Make sqlcmd/bcp accessible from the bash shell for login sessions
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/ubuntu/.bash_profile

# #Oracle
# #ROracle & PyOracle
RUN mkdir -p /opt/oracle && \
    wget -q https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip -O /opt/oracle/instantclient-basic-linuxx64.zip && \
    wget -q https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip -O /opt/oracle/instantclient-sdk-linuxx64.zip && \
    apt-get install libaio1 && \
    cd /opt/oracle && \
    unzip instantclient-basic-linuxx64.zip && \
    unzip instantclient-sdk-linuxx64.zip && \
    echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_6:\${LD_LIBRARY_PATH:-}" >> /home/ubuntu/.domino-defaults && \
    echo 'export OCI_LIB=/opt/oracle/instantclient_19_6' >> /home/ubuntu/.domino-defaults && \
    echo 'export OCI_INC=/opt/oracle/instantclient_19_6/sdk/include' >> /home/ubuntu/.domino-defaults && \
    echo "export PATH=/opt/oracle/instantclient_19_6:\${PATH:-}" >> /home/ubuntu/.domino-defaults && \
    chown -R ubuntu:ubuntu /opt/oracle/instantclient_19_6 && \
    echo '/opt/oracle/instantclient_19_6' > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig -v && \
    export PATH=/opt/oracle/instantclient_19_6:${PATH:-} && \
    export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_6:${LD_LIBRARY_PATH:-} && \
    pip install cx_Oracle  && \
    cd /home/ubuntu && \
    wget -q https://gracie-se.s3.eu-north-1.amazonaws.com/ROracle_1.3-2.tar.gz && \
    R CMD INSTALL --configure-args='--with-oci-inc=/opt/oracle/instantclient_19_6/sdk/include --with-oci-lib=/opt/oracle/instantclient_19_6' ROracle_1.3-2.tar.gz && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/oracle/instantclient-basic-linuxx64.zip && \
    rm -rf /opt/oracle/instantclient-sdk-linuxx64.zip && \
# #Install PostgreSQL client
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && apt-get -y -q install postgresql postgresql-client postgresql-contrib && \
    rm -rf /var/lib/apt/lists/* && \
    R --no-save -e 'install.packages(c("RPostgreSQL","RODBC","RMySQL","RPostgres"))'


# ####### R KERNEL IN JUPYTER ############

 RUN R --no-save -e 'install.packages("pbdZMQ", repos="https://cran.revolutionanalytics.com/", clean=TRUE)'
 USER ubuntu
 RUN R --no-save -e 'devtools::install_github("IRkernel/IRkernel"); IRkernel::installspec()'
 USER root

# ######Scala Kernel
RUN cd /tmp && wget -q https://downloads.lightbend.com/scala/2.12.6/scala-2.12.6.deb && dpkg -i scala-2.12.6.deb && apt-get update -y && apt-get install scala -y --allow-downgrades && \
 echo 'export SCALA_HOME=/usr/share/scala' >> /home/ubuntu/.domino-defaults && \
 echo 'export PATH=$PATH:$SCALA_HOME/bin:$PATH' >> /home/ubuntu/.domino-defaults && \
 echo 'export PATH=$PATH:/tmp:$PATH' >> /home/ubuntu/.domino-defaults && \
 cd /tmp && curl -L -o coursier https://git.io/coursier-cli && chmod +x coursier && \
 cd /tmp && wget -q https://github.com/almond-sh/almond/archive/v0.1.8.tar.gz && tar -zxvf v0.1.8.tar.gz && mv almond-0.1.8 almond && export SCALA_VERSION=2.12.6 && export ALMOND_VERSION=0.1.8 && ./coursier bootstrap -r jitpack -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION --sources --default=true -o almond-out && ./almond-out --install --global --id scala212 --display-name "Scala (2.12)" && \
# ## SBT
 echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list && \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
 apt-get update -y && \
 apt-get install sbt -y && \

###Julia
 rm -rf /usr/bin/julia && \
    cd /home/ubuntu && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.4/julia-1.4.2-linux-x86_64.tar.gz && \
    tar xzf julia-1.4.2-linux-x86_64.tar.gz && \
    chown -R ubuntu:ubuntu /home/ubuntu/julia-1.4.2 && \
    ln -s /home/ubuntu/julia-1.4.2/bin/julia /usr/bin/julia && \
    rm -rf /home/ubuntu/julia-1.4.2-linux-x86_64.tar.gz && \
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /tmp/*
 
USER ubuntu
RUN julia -e 'using Pkg; Pkg.update(); Pkg.add("IJulia")'
USER root

#### Installing Notebooks,Workspaces,IDEs,etc ####
# Add workspace install and configuration scripts
# Some error when I add my own Workspace install script maybe? 
RUN \
    cd /tmp && \
    wget -q https://github.com/dominopetter/workspaces/archive/v1.0.zip && \
    unzip v1.0.zip && \
    cp -Rf workspaces-1.0/. /var/opt/workspaces && \
    rm -rf /var/opt/workspaces/workspace-logos && rm -rf /tmp/workspaces-1.0/ && \
    
# # # # #Install Rstudio from workspaces
#add update .Rprofile with Domino customizations
    mv /var/opt/workspaces/rstudio/.Rprofile /home/ubuntu/.Rprofile && \
    chown ubuntu:ubuntu /home/ubuntu/.Rprofile && \
#Install Rstudio
    chmod +x /var/opt/workspaces/rstudio/install  && \
    /var/opt/workspaces/rstudio/install && \
    
# # # # #Install Jupyter from workspaces
    chmod +x /var/opt/workspaces/jupyter/install && \
    /var/opt/workspaces/jupyter/install && \

# # # # #Install vscode from workspaces
#Required for VSCode
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
    apt-get update && \
    apt-get install --no-install-recommends libssl1.0-dev node-gyp nodejs -y && \
    pip install python-language-server autopep8 flake8 pylint && \
    pip install git+git://github.com/dominodatalab/jupyter_codeserver_proxy-.git && \
#Install VScode
    chmod +x /var/opt/workspaces/vscode/install && \
    /var/opt/workspaces/vscode/install && \
    
# # # # #nstall Jupyterlab from workspaces
    chmod +x /var/opt/workspaces/Jupyterlab/install && \
    /var/opt/workspaces/Jupyterlab/install && \
# Adding jupyter-server-proxy for jupyter and jupyterlab
    pip install jupyter-server-proxy && \
    jupyter labextension install @jupyterlab/server-proxy && \
#   chown -R ubuntu:ubuntu /home/ubuntu/.config

#Clean up
    rm -rf /var/lib/apt/lists/* && \
    rm -Rf /tmp/* && \
#set permissions
    chown -R ubuntu:ubuntu /home/ubuntu/.local/

#### Install CUDA and GPU dependencies #####
###Install CUDA Base###
ENV CUDA_VERSION 10.2.89
ENV CUDA_PKG_VERSION 10-2=$CUDA_VERSION-1

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends gnupg2 ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
    apt-get update && \
    apt-get install -y --no-install-recommends cuda-cudart-$CUDA_PKG_VERSION cuda-compat-10-2 && \
    ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"


### CUDA RUNTIME ###
ENV NCCL_VERSION 2.4.8

RUN \
    apt-get update && apt-get install -y --no-install-recommends cuda-libraries-$CUDA_PKG_VERSION cuda-nvtx-$CUDA_PKG_VERSION libnccl2=$NCCL_VERSION-1+cuda10.0 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*

###Install CUDNN###
ENV CUDNN_VERSION 7.6.5.32
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN \
    apt-get update && apt-get install -y --no-install-recommends libcudnn7=$CUDNN_VERSION-1+cuda10.2 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

RUN \
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:\${LD_LIBRARY_PATH:-} && \
    echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:\${LD_LIBRARY_PATH:-}" >> /home/ubuntu/.domino-defaults && \
    
    export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:\${PATH:-} && \
    echo "export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:\${PATH:-}" >> /home/ubuntu/.domino-defaults

#Provide Sudo in container
RUN echo "ubuntu    ALL=NOPASSWD: ALL" >> /etc/sudoers

#Last Update
RUN apt-get update && apt-get upgrade -y
RUN /opt/conda/bin/python -m pip install --upgrade pip
