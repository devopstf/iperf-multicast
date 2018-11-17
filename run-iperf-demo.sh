#!/bin/bash

docker run -d --name=iperf-server-01 -e "ROLE=server" markbnj/cluster-iperf:0.0.1 -u -B 224.0.67.67 -i 1 && \
docker run -d --name=iperf-server-02 -e "ROLE=server" markbnj/cluster-iperf:0.0.1 -u -B 224.0.67.67 -i 1 && \
docker run -d --name=iperf-client -e "ROLE=client" -e "SERVER_ADDR=224.0.67.67" markbnj/cluster-iperf:0.0.1 -u --ttl 5 -t 30
