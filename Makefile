# Makefile

# VARIABLES
IMAGE_NAME = dotfiles
IMAGE_VERSION = latest

DOCKER_REGISTRY = index.docker.io
IMAGE_ORG = marcelofpfelix

# Generated variables
IMAGE_TAG = $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)

################################################################################
# general
################################################################################

pre: ## run pre-commit
	pre-commit run --all-files

check-bin-executables: ## check executable bits for shebang files in bin dirs
	default/bin/check-bin-executables

fix-bin-executables: ## chmod +x shebang files in bin dirs
	default/bin/check-bin-executables --fix

act: ## run GitHub Actions locally with act
	act -W .github/workflows/ci.yml

pre-act: ## run the manual pre-commit act hook
	pre-commit run act-ci --hook-stage manual --all-files

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: \033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s:\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\asd033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

################################################################################
# docker
################################################################################

build:
	@echo building $(IMAGE_TAG)
	@docker build -t $(IMAGE_TAG) .

hub:
	@echo MAKE pushing $(IMAGE_TAG)
	@docker push $(IMAGE_TAG)
