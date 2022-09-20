IMAGE_NAME=hrexed/oteltraining
IMAGE_VERSION=0.1
DEMO_NAME=oteltraining

.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .

.PHONY: run
run:
	docker run --rm -it --name=$(DEMO_NAME) -v /var/run/docker.sock:/var/run/docker.sock:ro --add-host=host.docker.internal:host-gateway $(IMAGE_NAME):$(IMAGE_VERSION)

