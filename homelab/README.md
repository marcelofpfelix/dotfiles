# homelab

Homelab automation using Ansible.

Read [the repository architecture](docs/repository-architecture.md) before
adding automation. Reusable role tasks belong in
`ansible-collection-homelab`; this public repository owns composition and
non-sensitive configuration. See [private data](docs/private-data.md) for the
Homework overlay and secret policy.

### Configuration management

`playbooks/config.yml` is the single system-configuration playbook. Targets declare
optional profiles in inventory and the collection auto-detects Debian-family or
Darwin behaviour.

```console
uv run ansible-playbook playbooks/config.yml -e config_target=lap1
```

See [system configuration](docs/configuration.md) for profiles, tags, safe
upgrades and platform package mappings.

### Deploy Containers

```console
  ## examples
ansible-playbook playbooks/deploy-container.yml -e "container=container_name target=hostname"
```

### Deploy Local Services

```console
ansible-playbook playbooks/deploy-service.yml -e deploy_service_name=lagostim-personal-hermes
ansible-playbook playbooks/deploy-service.yml -e deploy_service_name=lagostim-constanca-hermes
ansible-playbook playbooks/deploy-service.yml -e deploy_service_name=lagostim-work-hermes
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

`playbooks/home.yml` remains the focused entry point for home folders, dotfiles, shell
configuration, and SSH through `marcelofpfelix.homelab.home`.

### Laptop configuration

`lap1` declares `gui`, `gui_work`, `gui_linux`, `desktop_linux`, `cli`, `cli_work`, `cli_linux`, `apt_upgrades`, `apt_full_upgrade`, `firmware`, and `ubuntu_cleanup` capabilities
in the public inventory. The same `playbooks/config.yml` playbook can target a Debian,
Ubuntu, or Darwin host and the collection selects the appropriate platform
adapter from gathered facts.

Validate the composition and list focused tasks without changing the laptop:

```console
make test-config-playbook
uv run ansible-playbook playbooks/config.yml --syntax-check -e config_target=lap1
uv run ansible-playbook playbooks/config.yml --list-tasks \
  -e config_target=lap1 --tags gui
```

`playbooks/home.yml` remains separate for home folders, dotfiles, shell configuration and
SSH. Service/container deployment remains separate under `playbooks/deploy-service.yml`.
See [system configuration](docs/configuration.md) and
[laptop bootstrap](docs/laptop-bootstrap.md).

### Infrastructure as code

The public baseline, private overlay, and reusable collection are deliberately
separate. Follow [the repository architecture](docs/repository-architecture.md)
for ownership, local collection symlinks, Homework Stow integration, recovery
order, and publication order.
