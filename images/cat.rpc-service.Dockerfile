FROM ubuntu:18.04
MAINTAINER n8tb1t <n8tb1t@gmail.com>

WORKDIR /rpc-service

COPY cat_rpc-service ./rpc-service
COPY cat_wallet ./wallet
