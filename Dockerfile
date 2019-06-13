FROM ubuntu:16.04
MAINTAINER Jon Auman, jon.auman@uk.fujitsu.com

ENV LAST_UPDATE=2019-06-12

#####################################################################################
# Current version is aws-cli/1.10.53 Python/2.7.12
#####################################################################################

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tzdata locales

# Set the timezone
RUN echo "Europe/London" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Set the locale for UTF-8 support
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8

RUN apt-get install -y \
    curl \
    git \
    less \
    man \
    ssh \
    python \
    python-pip \
    vim \
    zip


RUN pip install awscli

RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
    && export PATH="$HOME/.tfenv/bin:$PATH" >> ~/.bash_profile \
    && ln -s ~/.tfenv/bin/* /usr/local/bin

RUN  tfenv install 0.12.1
