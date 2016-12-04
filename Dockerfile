FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /etc/bash.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python

#Go
ENV GO_VERSION 1.7
RUN curl -sSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    curl -sSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz.sha256 -o /tmp/go.tar.gz.sha256 && \
    echo "$(cat /tmp/go.tar.gz.sha256)  /tmp/go.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -vxzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz /tmp/go.tar.gz.sha256
ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go
RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

RUN apt-get install -y gcc
RUN apt-get install -y bzr rpm xz-utils

RUN mkdir -p $GOPATH/src/github.com/coreos/clair && \
    wget -O - https://github.com/coreos/clair/archive/v1.2.6.tar.gz | tar zx -C $GOPATH/src/github.com/coreos/clair
RUN cd $GOPATH/src/github.com/coreos/clair && \
    go install -v github.com/coreos/clair/cmd/clair && \
    go get -u github.com/coreos/clair/contrib/analyze-local-images

RUN cp $GOPATH/src/github.com/coreos/clair/config.example.yaml /etc/clair.yaml

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

