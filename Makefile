IMAGE_NAME=hrexed/oteltraining
IMAGE_VERSION=0.1
DEMO_NAME=oteltraining
DT_TOKEN=$2
DT_ENV_URL=$1

.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) . --build-arg API_TOKEN=$(DT_TOKEN) --build-arg DT_ENV_URL=$(DT_TOKEN) --no-cache

.PHONY: run
run:
	docker run --rm -it --name=$(DEMO_NAME) -v /var/run/docker.sock:/var/run/docker.sock:ro --add-host=host.docker.internal:host-gateway $(IMAGE_NAME):$(IMAGE_VERSION)

