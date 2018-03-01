ELECTRUM_VERSION = $(strip $(shell cat VERSION))

GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

DOCKER_IMAGE ?= blockvis/electrum-daemon
DOCKER_TAG = $(ELECTRUM_VERSION)

# Build Docker image
build: docker_build output

# Build and push Docker image
release: docker_build docker_push output

default: docker_build output

docker_build:
	@docker build \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VERSION=$(ELECTRUM_VERSION) \
		--build-arg VCS_REF=$(GIT_COMMIT) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

docker_run:
	docker run -d --name electrum -p 7000:7000 $(DOCKER_IMAGE):$(ELECTRUM_VERSION)

output:
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)


run_testnet:
	docker run -d \
	    -e "ELECTRUM_TESTNET=--testnet" \
	    --name electrum-testnet \
	    -p 7000:7000 \
	    $(DOCKER_IMAGE):$(ELECTRUM_VERSION)

	docker exec -it electrum-testnet electrum create --testnet
	docker exec -it electrum-testnet electrum daemon load_wallet --testnet
