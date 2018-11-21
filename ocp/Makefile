.PHONY: help
.DEFAULT_GOAL := help

REPO ?= devopsman
IMAGE ?= multicast-iperf
TAG ?= $(shell bash -c 'read -p "TAG: " tag; echo $$tag')

run: ## Create the pod, and follow the logs from minishift
	@oc create -f iperf-pod.yml && sleep 2 && oc logs -f multicast-iperf

logs: ## Gathering logs from completed pod and writing it to a file
	@touch iperf.log
	@oc logs multicast-iperf >> iperf.log && cat iperf.log

clean: ## Delete pod
	@oc delete pod multicast-iperf --grace-period=0

build: ## Building a new image
	@docker build -t $(REPO)/$(IMAGE):$(TAG) ./docker/

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
