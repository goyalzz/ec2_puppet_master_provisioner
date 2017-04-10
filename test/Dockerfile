FROM ubuntu:14.04

RUN apt-get update && apt-get -y --force-yes install wget vim git unzip

WORKDIR /usr/local/terraform
RUN wget https://releases.hashicorp.com/terraform/0.8.2/terraform_0.8.2_linux_amd64.zip && unzip terraform_0.8.2_linux_amd64.zip
ENV PATH $PATH:/usr/local/terraform

WORKDIR /root

VOLUME /root/terraform
