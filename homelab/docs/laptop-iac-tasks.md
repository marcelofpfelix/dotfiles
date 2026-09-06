# Laptop IaC tasks

These tasks track the complete laptop build. The generic `playbooks/config.yml` invokes
the collection `server` role for system configuration, `playbooks/home.yml` retains home
folders, dotfiles and SSH, and `service` remains responsible for
service/container deployment.

## Architecture

- [x] Replace overlapping laptop/server wrappers with `homelab/playbooks/config.yml`.
  - Acceptance: requires an explicit target, supports hosts or groups, and delegates platform detection and tagged capabilities to the collection.
- [ ] Complete the shared desktop layer for configuration common to Linux and macOS.
  - Progress: public `default` and `desktop` home tags plus common package definitions now feed the collection roles.
  - Examples: user identity, Git, shell tools, editor configuration, repositories, agent tooling, and dotfile deployment where behaviour is genuinely portable.
- [ ] Complete the Ubuntu-only desktop layer.
  - Progress: public `default_debian` and `desktop_debian` home tags plus Ubuntu package definitions now feed the collection roles.
  - Examples: APT repositories/packages, Hyprland, Quickshell, portals, PipeWire, NetworkManager, systemd user units, firmware, firewall, update policy, hibernation, backup integration, hardware support, and Tailscale.
- [ ] Complete the macOS-only desktop layer.
  - Progress: the `desktop_darwin` home-tag definition exists; macOS composition and packages remain deferred.
- [x] Keep machine-specific and secret values in the Homework overlay; keep reusable role tasks and defaults in `ansible-collection-homelab`, and keep playbook composition plus public profiles in Dotfiles.
- [x] Keep reusable laptop role work in the external collection.
  - Homelab loads the sibling collection's local `main` worktree directly;
    Dotfiles contains no duplicate role tasks.

## Bootstrap and recovery

- [ ] Add one documented bootstrap command for a freshly installed Ubuntu laptop.
  - Acceptance: installs only the minimum prerequisites needed to run Ansible, then invokes `playbooks/config.yml` with an explicit target.
- [ ] Document the bootstrap order: public baseline, secret-store recovery, Homework overlay, work overlay, then acceptance checks.
- [ ] Allow the public/shared baseline to run before gopass secrets are restored.
- [ ] Separate secret-dependent work templates from ordinary home and desktop configuration.
- [ ] Add backup restore and disaster-recovery checks for user data and the secret store.

## Package management

- [x] Replace `vars/install/desktop.yml` as a passive software list with executable profile definitions in `vars/config.yml` consumed by the collection.
- [ ] Split package definitions into shared desktop intent, Ubuntu package mappings, and macOS package mappings.
- [ ] Track or deliberately remove the currently missing desktop dependencies: `cliamp`, `dua-cli`, `omawrite`, `hyprsunset`, and `wlrctl`.
- [ ] Pin third-party repositories, packages, downloaded artefacts, and checksums where native repositories are not used.
  - Progress: shared logical selectors map to Darwin Homebrew casks or Debian-family Snap/APT sources; `gui_linux` owns Linux-only graphical helpers.
- [x] Define ownership between APT, Homebrew, Nix, mise, uv tools, and locally built binaries; avoid installing the same tool through multiple managers.
  - Decision: the collection maps shared GUI intent by platform. Snap owns Slack and APT owns Chrome, Brave, and 1Password on Debian-family systems; Homebrew casks own them on Darwin. mise owns development runtimes, and Nix must not duplicate these GUI packages.

## Inventory and security

- [x] Replace host/group name collisions for `laptop` and `mac` with distinct group and host names.
- [x] Give the new laptop explicit shared and Ubuntu desktop profiles consumed by the collection `server` and `home` roles; do not rely on `desktop: true` as an unused marker.
- [ ] Remove global `StrictHostKeyChecking=no` from public and private Ansible configuration.
- [ ] Manage trusted SSH host keys explicitly.
- [x] Keep unrestricted passwordless sudo as the explicit, user-specific step
  documented in `laptop-bootstrap.md`; do not grant `NOPASSWD: ALL` to the
  entire sudo group.
- [ ] Add Ubuntu security definitions for firewall policy, unattended security updates, SSHD policy, Docker exposure, and encryption-state verification.

## CI and acceptance

- [x] Move Homelab CI into the repository-root GitHub Actions workflow; nested workflows are not discovered by GitHub.
- [x] Run YAML validation, Gitleaks, Ansible syntax checks, and `ansible-lint` against all public playbooks.
- [x] Stop excluding `playbooks/home.yml` and `playbooks/deploy-container.yml` from Ansible lint without a documented narrow reason.
- [ ] Add role tests for shared desktop, Ubuntu desktop, and macOS desktop separately.
- [ ] Add an Ubuntu VM acceptance test for a clean-laptop bootstrap.
- [ ] Run the laptop playbook twice and require the second run to report no unintended changes.
- [ ] Add a `laptop-doctor` command that verifies the expected packages, services, desktop session, portals, networking, backup, and security state.

## Existing deployment cleanup

- [ ] Make `home -y` use the same declarative Ansible path instead of bypassing it with direct rsync copies.
- [ ] Define which deployed files are managed and how obsolete managed files are safely removed.
- [ ] Update the root READMEs with supported entry points, platform scope, prerequisites, and recovery instructions.
- [ ] Correct completed task claims that currently describe system-IaC work which has not been implemented.
