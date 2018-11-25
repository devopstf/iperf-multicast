# Using iperf for testing UDP Multicast traffic

## Pre-requisites

We need a few things for getting this demo working:

* ``Python 2.7+`` installed.
* Docker and docker-compose installed and properly configured.
* Multicast traffic allowed within your network environment (IGMP enabled within your routers, switches, etc.).
* Your host's network interface must be multicast enabled.
* The same applies for your host's firewall.

## Environment

This demo has been accomplished using the following environment:

* **Localhost:** MacBookPro9,2 Mac OS X 10.13.6 High Sierra
* **VM provider:** VirtualBox 5.2.16 r123759
* **iPerf:** version 2.0.12 (brew installed) | version 2.0.5 (FROM Alpine 3.1 docker image)
* **minishift** version 1.21.0+a8c8b37 | CentOS 7 host virtual machine

## Usage

### Docker demo

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

### Minishift Demo

**Required:**

* You have to enable a host-only network adapter for your minishift VM within VirtualBox GUI, or via ``VBoxManage`` CLI
* You need to set up a route for multicast traffic; hence you first list the interfaces within the host machine via ``ifconfig`` finding out which one ``ethX`` is attached to VirtualBox host-only network you are using, and then issue the following command for creating such a route,

```
route -n add -net 224.0.0.0 netmask 240.0.0.0 dev <ethX>
```

When we are dealing with multicast addresses, we have to take into account that **the ``224.0.0.0/24`` CIDR has to be used for local networking**. Within this demo we are using a Virtual Box's internal or host-only network subscribed to ``224.0.0.1`` address (All the hosts within the local network). Our ``minishift`` VM is a Centos-based host machine, provisioned with OverlayFS and its ``firewalld`` service is set to inactive.

The iperf process configured as client (i.e. traffic generator) is deployed as a simple pod in ``hostNetwork`` mode, that is an anti-pattern requiring "non restricted" access to Openshift API, hence we should issue the following command before deploying it:

```
oc adm policy add-scc-to-user privileged <your-demo-user>
```

**Deploying iperf traffic generator on minishift:**

1. Starting up minishift

```
minishift start --vm-driver=virtualbox
```

2. Starting up the multicast listener in our localhost

You can use a simple socket binding via a python script,

```
cd python/
python multicast-client.py
```

Or you can simply set up an iperf server,

```
iperf -s -u -B 224.0.0.1 -i 1
```

3. Creating a pod

```
cd ocp/
oc create -f iperf-pod.yml
```

The datagrams hex-dump should be appearing in the terminal where the python script is attached to, displaying the interface IP address, and port.

4. Displaying logs from iperf client:

```
oc logs multicast-iperf
```

5. Deleting the iperf pod

```
oc delete pod multicast-iperf --grace-period=0
```

You can find a simple ``Makefile`` inside ``ocp`` folder for playing around with the demo more easily, including the following receipes:

```
build                          Building a new image
clean                          Delete pod
logs                           Gathering logs from completed pod and writing it to a file
run                            Create the pod, and follow the logs from minishift
```

## Develop

Work in progress you can contribute to:

* Prompting for the parameters to be populated into ``.env`` file. ⣿⣿⣀⣀⣀⣀⣀⣀⣀⣀ 20%	
* Getting iperf to generate outbound multicast traffic from minishift. ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦ 95%	
* Setting up the traffic generator as an Openshift's ``job`` instead of a simple pod. ⣿⣿⣿⣿⣀⣀⣀⣀⣀⣀ 40%

## References

* [Multicast Address](https://en.wikipedia.org/wiki/Multicast_address)
* [Accessing K8s pods from outside of the cluster](http://alesnosek.com/blog/2017/02/14/accessing-kubernetes-pods-from-outside-of-the-cluster/)
* [Multicast Addressing Pitfalls](http://aviadezra.blogspot.com/2009/07/multicast-ip-udp-igmp-multi-homed.html)
* [iPerf](https://iperf.fr)
* [How to allow multicast traffic with firewallD in RHEL 7](https://access.redhat.com/solutions/1587673)
* [Understanding Service Accounts and SCCs](https://blog.openshift.com/understanding-service-accounts-sccs/)
* [Mark Betz's repo](https://github.com/Markbnj/cluster-iperf)
