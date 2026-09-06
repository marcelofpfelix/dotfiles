# System configuration

`playbooks/config.yml` is the single public system-configuration playbook. It invokes the
collection `server` role and lets that role route tasks from gathered facts:

- Debian-family systems use APT, Snap, and `fwupd` where selected;
- Darwin systems use Homebrew formulae and casks;
- unsupported platform-specific layers are skipped.

Home folders, dotfiles, shell and SSH remain in `playbooks/home.yml`. Services and
containers remain in their service playbooks.

## Host profiles

Hosts declare comma-separated capabilities in `inventory.ini`. `lap1` uses:

```ini
lap1 config_profiles_csv=gui,gui_work,gui_linux,cli,cli_work,cli_linux,apt_upgrades,apt_full_upgrade,firmware,ubuntu_cleanup
```

Application intent lives in `vars/config.yml`:

- `gui`: shared personal GUI applications (`brave`, `ghostty`);
- `gui_work`: shared work GUI applications (`slack`, `onepassword`,
  `google_chrome`, `wireshark`);
- `gui_linux` is a selectable bundle of logical names for Linux-only GUI
  helpers used by the tracked desktop configuration;
- `desktop_linux` builds Hyprland, its matching portal, Quickshell, and `nixGL`
  from the checked-in `desktop/nix/flake.lock`;
- `cli` and `cli_work` contain shared CLI/TUI tools;
- `cli_linux` is a selectable bundle of logical names for Linux-only command
  backends called by the tracked Wayland configuration.

Hyprland and Quickshell are installed only when `desktop_linux` is selected.
APT continues to own Nix itself and Ubuntu session integration; the flake lock
owns the fast-moving desktop versions. Normal convergence never updates the lock. The closure uses nixGL's pure Mesa wrapper for Intel, AMD, and Nouveau graphics; proprietary NVIDIA requires an explicit host-specific design.

Logical names are mapped by the collection. Do not put platform package names
such as `google-chrome-stable`, `libnotify-bin`, or `pulseaudio-utils` in these
lists. Ghostty uses a stable classic Snap on Debian-family systems and a Homebrew
cask on Darwin. Wireshark uses Ubuntu's packages (including `tshark`) with
non-root capture enabled for the configured user; a new login is required after
the first group-membership change. Darwin uses the `wireshark-app` cask.

## Safety

An explicit target is required. The playbook may target one host or an intended
inventory group; it does not hard-code Ubuntu or Darwin. GUI remains disabled in
collection defaults and activates through the target's declared profiles. APT
and firmware profiles only establish host eligibility: maintenance executes
only with an explicit maintenance tag (`apt_upgrades`, `apt_full_upgrade`,
`firmware`, or `ubuntu_cleanup`). Full APT, firmware, and Ubuntu cleanup runs
also require exactly one selected host.

Inspect a target without applying changes:

```console
uv run ansible-playbook playbooks/config.yml --check --diff \
  -e config_target=lap1
```

On a clean Debian-family host, check mode validates selection and routing but
defers package-manager, repository, firmware and application operations whose
prerequisites cannot be created without mutation.

Apply non-maintenance profiles:

```console
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1
```

Run focused layers with tags:

```console
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1 --tags gui
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1 --tags cli
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1 --tags apt_upgrades
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1 --tags apt_full_upgrade
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1 --tags firmware
uv run ansible-playbook playbooks/config.yml --ask-become-pass \
  -e config_target=lap1 --tags ubuntu_cleanup
```

Routine APT upgrades use conservative `safe` semantics and reject package
removals. Full APT upgrades use `apt-get dist-upgrade` semantics and may install
new dependencies or remove conflicting packages; inspect the proposed changes
carefully and use `apt_full_upgrade` only for a deliberate one-host run. Neither
APT path reboots automatically. Firmware updates install `fwupd` plus
`fwupd-signed` on x86_64/aarch64 Debian-family systems, run only on
Debian-family systems, and do not reboot automatically; inspect the output and
reboot manually when requested.

`ubuntu_cleanup` is an exact-tag, Ubuntu-only destructive profile. It removes a
short explicit APT list for CUPS, Avahi, GNOME Calendar, Evolution, LibreOffice,
Thunderbird and Chromium, plus exact Thunderbird, LibreOffice and Chromium
snaps. Firefox, Brave, Google Chrome and Slack are untouched because they are not
in either list. APT autoremove is disabled. Check mode prints the two lists and
does not remove anything.

Tracker services, language packs, input methods, broad printer-driver cleanup,
and dependency-level cleanup are intentionally out of scope: they are not worth
the additional policy and maintenance code for this small cleanup task.

Slack uses its verified stable Snap on Debian-family systems. Chrome, Brave and
1Password use signed vendor APT repositories there. On Darwin the four logical
selectors resolve to Homebrew casks. 1Password remains last in both resolved
platform orders.
