# homelab

Homelab automation using Ansible

See [docs/private-data.md](docs/private-data.md) for how private inventory,
templates, and secrets are handled.

### Configuration management

```console
  ## examples
ansible-playbook server-config.yml"
```

### Deploy Containers

```console
  ## examples
ansible-playbook deploy_container.yml -e "container=container_name target=hostname"
```

### Deploy Local Services

```console
ansible-playbook deploy-service.yml -e deploy_service_name=lagostim-personal-hermes
ansible-playbook deploy-service.yml -e deploy_service_name=lagostim-constanca-hermes
ansible-playbook deploy-service.yml -e deploy_service_name=lagostim-work-hermes
```

The Lagostim service definitions manage macOS LaunchAgents using the canonical
Compose file at `files/lagostim/docker-compose.yml`. Lagostim remains the image
build context and contains the lifecycle helper; it is not the canonical
service-definition owner. Mutable runtime env files live under
`/Volumes/NVMe/docker/lagostim/<profile>/runtime/compose.env`.
Messaging platform secrets that are consumed directly by Hermes are synced into
the matching ignored profile env file. Work Slack and Telegram tokens and user
allowlists use profile-specific gopass entries; deployment copies them unchanged
into the ignored runtime env and never stores values in Git. Personal mounts the canonical Eusebio
identity read-only, and Work mounts John read-only; their runtime config loads
`skills/portable` through
Hermes `skills.external_dirs`. Personal, Family, and Work all mount the full
`${HERMES_GWT_ROOT:-/Volumes/NVMe/gwt}` tree read-write at
`/Users/marcelof/gwt`, preserving the absolute paths stored by `gwt`
worktrees. All three services start in `/workspace`, which is the gateway
fallback. Do not set `terminal.cwd` in persistent Hermes `config.yaml`: a
CLI invocation such as `hermes --in /Users/marcelof/gwt/...` must let its
terminal tools inherit that project directory. Brain profile boundaries are
instruction and write-routing policy,
not filesystem isolation. No repository or Brain files are copied or moved.
Constanca mounts the canonical family identity read-only, matching Personal and
Work while preserving mutable runtime memory in its existing data directory.
Work also mounts its dedicated SSH runtime directory read-only at
`/opt/data/ssh`; the private key is materialized from gopass into ignored
runtime storage and is never stored in this repository.

Validate all profiles without changing containers:

```console
make test-lagostim-compose
```

### Home

`home.yml` remains the focused entry point for home folders, dotfiles, shell
configuration, and SSH through `marcelofpfelix.homelab.home`.

### New Ubuntu laptop

`laptop.yml` composes the existing collection roles rather than duplicating
their tasks:

1. `marcelofpfelix.homelab.server` applies system configuration and layered
   shared/Ubuntu packages.
2. `marcelofpfelix.homelab.home` applies the `default`, `desktop`,
   `default_debian`, and `desktop_debian` home layers.
3. Service/container deployment remains separate under `deploy-service.yml`.

The target is mandatory. Validate the composition and syntax without changing a
machine:

```console
make test-laptop-playbook
uv run ansible-playbook laptop.yml --syntax-check \
  -i 'localhost,' -e laptop_target=localhost
```

On the Ubuntu laptop, inspect the local changes before applying them:

```console
uv run ansible-playbook laptop.yml --check --ask-become-pass \
  -i 'localhost,' -c local -e laptop_target=localhost
```

Remove `--check` only after reviewing the dry-run. The collection role rejects
non-Ubuntu targets and host patterns that select more than one machine. This is
the first foundation slice, not yet the complete laptop build.

### Infrastructure as code
