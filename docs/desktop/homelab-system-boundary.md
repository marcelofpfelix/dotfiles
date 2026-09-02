# Homelab System Boundary

Dotfiles own user-level Hyprland, Quickshell, shell helpers, and validation. System-wide desktop policy belongs in the sibling homelab repo, not the home role.

## Homelab-Owned Tasks

- Firewall and LocalSend exceptions: decide allowed LAN ports and profiles in system automation.
- SSH daemon policy: enable/disable, listen addresses, keys, and hardening outside dotfiles.
- Docker exposure lockdown: daemon socket, published ports, and bridge/firewall policy outside dotfiles.
- Time sync repair: chrony/systemd-timesyncd package, service, and stepping policy outside the home role.
- Package update workflow: OS/package refresh, reboot gates, and update notifications outside Quickshell helpers.
- Hibernation: swap/resume setup and kernel parameters outside dotfiles; Quickshell may only show an already-supported action.
- Snapshots/backups: Btrfs/Timeshift/restic or equivalent system setup outside dotfiles.
- Fingerprint/Fido: PAM, sudo, polkit, and locker integration outside dotfiles.
- Tailscale: install, auth policy, routes, and DNS outside dotfiles.

## Dotfiles-Owned Checks

- `desktop/tools/desktop-doctor` may report whether required user-facing helpers exist.
- `hypr-session smoke` may report locker, portal, clock, and package-intent status.
- Quickshell may expose buttons for already-supported system actions, but must not configure the system from the home role.
