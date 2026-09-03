#!/bin/sh
set -eu

homelab_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
playbook="$homelab_root/laptop.yml"
desktop_vars="$homelab_root/vars/laptop/desktop.yml"
ubuntu_vars="$homelab_root/vars/laptop/ubuntu.yml"
macos_vars="$homelab_root/vars/laptop/macos.yml"

fail() {
    printf 'laptop composition contract failed: %s\n' "$1" >&2
    exit 1
}

[ -f "$playbook" ] || fail "missing laptop.yml"
[ -f "$desktop_vars" ] || fail "missing shared desktop profile"
[ -f "$ubuntu_vars" ] || fail "missing Ubuntu profile"
[ -f "$macos_vars" ] || fail "missing macOS profile"

grep -Fq 'hosts: "{{ laptop_target | default('\''all'\'') }}"' "$playbook" || fail "laptop target fallback is not lint-compatible"
grep -Fq 'server_config_target_is_explicit: "{{ laptop_target is defined }}"' "$playbook" || fail "omitted laptop targets are not rejected by the collection role"
grep -Fq 'role: marcelofpfelix.homelab.server' "$playbook" || fail "server role is missing"
grep -Fq 'role: marcelofpfelix.homelab.home' "$playbook" || fail "home role is missing"
server_line=$(grep -n 'role: marcelofpfelix.homelab.server' "$playbook" | cut -d: -f1)
home_line=$(grep -n 'role: marcelofpfelix.homelab.home' "$playbook" | cut -d: -f1)
[ "$server_line" -lt "$home_line" ] || fail "server role must run before home role"

grep -Fq 'server_config_require_single_host: true' "$playbook" || fail "single-host protection is not enabled"
grep -Fq 'server_config_allowed_distributions:' "$playbook" || fail "Ubuntu platform restriction is missing"
grep -Fq 'server_config_manage_sudo: false' "$playbook" || fail "broad sudo configuration must remain disabled"
grep -Fq 'server_config_desktop_packages_common: "{{ laptop_desktop_common_packages }}"' "$playbook" || fail "shared desktop packages are not passed to the server role"
grep -Fq 'server_config_desktop_packages_ubuntu: "{{ laptop_ubuntu_packages }}"' "$playbook" || fail "Ubuntu packages are not passed to the server role"
if grep -Fq 'server_config_manage_desktop_packages' "$playbook"; then
    fail "laptop.yml uses a redundant desktop package toggle"
fi
grep -Fq 'laptop_desktop_home_tags | combine(laptop_ubuntu_home_tags)' "$playbook" || fail "shared and Ubuntu home layers are not combined"

if grep -Fq 'marcelofpfelix.homelab.service' "$playbook"; then
    fail "service deployment must remain separate from laptop provisioning"
fi
if grep -Eq '^[[:space:]]*(pre_)?tasks:' "$playbook"; then
    fail "reusable Ansible tasks belong in the collection roles"
fi

grep -Fq 'dir: default' "$desktop_vars" || fail "default home layer is missing"
grep -Fq 'dir: desktop' "$desktop_vars" || fail "shared desktop home layer is missing"
grep -Fq 'dir: default_debian' "$ubuntu_vars" || fail "Ubuntu default layer is missing"
grep -Fq 'dir: desktop_debian' "$ubuntu_vars" || fail "Ubuntu desktop layer is missing"
grep -Fq 'dir: desktop_darwin' "$macos_vars" || fail "macOS desktop layer is missing"

printf 'laptop composition contract: ok\n'
