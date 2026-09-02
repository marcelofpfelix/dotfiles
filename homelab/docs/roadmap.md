# Roadmap

## Configuration

- Split public reusable automation from private host and work configuration.
- Keep `vars/work/`, `group_vars/`, `host_vars/`, and private templates outside
  the public repository.
- Move private homelab overlay files into `../homework/homelab/` and link them
  back with `make private-link`.
- Move real secrets into Ansible Vault files inside the private overlay.
- Add sanitized example inventories and vars for common local workflows.
- Consider a private companion repository for real inventory and service data.

## Containers

- Add clean public examples for CoreDNS, dnsmasq, and Pi-hole.
- Review whether CoreDNS should be replaced or supplemented by Unbound.
- Keep work-specific registries, routes, TLS material, and webhook settings out
  of this repository.

## Local Tooling

- Keep CI based on `uv`, pre-commit, YAML lint, Gitleaks, and ansible-lint.
- Consider a small `lab` CLI only if repeated local commands become awkward.
