.PHONY: help pre build clean shell version inventory ping check private-link private-unlink private-status

################################################################################
# variables
################################################################################

IMAGE_TAG ?= latest
IMAGE_NAME ?= homelab-ansible:$(IMAGE_TAG)
PRIVATE_REPO ?= ../homework
PRIVATE_PACKAGE ?= homelab
DOCKER_RUN ?= docker run --rm \
	-v $(HOME)/.ssh:/tmp/ssh-keys:ro \
	-e ANSIBLE_VAULT_PASSWORD \
	-e SCAN_SSH_HOSTS \
	$(IMAGE_NAME)
DOCKER_RUN_INTERACTIVE ?= docker run --rm -it \
	-v $(HOME)/.ssh:/tmp/ssh-keys:ro \
	-e ANSIBLE_VAULT_PASSWORD \
	-e SCAN_SSH_HOSTS \
	$(IMAGE_NAME)

################################################################################
# general
################################################################################

pre: ## run pre-commit
	uv run --extra dev pre-commit run --all-files

check: pre ## run linting and quality checks

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: \033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s:\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

################################################################################
# private overlay
################################################################################

private-link: ## link private inventory/config from PRIVATE_REPO using stow
	stow --dir $(PRIVATE_REPO) --target $(CURDIR) --no-folding --restow $(PRIVATE_PACKAGE)

private-unlink: ## unlink private inventory/config managed by stow
	stow --dir $(PRIVATE_REPO) --target $(CURDIR) --delete $(PRIVATE_PACKAGE)

private-status: ## show private overlay paths
	@printf "PRIVATE_REPO=%s\nPRIVATE_PACKAGE=%s\n" "$(PRIVATE_REPO)" "$(PRIVATE_PACKAGE)"
	@test -d "$(PRIVATE_REPO)/$(PRIVATE_PACKAGE)" && find "$(PRIVATE_REPO)/$(PRIVATE_PACKAGE)" -maxdepth 3 -type f -print | sort || true

################################################################################
# docker
################################################################################

build: ## build the Docker image
	docker build -t $(IMAGE_NAME) .

clean: ## remove the Docker image
	-docker rmi -f $(IMAGE_NAME)

shell: ## start an interactive shell in the container
	$(DOCKER_RUN_INTERACTIVE) /bin/bash

version: ## show Ansible version in the container
	$(DOCKER_RUN) ansible --version

inventory: ## list Ansible inventory in the container
	$(DOCKER_RUN) ansible-inventory --list

ping: ## test connectivity to all hosts, or set TARGET=host
	$(DOCKER_RUN) ansible $(if $(TARGET),$(TARGET),all) -u $(USER) -m ping
