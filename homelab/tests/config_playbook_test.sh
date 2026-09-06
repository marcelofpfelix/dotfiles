#!/bin/sh
set -eu

homelab_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
playbook="$homelab_root/playbooks/config.yml"
profile_vars="$homelab_root/vars/config.yml"
inventory="$homelab_root/inventory.ini"
docs="$homelab_root/docs/configuration.md"
package_audit="$homelab_root/../desktop/tools/desktop-package-audit"
bootstrap_doc="$homelab_root/docs/laptop-bootstrap.md"
desktop_flake="$homelab_root/../desktop/nix/flake.nix"
desktop_lock="$homelab_root/../desktop/nix/flake.lock"
hypr_session="$homelab_root/../desktop/bin/hypr-session"
hypr_gdm="$homelab_root/../desktop/bin/hypr-gdm"

fail() {
    printf 'config composition contract failed: %s\n' "$1" >&2
    exit 1
}

[ -f "$playbook" ] || fail 'missing playbooks/config.yml'
[ -f "$profile_vars" ] || fail 'missing vars/config.yml'
[ -f "$docs" ] || fail 'missing configuration documentation'
[ ! -e "$homelab_root/laptop.yml" ] || fail 'laptop.yml must be replaced by config.yml'
[ ! -e "$homelab_root/server-config.yml" ] || fail 'server-config.yml must be replaced by config.yml'

grep -Fq 'hosts: "{{ config_target | mandatory }}"' "$playbook" || fail 'mandatory generic target selector is missing'
grep -Fq 'server_config_target_is_explicit: true' "$playbook" || fail 'explicit-target guard is missing'
grep -Fq 'role: marcelofpfelix.homelab.server' "$playbook" || fail 'server role is missing'
for capability in packages docker dns macos hardening; do
    grep -Fq "server_config_manage_${capability}: false" "$playbook" || fail "unrelated ${capability} capability is not explicitly disabled"
done
if grep -Eq '^[[:space:]]+- config$' "$playbook"; then
    fail 'broad config tag can bypass named maintenance tags'
fi
if grep -Fq 'server_config_allowed_distributions:' "$playbook"; then
    fail 'generic config playbook hard-codes a distribution'
fi
if grep -Fq 'marcelofpfelix.homelab.home' "$playbook"; then
    fail 'home configuration must remain a separate entry point'
fi
if grep -Fq 'marcelofpfelix.homelab.service' "$playbook"; then
    fail 'service deployment must remain separate'
fi

for profile in gui gui_work gui_linux desktop_linux cli cli_work cli_linux; do
    grep -Fq "$profile:" "$profile_vars" || fail "missing $profile application list"
done
for app in brave ghostty; do
    grep -A3 -F 'gui:' "$profile_vars" | grep -Fq "  - $app" || fail "gui missing $app"
done
for app in slack onepassword google_chrome wireshark; do
    grep -A5 -F 'gui_work:' "$profile_vars" | grep -Fq "  - $app" || fail "gui_work missing $app"
done
for app in network_manager pavucontrol swappy; do
    grep -A4 -F 'gui_linux:' "$profile_vars" | grep -Fq "  - $app" || fail "gui_linux missing $app"
done
for app in hyprland quickshell; do
    grep -A3 -F 'desktop_linux:' "$profile_vars" | grep -Fq "  - $app" || fail "desktop_linux missing $app"
done
for file in "$desktop_flake" "$desktop_lock"; do
    [ -s "$file" ] || fail "missing pinned desktop closure: ${file##*/}"
done
grep -Fq 'pkgs.hyprland' "$desktop_flake" || fail 'Hyprland is not sourced from pinned nixpkgs'
grep -Fq 'quickshell.packages.${system}.default' "$desktop_flake" || fail 'Quickshell is not sourced from its pinned flake'
grep -Fq 'xdg-desktop-portal-hyprland' "$desktop_flake" || fail 'matching Hyprland portal is absent from the closure'
grep -Fq 'nixGLIntel' "$desktop_flake" || fail 'the pure Mesa nixGL wrapper is absent from the non-NixOS closure'
grep -Fq 'writeShellScriptBin "nixGL"' "$desktop_flake" || fail 'the Mesa wrapper is not exposed as nixGL for start-hyprland'
for app in fzf gum htop jq oath_toolkit taskwarrior timewarrior; do
    grep -A7 -F 'cli:' "$profile_vars" | grep -Fq "  - $app" || fail "cli missing $app"
done
for app in sngrep tcpdump; do
    grep -A3 -F 'cli_work:' "$profile_vars" | grep -Fq "  - $app" || fail "cli_work missing $app"
done
if grep -A3 -F 'cli_work:' "$profile_vars" | grep -Fq '  - oath_toolkit'; then
    fail 'oath_toolkit must be in cli, not cli_work'
fi
for app in bluez brightnessctl ddcutil dex ffmpeg grim imagemagick libnotify lm_sensors mpv network_manager playerctl power_profiles_daemon pulseaudio_utils slurp tesseract upower wf_recorder wireplumber wl_clipboard xdg_utils; do
    grep -A23 -F 'cli_linux:' "$profile_vars" | grep -Fq "  - $app" || fail "cli_linux missing $app"
