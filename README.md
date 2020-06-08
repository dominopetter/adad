# Accelerated Domino Analytics Distribution - Unsupported

This Docker Image for Domino tries to contain the latest release of everything to the extent possible\
\
v.2 - 2020-06-08\
v.1 - 2020-05-29\
\
Docker Hub Link         : https://hub.docker.com/repository/docker/petterolsson/adad/general

To add it to Domino Link: docker.io/petterolsson/adad:v1

R 4.0.1\
Python 3.8\
Oracle Instantclient 19.6\
Scala Kernel 2.12.6\
Julia 1.4.2\
Jupyterlab 2.1.3\
Zeppelin 0.8.2\
h2o 3.18.0.4\
Jupyter 1.0.0\
Rstudio Server 1.3.959\
VScode 3.4.1\
CUDA 10.2.89\
CUDNN 7.6.5.32

## Notebook Properities

Pluggable properties values to be set in the compute environment
```
jupyter:
  title: "Jupyter (Python, R, Julia)"
  iconUrl: "/assets/images/workspace-logos/Jupyter.svg"
  start: [ "/var/opt/workspaces/jupyter/start" ]
  httpProxy:
    port: 8888
    rewrite: false
    internalPath: "/{{ownerUsername}}/{{projectName}}/{{sessionPathComponent}}/{{runId}}/{{#if pathToOpen}}tree/{{pathToOpen}}{{/if}}"
    requireSubdomain: false
  supportedFileExtensions: [ ".ipynb" ]
jupyterlab:
  title: "JupyterLab"
  iconUrl: "/assets/images/workspace-logos/jupyterlab.svg"
  start: [  /var/opt/workspaces/Jupyterlab/start.sh ]
  httpProxy:
    internalPath: "/{{ownerUsername}}/{{projectName}}/{{sessionPathComponent}}/{{runId}}/{{#if pathToOpen}}tree/{{pathToOpen}}{{/if}}"
    port: 8888
    rewrite: false
    requireSubdomain: false
vscode:
 title: "vscode"
 iconUrl: "/assets/images/workspace-logos/vscode.svg"
 start: [ "/var/opt/workspaces/vscode/start" ]
 httpProxy:
    port: 8888
    requireSubdomain: false
rstudio:
  title: "RStudio"
  iconUrl: "/assets/images/workspace-logos/Rstudio.svg"
  start: [ "/var/opt/workspaces/rstudio/start" ]
  httpProxy:
    port: 8888
    requireSubdomain: false
```
