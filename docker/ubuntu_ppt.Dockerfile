# Dockerfile for python development on Ubuntu

# Install docker-ce on ubuntu host system
#   https://docs.docker.com/engine/install/ubuntu/  

# Overview of ubuntu docker images
#   https://hub.docker.com/_/ubuntu
#FROM ubuntu:20.04 
FROM ubuntu:22.04

# Set workdir and copy requirements file in container 
WORKDIR /workdir
COPY ../requirements.txt /workdir/requirements.txt

# Add a user given as build argument
ARG UNAME=workuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

# port jupyter
ARG CONTAINER_PORT=8888
EXPOSE $CONTAINER_PORT

# update and upgrade
RUN apt-get update 
RUN apt-get dist-upgrade -y

# Configure timezone 
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezon

# basic python3.8 setup
# To be explicit and use pip3 to install packages  
# can be installed by invoking like this:
# python3 -m pip --version    
RUN apt-get install -y python3 python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python 
#RUN apt-get install -y python3 python3-dev 
RUN apt-get install -y python3-venv
RUN apt-get install -y python3-pip 


# Required system tools 
#-----------------------
RUN apt-get install -y git wget curl
# Additional system tools 
RUN apt-get install -y vim iputils-ping netcat iproute2 sudo

# Math
#----------------------
# Install sagemath from the packages:
RUN apt-get install -y sagemath sagemath-jupyter python3-sage 

# Install sagemath from source:


# Crypto requirements 
#-----------------------
# requirements for building underlying packages when installing required python modules later 
# e.g., secp256k1 
RUN apt-get install -y build-essential pkg-config autoconf libtool libssl-dev libffi-dev libgmp-dev libsecp256k1-0 libsecp256k1-dev

# upgrade pip and install requirements for python3.7 which have been previously added to /smartcode
RUN python3 -m pip install --upgrade pip
#RUN python3 -m pip install -r requirements.txt

# Fixing jupyter nbconcert issues
# maybe also required to push version from 5 something to 6.0.7:
# $ pip install --upgrade nbconvert
#RUN chmod -R o+r,o+x /usr/share/jupyter/nbconvert/templates/
#RUN chmod -R o+r,o+x /usr/local/share/jupyter/nbconvert/templates/

# Python install
#----------------------
RUN apt-get install -y python3-notebook python3-nbconvert python3-jupyter-core python3-ipykernel


# change final user
USER $UNAME

# user pyhton virtualenv install
# is done in entrypoint script
ENTRYPOINT ["/workdir/entrypoint.sh"]

# Run jupyter per default:
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0", "--port", "8888"]

