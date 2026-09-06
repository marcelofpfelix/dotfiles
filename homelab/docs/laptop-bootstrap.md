# Laptop bootstrap before Ansible

Ansible needs a reachable SSH service before it can manage the laptop.

1. On the laptop console, find the interface MAC addresses:

   ```sh
   ip a
   ```

   Reserve the selected address in the router DHCP configuration, then record
   the MAC-to-address mapping in Homework `workdesk/hardware.yml`.

2. On the laptop console, enable SSH:

   ```sh
   sudo apt update
   sudo apt install -y openssh-server
   sudo ss -ltnp | grep ':22'
   ```

3. On the laptop console, allow the managed user to run Ansible's privileged
   tasks without an interactive password prompt:

   ```sh
   printf '%s\n' 'marcelof ALL=(ALL:ALL) NOPASSWD: ALL' \
     | sudo tee /etc/sudoers.d/90-marcelof-nopasswd >/dev/null
   sudo chmod 0440 /etc/sudoers.d/90-marcelof-nopasswd
   sudo visudo -cf /etc/sudoers
   sudo -k
   sudo -n true
   ```

   `visudo` validates the complete sudo configuration; `sudo -n true` confirms
   that automation will not stop for a password prompt.

4. On the laptop console, enable future LTS-to-LTS release upgrades. This was
   completed on `lap1` during bootstrap:

   ```sh
   sudo sed -i 's/^Prompt=.*/Prompt=lts/' \
     /etc/update-manager/release-upgrades
   grep '^Prompt=lts$' /etc/update-manager/release-upgrades
   ```

   This changes the upgrade policy only; it does not start a release upgrade.

5. From the controller, install and verify the existing Homelab key:

   ```sh
   ssh-copy-id -i ~/default/.tmp/id_ed25519_homelab.pub \
     lap1
   ssh lap1
   ```

6. From the Dotfiles `homelab/` directory on the controller, install the
   pinned Galaxy dependencies, then run the public home sync so the locked
   desktop flake exists on the laptop before system configuration:

   ```sh
   uv run --extra dev ansible-galaxy collection install --force \
     -r collections/requirements.yml
   home -t lap1 -y
   ```

   The Home play keeps the key authorised and syncs the managed home, Dotfiles,
   shell, and SSH configuration. Service/container deployment remains a
   separate lifecycle.

7. Inspect the system configuration without changing the laptop:

   ```sh
   uv run --extra dev ansible-playbook playbooks/config.yml --check --diff \
     -e config_target=lap1 --tags gui
   ```

   Remove `--check --diff` only after reviewing the selected hosts and proposed
   changes. APT and firmware maintenance require their own explicit tags; see
   [configuration.md](configuration.md). Override `config_nix_desktop_flake`
   when Dotfiles is intentionally synced to a different target path.
