CONTAINER_ENGINE ?= $(shell if command -v docker >/dev/null 2>&1; then echo docker; elif command -v podman >/dev/null 2>&1; then echo podman; fi)
IMAGE ?= php-hello-world

.PHONY: build run test test-local

build:
	@test -n "$(CONTAINER_ENGINE)" || (echo "Docker or Podman is required" >&2; exit 1)
	$(CONTAINER_ENGINE) build -t $(IMAGE) .

run: build
	$(CONTAINER_ENGINE) run --rm $(IMAGE)

test: build
	@test "$$($(CONTAINER_ENGINE) run --rm $(IMAGE))" = "Hello, World!"
	@echo "Test passed"

test-local:
	@command -v php >/dev/null 2>&1 || (echo "PHP is required" >&2; exit 1)
	php -l index.php
	@test "$$(php index.php)" = "Hello, World!"
	@echo "Test passed"
