# Using iperf for testing UDP Multicast traffic

This demo is a simplified version of [Mark Betz's repo](https://github.com/Markbnj/cluster-iperf). This version is focused on Multicast UDP traffic.

## Pre-requisites

We need a few things for getting this demo working:

* Docker and docker-compose installed and properly configured.
* Multicast traffic allowed within your network environment (IGMP enabled within your routers, switches, etc.).
* Your host's network interface must be multicast enabled.
* The same applies for your host's firewall.

## Usage

The demo is based on ``docker-compose`` tool for running. The ``docker-compose.yml`` script will launch an iperf alpine-based container in client mode (i.e. as sender),
and two containers in server mode (i.e. receivers) properly binded to a multicast group's IP address.

The traffic generator parameters can be customized editing the ``.env`` file, that defaults to the following values:

```
#####################
# Docker parameters #
#####################
REPO=devopsman
IMAGE=multicast-iperf
TAG=dev-05
FILE=/data/sample.mp4

########################
# iperf UDP parameters #
########################
SERVER_PORT = 5001
TTL=1
MULTICAST=224.0.67.67
TIME=10
LENGTH=100K
BANDWIDTH=1M
INTERVAL=1
```

These parameters are properly explained within iperf's [docs](https://iperf.fr/iperf-doc.php#doc); while some of them are only used for building the docker image.

You can use this simple demo leveraging the ``Makefile``you can find here containing the following receipes:

```
build                          Building a new image
clean                          Cleaning up the whole stuff
logs                           Gathering logs from containers
run                            Setting up two listeners and one sender
```
If you need to re-build the docker image we use, you must add a sample file into docker folder, properly modifying the ``.env`` file.

