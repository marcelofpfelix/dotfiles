# dotfiles

Public workstation configuration and composition for Linux and macOS.

## Repository model

This repository is one part of a three-repository infrastructure-as-code system:

| Repository | Visibility | Responsibility |
| --- | --- | --- |
| `dotfiles` | Public | Non-sensitive dotfiles, playbook composition, public profiles and logical inventory groups, dependency pins, bootstrap commands, tests, and operator documentation. |
| `ansible-collection-homelab` | Public | Reusable Ansible roles, tasks, defaults, variables, handlers, platform routing, and role tests. |
| `homework` | Private | Private inventory data, host/group variables, network addresses, machine and work configuration, private templates, and secret-loading integration. |

Reusable Ansible behaviour belongs in the collection, not in this repository.
Private or sensitive data belongs in Homework or an external encrypted secret
store, not in this public repository.

The private Agents repository contains the Brain used to retain verified
architectural and operational knowledge. It is a knowledge layer, not another
source of workstation configuration.

See [the Homelab repository architecture](homelab/docs/repository-architecture.md)
for ownership rules, symlink integration, development workflow, publication
order, and clean-machine recovery order.

## Homelab entry points

- [`homelab/playbooks/home.yml`](homelab/playbooks/home.yml): home folders, dotfiles, shell setup,
  and SSH through the collection's `home` role.
- [`homelab/playbooks/config.yml`](homelab/playbooks/config.yml): generic system configuration,
  semantic GUI profiles, APT upgrades, and firmware through the collection's
  `server` role.
- [`homelab/playbooks/deploy-service.yml`](homelab/playbooks/deploy-service.yml): service and
  container deployment through the collection's `service` role.

These entry points have distinct responsibilities. `playbooks/config.yml` delegates
platform routing and reusable implementation to the collection; it does not
replace `playbooks/home.yml` or service deployment.

## Private overlay

The public laptop baseline is designed to run without Homework. Restore and link
the private overlay only when private inventory, work configuration, or secret
references are needed.

See [`homelab/docs/private-data.md`](homelab/docs/private-data.md).
