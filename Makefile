.PHONY: help
.DEFAULT_GOAL := help

REGISTRY_NAME ?= devopsman
SHELL = /bin/bash
IMAGE_NAME ?= multicast-iperf
TAG ?= dev
LOG_NAME ?= image-build.log
CLIENT_NAME = iperf-client
SERVER_NAME = iperf-server
SERVER_PORT = 5001
TTL ?= 1
MULTICAST ?= 224.0.67.67

.rm-client: ## Remove client container
	if (docker ps -a | grep -q $(CLIENT_NAME)); then docker rm -f $(CLIENT_NAME); fi

.rm-server: ## Remove server container
	if (docker ps -a | grep -q $(SERVER_NAME)); then docker rm -f $(SERVER_NAME); fi

cluster-iperf: ## Build the cluster-iperf image
	docker build --tag=$(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG) --rm=true --force-rm=true docker | tee docker/$(LOG_NAME)

run-server: ## Remove previous containers and run iperf in server (receiver) mode 
	.rm-server
	docker run -it -h $(SERVER_NAME) --name=$(SERVER_NAME) -p $(SERVER_PORT):$(SERVER_PORT) -e "ROLE=server" $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG)

run-client: ## Remove previous container and run iperf in client (sender) mode
	.rm-client
	docker run -it -h $(CLIENT_NAME) --name=$(CLIENT_NAME) -e "ROLE=client" -e "SERVER_ADDR=iperf-server" --link iperf-server:iperf-server $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG)

clean: ## Remove containers and associated images
	.rm-client .rm-server
	if (docker images | grep -q $(REGISTRY_NAME)/$(IMAGE_NAME)); then docker rmi $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG); fi
	rm -f docker/image-build.log

build: ## Cleaning up the images and building a new one
	clean cluster-iperf

logs: ## Show client and server logs, and remove them
	docker logs $(CLIENT_NAME) && docker logs $(SERVER_NAME)
	clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
