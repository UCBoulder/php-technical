CONTAINER_ENGINE ?= $(shell if command -v docker >/dev/null 2>&1; then echo docker; elif command -v podman >/dev/null 2>&1; then echo podman; fi)
IMAGE ?= php-hello-world

.PHONY: build run test test-codespaces-auth

build:
	@test -n "$(CONTAINER_ENGINE)" || (echo "Docker or Podman is required" >&2; exit 1)
	$(CONTAINER_ENGINE) build -t $(IMAGE) .

run: build
	$(CONTAINER_ENGINE) run --rm $(IMAGE)

test: build
	@test "$$($(CONTAINER_ENGINE) run --rm $(IMAGE))" = "Hello, World!"
	@echo "Test passed"

test-codespaces-auth:
	.devcontainer/test-codex-auth-sync.sh