done
grep -Eq '^lap1[[:space:]]+config_profiles_csv=gui,gui_work,gui_linux,desktop_linux,cli,cli_work,cli_linux,apt_upgrades,apt_full_upgrade,firmware,ubuntu_cleanup$' "$inventory" || fail 'lap1 capability profiles are not declared'
grep -Fq 'config_known_profiles:' "$profile_vars" || fail 'known profile allow-list is missing'
grep -Fq 'gather_facts: false' "$playbook" || fail 'profiles are not validated before fact gathering'
grep -Fq 'ansible.builtin.setup:' "$playbook" || fail 'explicit fact gathering is missing after validation'
grep -Fq 'difference(config_known_profiles)' "$playbook" || fail 'unknown host profiles are not rejected'
grep -Fq "(config_profiles_csv | default('')).split(',')" "$playbook" || fail 'CSV profiles are not normalized once'
grep -Fq 'server_config_manage_gui_apps:' "$playbook" || fail 'GUI profile enablement is not passed to the role'
grep -Fq 'server_config_gui_apps:' "$playbook" || fail 'shared GUI selection is not passed to the role'
grep -Fq 'server_config_gui_linux_apps:' "$playbook" || fail 'Linux GUI selection is not passed to the role'
grep -Fq 'server_config_manage_nix_desktop:' "$playbook" || fail 'Nix desktop profile enablement is not passed to the role'
grep -Fq 'server_config_nix_desktop_flake:' "$playbook" || fail 'desktop flake path is not passed to the role'
grep -Fq 'server_config_nix_desktop_session_launcher: "{{ ansible_user_dir }}/bin/hypr-session"' "$playbook" || fail 'desktop session launcher is not passed to the role'
grep -Fq 'server_config_nix_desktop_user: "{{ ansible_user_id }}"' "$playbook" || fail 'desktop user depends on undefined ansible_user'
grep -Fq 'server_config_wireshark_capture_user: "{{ ansible_user_id }}"' "$playbook" || fail 'Wireshark capture user depends on undefined ansible_user'
grep -Fq 'server_config_manage_cli_apps:' "$playbook" || fail 'CLI profile enablement is not passed to the role'
grep -Fq 'server_config_cli_apps:' "$playbook" || fail 'shared CLI selection is not passed to the role'
grep -Fq 'server_config_cli_linux_apps:' "$playbook" || fail 'Linux CLI selection is not passed to the role'
grep -Fq 'server_config_upgrade_packages:' "$playbook" || fail 'APT upgrade profile is not passed to the role'
grep -Fq 'server_config_full_upgrade_packages:' "$playbook" || fail 'full APT upgrade profile is not passed to the role'
grep -Fq 'server_config_upgrade_firmware:' "$playbook" || fail 'firmware profile is not passed to the role'
grep -Fq 'server_config_cleanup_ubuntu:' "$playbook" || fail 'Ubuntu cleanup profile is not passed to the role'
grep -Fq 'Apply non-maintenance profiles:' "$docs" || fail 'normal convergence scope is not documented accurately'
if grep -Fq 'Apply all declared profiles:' "$docs"; then
    fail 'documentation wrongly claims untagged convergence applies maintenance'
fi
for tag in gui apt_upgrades apt_full_upgrade firmware ubuntu_cleanup; do
    grep -Fq "$tag" "$docs" || fail "documentation omits $tag tag"
done
grep -Fq 'only with an explicit maintenance tag' "$docs" || fail 'maintenance never-tag behaviour is not documented'
grep -Fq '`gui_linux` is a selectable bundle of logical names' "$docs" || fail 'gui_linux semantics are unclear'
grep -Fq '`cli_linux` is a selectable bundle of logical names' "$docs" || fail 'cli_linux semantics are unclear'
grep -Fq 'homelab/vars/config.yml' "$package_audit" || fail 'desktop package audit does not use executable profile intent'
for app in hyprland quickshell; do
    grep -Fq "  $app" "$package_audit" || fail "desktop package audit omits $app"
done
for script in "$hypr_session" "$hypr_gdm"; do
    if grep -Fq '.nix-profile/bin' "$script"; then
        fail "${script##*/} retains a hard-coded legacy Nix profile path"
    fi
    grep -Fq '.local/share/dotfiles-nix/desktop/bin' "$script" || fail "${script##*/} omits the declared desktop closure path"
done
grep -Fq 'exec start-hyprland --force-nixgl' "$hypr_session" || fail 'Hyprland session does not require the non-NixOS graphics wrapper'
if grep -R -Fq '.nix-profile/bin' \
    "$homelab_root/../desktop/bin" \
    "$homelab_root/../desktop/tools" \
    "$homelab_root/../desktop/.config/hypr" \
    "$homelab_root/../desktop/.config/systemd/user"; then
    fail 'active desktop runtime retains hard-coded legacy Nix profile paths'
fi
grep -Fq 'config_nix_desktop_flake:' "$profile_vars" || fail 'desktop flake path is not an explicit composition variable'
grep -Fq 'server_config_nix_desktop_flake: "{{ config_nix_desktop_flake }}"' "$playbook" || fail 'config playbook hard-codes the target desktop flake path'
home_line=$(grep -n -F 'home -t lap1 -y' "$bootstrap_doc" | cut -d: -f1)
config_line=$(grep -n -F 'ansible-playbook playbooks/config.yml --check --diff' "$bootstrap_doc" | cut -d: -f1)
[ -n "$home_line" ] && [ -n "$config_line" ] && [ "$home_line" -lt "$config_line" ] \
    || fail 'bootstrap config runs before Dotfiles exists on the target'

DOTFILES_ROOT="$homelab_root/.." "$package_audit" >/dev/null || fail 'desktop package audit does not match profile intent'

printf 'config composition contract: ok\n'
