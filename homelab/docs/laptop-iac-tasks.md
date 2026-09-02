# Laptop IaC tasks

These tasks are intentionally deferred. The new Ubuntu laptop automation must be designed from scratch rather than extending the legacy `home.yml` or server playbooks.

## Architecture

- [ ] Create a fresh `homelab/laptop.yml` entry point for provisioning a new laptop.
  - Acceptance: targets one explicitly selected laptop; does not default to the existing `desktop` group; supports check mode and tags.
- [ ] Define a shared desktop layer for configuration common to Linux and macOS.
  - Examples: user identity, Git, shell tools, editor configuration, repositories, agent tooling, and dotfile deployment where behaviour is genuinely portable.
- [ ] Define an Ubuntu-only desktop layer.
  - Examples: APT repositories/packages, Hyprland, Quickshell, portals, PipeWire, NetworkManager, systemd user units, firmware, firewall, update policy, hibernation, backup integration, hardware support, and Tailscale.
- [ ] Define a macOS-only desktop layer.
  - Examples: Homebrew, LaunchAgents, macOS defaults, FileVault verification, application installation, and Darwin-specific paths.
- [ ] Keep machine-specific and secret values in the Homework overlay; keep reusable roles, playbooks, defaults, and validation in Dotfiles.
- [ ] Decide whether laptop roles live directly under `homelab/roles/` or in the external collection.
  - Acceptance: whichever boundary is selected must be pinned and reproducible; no dependency on a mutable collection `main` branch.

## Bootstrap and recovery

- [ ] Add one documented bootstrap command for a freshly installed Ubuntu laptop.
  - Acceptance: installs only the minimum prerequisites needed to run Ansible, then invokes `laptop.yml`.
- [ ] Document the bootstrap order: public baseline, secret-store recovery, Homework overlay, work overlay, then acceptance checks.
- [ ] Allow the public/shared baseline to run before gopass secrets are restored.
- [ ] Separate secret-dependent work templates from ordinary home and desktop configuration.
- [ ] Add backup restore and disaster-recovery checks for user data and the secret store.

## Package management

- [ ] Replace `vars/install/desktop.yml` as a passive software list with executable package definitions consumed by roles.
- [ ] Split package definitions into shared desktop intent, Ubuntu package mappings, and macOS package mappings.
- [ ] Track or deliberately remove the currently missing desktop dependencies: `cliamp`, `dua-cli`, `omawrite`, `hyprsunset`, and `wlrctl`.
- [ ] Pin third-party repositories, packages, downloaded artefacts, and checksums where native repositories are not used.
- [ ] Define ownership between APT, Homebrew, Nix, mise, uv tools, and locally built binaries; avoid installing the same tool through multiple managers.

## Inventory and security

- [ ] Replace host/group name collisions for `laptop` and `mac` with distinct group and host names.
- [ ] Give the new laptop explicit shared and Ubuntu desktop roles; do not rely on `desktop: true` as an unused marker.
- [ ] Remove global `StrictHostKeyChecking=no` from public and private Ansible configuration.
- [ ] Manage trusted SSH host keys explicitly.
- [ ] Make unrestricted passwordless sudo opt-in and avoid granting `NOPASSWD: ALL` to the entire sudo group.
- [ ] Add Ubuntu security definitions for firewall policy, unattended security updates, SSHD policy, Docker exposure, and encryption-state verification.

## CI and acceptance

- [ ] Move Homelab CI into the repository-root GitHub Actions workflow; nested workflows are not discovered by GitHub.
- [ ] Run YAML validation, Gitleaks, Ansible syntax checks, and `ansible-lint` against all public playbooks.
- [ ] Stop excluding `home.yml`, `server-config.yml`, and `deploy-container.yml` from Ansible lint without a documented narrow reason.
- [ ] Add role tests for shared desktop, Ubuntu desktop, and macOS desktop separately.
- [ ] Add an Ubuntu VM acceptance test for a clean-laptop bootstrap.
- [ ] Run the laptop playbook twice and require the second run to report no unintended changes.
- [ ] Add a `laptop-doctor` command that verifies the expected packages, services, desktop session, portals, networking, backup, and security state.

## Existing deployment cleanup

- [ ] Make `home -y` use the same declarative Ansible path instead of bypassing it with direct rsync copies.
- [ ] Define which deployed files are managed and how obsolete managed files are safely removed.
- [ ] Update the root READMEs with supported entry points, platform scope, prerequisites, and recovery instructions.
- [ ] Correct completed task claims that currently describe system-IaC work which has not been implemented.
