.PHONY: help pre build clean shell version inventory ping check deps syntax collection-link collection-unlink collection-status private-link private-unlink private-status test-layout test-config-playbook test-lagostim-compose test-lagostim-launchd

################################################################################
# variables
################################################################################

COLLECTION_REPO ?= ../../../ansible-collection-homelab/main
COLLECTION_LINK ?= collections/ansible_collections/marcelofpfelix/homelab
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

pre: ## run scoped Homelab pre-commit hooks
	uv run --extra dev pre-commit run --config .pre-commit-config.yaml --all-files

check: pre test-layout test-config-playbook syntax ## run linting and quality checks

deps: ## install pinned Ansible collections
	uv run --extra dev ansible-galaxy collection install -r collections/requirements.yml

syntax: ## syntax-check all supported public playbooks
	uv run --extra dev ansible-playbook playbooks/config.yml -e config_target=localhost --syntax-check
	uv run --extra dev ansible-playbook playbooks/home.yml -e target=localhost --syntax-check
	uv run --extra dev ansible-playbook playbooks/deploy-container.yml -e target=localhost -e container=dummy --syntax-check
	uv run --extra dev ansible-playbook playbooks/deploy-service.yml -e target=localhost -e deploy_service_name=dummy --syntax-check
	uv run --extra dev ansible-playbook playbooks/deploy-service-dummy.yml -e target=localhost --syntax-check

collection-link: ## use the sibling Homelab collection worktree for development
	@mkdir -p "$(dir $(COLLECTION_LINK))"
	@ln -sfn "$(abspath $(COLLECTION_REPO))" "$(COLLECTION_LINK)"

collection-unlink: ## remove the local Homelab collection development override
	@unlink "$(COLLECTION_LINK)" 2>/dev/null || true

collection-status: ## show the active local Homelab collection override
	@readlink "$(COLLECTION_LINK)" 2>/dev/null || printf 'No local collection override\n'

test-layout: ## validate the Homelab project layout
	sh tests/layout_test.sh

test-config-playbook: ## validate the generic configuration composition contract
	sh tests/config_playbook_test.sh

test-lagostim-compose: ## validate the canonical Hermes Compose definition
	bash tests/lagostim_compose_test.sh

test-lagostim-launchd: ## validate local launchd runtime bundles for Hermes
	ruby tests/lagostim_launchd_test.rb

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
