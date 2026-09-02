# Development Notes

These notes preserve durable ideas that were previously only in ignored scratch
files. Keep private host data, tokens, vault passwords, and real work inventory
in the private overlay.

## Private Overlay

- Keep `vars/work/`, `group_vars/`, `host_vars/`, private templates, private
  scripts, and private tasks outside the public repository.
- Evaluate whether `work: true` should select a private container vars path such
  as `work/vars/containers`.
- Revisit whether the private overlay should stay linked by `make private-link`
  or move to a dedicated private submodule. Prefer the current link approach
  unless the workflow needs independent version pinning.

## Container Host Notes

Candidate Docker daemon settings to model when the role owns Docker host setup:

```json
{
  "data-root": "/data/docker",
  "storage-driver": "overlay2",
  "insecure-registries": ["10.0.0.0/8"],
  "dns": [],
  "live-restore": true,
  "log-driver": "journald",
  "log-level": "warn",
  "log-opts": {
    "tag": "{{.ImageID}} {{.ImageName}} "
  }
}
```

Open questions:

- Review whether CoreDNS should be replaced or supplemented by Unbound.
- Keep Pi-hole, dnsmasq, and CoreDNS examples sanitized before promoting them
  from scratch files.
- Use the private routing role as a reference for FRR host-routing behavior:
  `team-telnyx/infra-roles-host-routing`.

## Naming

Candidate lab host naming pattern:

```text
blab01-desktop01
blab01-nuc01 b01 hydrogen h alfa
blab02-pvm01 b02 helium he bravo
blab03-pvm02 b03 lithium li charlie
blab04-pvm03 b04 beryllium be delta
```

Possible naming pools:

- Greek gods, if the lab stays small.
- NATO alphabet, up to 26 hosts.
- Periodic table, up to 118 hosts.

## Vault

Old scratch vault commands were intentionally not copied here. The supported
secret workflow is documented in `docs/private-data.md`.

## Plaintext Finance Tooling

Local hledger tooling for the wiki finance ledger lives on the workstation, not
in homelab services.

Installed tools:

- `hledger` via Homebrew, currently `hledger 1.52.1`.
- `puffin` via Homebrew tap `siddhantac/puffin`, currently `2.1.5`.
- `hledger-mcp` via npm package `@iiatlas/hledger-mcp`, currently `1.0.5`.

Primary journal:

```sh
~/gwt/marcelofpfelix/wiki/main/ledger/main.journal
```

Useful commands:

```sh
hledger -f ~/gwt/marcelofpfelix/wiki/main/ledger/main.journal check
hledger -f ~/gwt/marcelofpfelix/wiki/main/ledger/main.journal bal --depth 2
puffin -cfg ~/gwt/marcelofpfelix/wiki/main/ledger/dev/puffin.json
hledger-mcp ~/gwt/marcelofpfelix/wiki/main/ledger/main.journal --read-only
```

Start MCP in read-only mode first. Enable write tools only after the ledger
import/migration path is fully validated.

## Home Play Boundary

The `home.yml` play and `home` role must only make home-user changes:
dotfiles, user config, user services, and files under the target user home.
They must not edit system config, use `become` for OS policy, restart system
services, or change host-wide behavior such as NTP, networking, kernel, Docker,
package manager, or security settings. Put those changes in a dedicated system,
desktop, or host role instead.

## Desktop Time Sync

Desktop hosts may use `chrony` for NTP, but the home playbook must not configure
it. Ubuntu default `makestep 1 3` only permits stepping during the first three
updates, which can leave a resumed laptop visibly wrong while chrony slowly
slews. Any permanent `makestep 1 -1` policy belongs in a system-level desktop
role, not `home.yml`.

Immediate repair command when the clock is already wrong:

```sh
sudo chronyc makestep
```
