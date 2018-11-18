.PHONY: help
.DEFAULT_GOAL := help

REPO ?= devopsman
IMAGE ?= multicast-iperf
TAG ?= $(shell bash -c 'read -s -p "TAG: " tag; echo $$tag')

run: ## Setting up two listeners and one sender
	@docker-compose up -d

logs: ## Gathering logs from containers
	@docker-compose logs >> iperf.log && cat iperf.log

clean: ## Cleaning up the whole stuff
	@docker-compose down

build: ## Building a new image
	@docker build -t $(REPO)/$(IMAGE):$(TAG) ./docker/

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
