# Using iperf for testing UDP Multicast traffic

This demo is a simplified version of [Mark Betz's repo](https://github.com/Markbnj/cluster-iperf). This version is focused on Multicast UDP traffic.

When we are dealing with multicast addresses, we have to take into account that **the ``224.0.0.0/24`` CIDR has to be used for local networking**. Within this demo we are using a Virtual Box's internal or host-only network subscribed to ``224.0.0.1`` address (All the hosts within the local network). Our ``minishift`` VM is a Centos-based host machine, provisioned with OverlayFS and its ``firewalld`` service is set to inactive.

The iperf process configured as client (i.e. traffic generator) is deployed as a simple pod in ``hostNetwork`` mode, that is an anti-pattern requiring priviledged access to Openshift API, hence we should issue the following command before deploying it (assuming we are logging in as the admin user into minishift):

```
oc adm policy add-scc-to-user privileged admin
```

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
TAG=dev-06
FILE=/data/sample.mp4

########################
# iperf UDP parameters #
########################
PORT=5001
PROTOCOL=udp
TTL=1
MULTICAST=224.0.0.1
TIME=10
LENGTH=2K
WINDOW=4K
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

Log will be written to ``iperf.log`` file issuing ``make logs``. The file will be removed by ``make clean``receipe.

The traffic generation is based on a ``smple.mp4`` file located in ``/data``. You can use the default one by setting "FILE" parameter to blank within ``.env`` file.

## Develop

Work in progress you can contribute to:

* Prompting for the parameters to be populated into ``.env`` file.
* Getting iperf to generate multicast traffic from within an OCP cluster, and listening to it from outside. [x]
* Setting up the traffic generator as an Openshift's ``job`` instead of a simple pod.