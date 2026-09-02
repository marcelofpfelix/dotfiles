# Dockerfile for running Ansible playbooks in homelab.
# Compatible with local execution and GitHub Actions.

ARG BASE_IMAGE=python:3.13-slim
ARG VENV_PATH=/opt/venv

# ==============================================================================
# BUILDER STAGE
# Creates a virtual environment with all Python and Ansible dependencies.
# ==============================================================================
FROM ${BASE_IMAGE} AS builder

ARG VENV_PATH
WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./

RUN set -o nounset -o errexit -o xtrace \
    && UV_PROJECT_ENVIRONMENT=${VENV_PATH} uv sync --locked --no-dev --no-install-project \
    && true

# ==============================================================================
# FINAL STAGE
# Creates the final image with the virtual environment and Ansible project files.
# ==============================================================================
FROM ${BASE_IMAGE} AS final

ARG VENV_PATH
WORKDIR /ansible

ENV VIRTUAL_ENV=${VENV_PATH} \
    PYTHONUNBUFFERED=1 \
    ANSIBLE_VAULT_PASSWORD_FILE=/home/ansible/.vault_pass \
    PATH="${VENV_PATH}/bin:${PATH}"

RUN set -o nounset -o errexit -o xtrace \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        openssh-client \
        rsync \
        sshpass \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder ${VENV_PATH} ${VENV_PATH}
COPY . .

RUN set -o nounset -o errexit -o xtrace \
    && groupadd --system ansible \
    && useradd --no-log-init --system --gid ansible --home-dir /home/ansible --create-home --shell /bin/bash ansible \
    && mkdir -p /home/ansible/.ssh /home/ansible/.ansible/tmp \
    && chmod 700 /home/ansible/.ssh \
    && chown -R ansible:ansible /ansible /home/ansible \
    && chmod +x /ansible/ci/entrypoint.sh

ENTRYPOINT ["/ansible/ci/entrypoint.sh"]
CMD ["ansible", "--version"]
