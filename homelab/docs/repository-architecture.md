# Workstation IaC repository architecture

## Decision

The workstation build uses three repositories with explicit, non-overlapping
ownership. They integrate through pinned Ansible collection dependencies and,
where Ansible expects private files at public paths, documented symlinks.

| Repository | Owns | Must not own |
| --- | --- | --- |
| `ansible-collection-homelab` | Reusable roles, tasks, defaults and vars, handlers, role files/templates, platform routing, contracts, and Molecule tests. | Consumer inventory, machine-specific values, or secrets. |
| `dotfiles` | Public dotfiles, playbook composition, public profiles, logical host aliases/groups, immutable dependency pins, bootstrap entry points, integration tests, and operator docs. | Reusable role implementations or private data. |
| `homework` | Private inventory data, host/group vars, network addresses, machine identity, work configuration, private templates, secret-loading code, and references to encrypted/external secrets. | General reusable role behaviour that belongs in the collection. |

The private Agents repository contains the Brain. It stores compacted, verified
knowledge about the system but is not a fourth IaC source and must not become a
runtime dependency.

## Inventory split

Dotfiles `inventory.ini` may declare non-sensitive logical aliases and group
membership so public playbooks have stable targets. Homework supplies private
connection data under matching `host_vars/<alias>.yml` files, including
`ansible_host`, private usernames, key paths, and machine-specific values.

For example, Dotfiles may place `lap1` in the `desktop` group while Homework
owns `homelab/host_vars/lap1.yml`. Do not put the LAN address in the public
inventory.

## Supported responsibility boundaries

The collection roles remain the supported implementation boundaries:

- `marcelofpfelix.homelab.home` manages home folders, dotfiles, shell setup,
  and SSH.
- `marcelofpfelix.homelab.server` manages system configuration and software
  installation.
- `marcelofpfelix.homelab.service` manages systemd/launchd services and
  container-backed deployments.

The public playbooks retain focused entry points:

- `playbooks/config.yml` for generic system configuration and software installation;
- `playbooks/home.yml` for home configuration;
- `playbooks/deploy-service.yml` for services and containers.

`playbooks/config.yml` is platform-neutral. Inventory hosts declare capabilities such as
`gui`, `gui_work`, `gui_linux`, `desktop_linux`, `cli`, `cli_work`, `cli_linux`, `apt_upgrades`, `apt_full_upgrade`, `firmware`, and `ubuntu_cleanup`; the collection routes those
capabilities from gathered Debian-family or Darwin facts.

## Platform layers

Public configuration is split by portability:

- shared desktop definitions apply where names and behaviour genuinely match;
- Ubuntu/Debian definitions contain apt and Linux-specific configuration;
- macOS definitions contain Homebrew and Darwin-specific configuration.

Do not infer portability from a directory name. Audit a file before moving it
into the shared layer.

## Collection integration

Normal runs install the Homelab collection and third-party dependencies from the
immutable pins in `collections/requirements.yml`. For collection development,
`ansible.cfg` gives an ignored local override under
`collections/ansible_collections/` higher precedence than user-wide installs.
Create it explicitly from the Dotfiles `homelab/` directory:

```sh
make collection-link \
  COLLECTION_REPO=../../../ansible-collection-homelab/main
```

Changes in that sibling worktree are then available immediately. Remove the
override with `make collection-unlink` before verifying the published pin.

Install the pinned collections with:

```sh
cd homelab
uv run --extra dev ansible-galaxy collection install -r collections/requirements.yml
```

Verify that Ansible resolves the local collection:

```sh
uv run ansible-doc -t role marcelofpfelix.homelab.server
```

## Homework overlay

Dotfiles ignores the private paths that Homework owns. Link the Homework
`homelab` Stow package into the public Homelab checkout:

```sh
cd /absolute/path/to/dotfiles/homelab
make private-link \
  PRIVATE_REPO=/absolute/path/to/homework \
  PRIVATE_PACKAGE=homelab
```

Inspect the proposed links before using private data, and unlink them with:

```sh
make private-unlink \
  PRIVATE_REPO=/absolute/path/to/homework \
  PRIVATE_PACKAGE=homelab
```

The active GWT layout uses repository worktrees, so pass the Homework worktree
explicitly, for example:

```sh
make private-link \
  PRIVATE_REPO=../../../homework/main \
  PRIVATE_PACKAGE=homelab
```

The Makefile's shorter default is only suitable when the checkouts match that
relative layout.

## Secrets

Homework being private does not make plaintext credentials safe. Store secret
values in gopass, SOPS, or Ansible Vault where practical. Commit only encrypted
values, private non-secret configuration, and secret references.

Never place private keys, tokens, vault passwords, generated runtime secret
files, or unredacted examples in Dotfiles, collection tests, documentation, or
the Brain.

## Clean-machine order

The recovery path must not depend on secrets that can only be recovered after
the machine is configured:

1. Clone Dotfiles.
2. Install public bootstrap prerequisites.
3. Install the collection at the pinned commit.
4. Apply the public system and home baseline in check mode, then apply it.
5. Restore the secret store through its independent recovery process.
6. Clone and link Homework.
7. Apply private and work configuration.
8. Run acceptance checks and a second idempotence run.
9. Deploy optional services separately.

`playbooks/config.yml` is the public system baseline for inventory hosts. Host-declared
profiles choose optional capabilities while the collection auto-detects the
platform. `playbooks/home.yml` and service playbooks remain separate because they own
different lifecycle domains.

## Change and publication order

For a reusable Ansible change:

1. Add or update the collection contract/Molecule coverage.
2. Implement and validate the collection role change.
3. Commit and publish the collection first.
4. Verify the collection commit is remotely available.
5. Pin that immutable commit in Dotfiles.
6. Update the public composition and integration tests.
7. Commit and publish Dotfiles.
8. Update Homework only when the private interface or values must change.

Do not amend a published collection commit. If an unpublished collection commit
is amended, update and revalidate the Dotfiles pin before committing it.

## Durable knowledge

Repository documentation is the operational source of truth. Reusable verified
learnings and architecture decisions are also compacted into the Agents Brain
under the appropriate profile. Raw sessions, temporary task state, secrets, and
unverified findings do not belong there.
