FROM ubuntu:14.04
MAINTAINER Shawn Dempsay <sdempsay@pavlovmedia.com>
ENV DEBIAN_FRONTEND noninteractive 
RUN apt-get update
RUN apt-get install -y software-properties-common python zlib1g-dev
ADD genieacs-install.sh /tmp/genieacs-install.sh
RUN chmod +x /tmp/genieacs-install.sh
RUN /tmp/genieacs-install.sh
