FROM ubuntu:18.04
MAINTAINER n8tb1t <n8tb1t@gmail.com>

RUN apt-get update && apt-get install -y \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /daemon

COPY xun_daemon ./daemon
