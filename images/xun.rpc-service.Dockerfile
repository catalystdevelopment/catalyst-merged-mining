FROM xun_deamon:latest
MAINTAINER n8tb1t <n8tb1t@gmail.com>

WORKDIR /rpc-service

COPY xun_rpc-service ./rpc-service
COPY xun_wallet ./wallet
