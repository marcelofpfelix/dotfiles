#!/bin/sh
set -eu

homelab_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
dotfiles_root="$(CDPATH='' cd -- "$homelab_root/.." && pwd)"

fail() {
    printf 'homelab layout contract failed: %s\n' "$1" >&2
    exit 1
}

for playbook in config home deploy-container deploy-service deploy-service-dummy; do
    [ -f "$homelab_root/playbooks/$playbook.yml" ] || fail "missing playbooks/$playbook.yml"
    [ ! -e "$homelab_root/$playbook.yml" ] || fail "$playbook.yml remains at project root"
done

[ -f "$homelab_root/playbooks/tasks/load-private-secrets.yml" ] || fail 'public private-secret adapter is missing'
git -C "$dotfiles_root" ls-files --error-unmatch \
    homelab/playbooks/tasks/load-private-secrets.yml >/dev/null 2>&1 \
    || fail 'public private-secret adapter is not tracked'
for playbook in home deploy-container; do
    grep -Fq 'ansible.builtin.include_tasks: tasks/load-private-secrets.yml' \
        "$homelab_root/playbooks/$playbook.yml" || fail "$playbook bypasses the public secret adapter"
done

[ -f "$homelab_root/collections/requirements.yml" ] || fail 'missing collections/requirements.yml'
[ ! -e "$homelab_root/requirements.yml" ] || fail 'legacy root requirements.yml remains'
[ -f "$homelab_root/tests/config_playbook_test.sh" ] || fail 'tests directory is not canonical'
[ ! -d "$homelab_root/test" ] || fail 'legacy test directory remains'

grep -Fq 'inventory = inventory.ini' "$homelab_root/ansible.cfg" || fail 'inventory path changed unexpectedly'
! grep -Fqx '[mac]' "$homelab_root/inventory.ini" || fail 'mac host/group collision remains'
grep -Fqx '[macos]' "$homelab_root/inventory.ini" || fail 'macOS inventory group is missing'
grep -Fq 'collections_path = ./collections:' "$homelab_root/ansible.cfg" || fail 'collection path is not isolated'
grep -Fq 'collections/ansible_collections/' "$homelab_root/.gitignore" || fail 'local collection override is not ignored'
grep -Fq 'ansible-galaxy collection install -r collections/requirements.yml -p collections' \
    "$homelab_root/Dockerfile" || fail 'container does not install pinned collections'
grep -Fq '!collections/requirements.yml' "$homelab_root/.dockerignore" || fail 'container excludes collection requirements'
grep -Fq '!playbooks/**' "$homelab_root/.dockerignore" || fail 'container excludes playbook contents'
grep -Fq 'offline: true' "$homelab_root/.ansible-lint" || fail 'ansible-lint dependency installation is implicit'
grep -Fq '  - collections/ansible_collections/' "$homelab_root/.ansible-lint" || fail 'ansible-lint scans installed collections'
grep -Fq '  - files/' "$homelab_root/.ansible-lint" || fail 'ansible-lint treats payload files as playbooks'
grep -A1 -F 'extra_vars:' "$homelab_root/.ansible-lint" | grep -Fq 'config_target: localhost' || fail 'ansible-lint target is undefined'
grep -Fq 'version: c80213f' "$homelab_root/collections/requirements.yml" || fail 'Homelab collection is not immutably pinned'
if grep -Eq 'version:.*[><~^*]' "$homelab_root/collections/requirements.yml"; then
    fail 'collection dependency uses a mutable version range'
fi

[ -f "$dotfiles_root/.github/workflows/homelab-ci.yml" ] || fail 'Homelab CI is not discoverable at repository root'
[ ! -e "$homelab_root/.github/workflows/ci.yml" ] || fail 'undiscoverable nested workflow remains'
grep -Fq 'check: pre test-layout test-config-playbook syntax' "$homelab_root/Makefile" || fail 'check target omits a Homelab verification gate'
grep -Fq 'make check' "$dotfiles_root/.github/workflows/homelab-ci.yml" || fail 'CI bypasses the scoped Homelab quality gate'
grep -Fq 'uv run --extra dev pre-commit run --config .pre-commit-config.yaml --all-files' \
    "$homelab_root/Makefile" || fail 'Homelab pre-commit does not select its scoped configuration'
grep -Fq 'entry: homelab/ci/ansible-lint.sh' "$homelab_root/.pre-commit-config.yaml" || fail 'Ansible lint hook does not enter the nested project'
grep -Fq 'entry: act -W .github/workflows/homelab-ci.yml -j pre-commit' \
    "$dotfiles_root/.pre-commit-config.yaml" || fail 'manual act hook points at a stale workflow'

grep -Fq 'inventory_target_is_host "$target"' "$dotfiles_root/desktop/bin/home" || fail 'home wrapper does not guard SSH user resolution to concrete inventory hosts'
test ! -e "$dotfiles_root/desktop/.config/systemd/user/elephant.service" || fail 'excluded Elephant still owns an active user service'
if grep -Fq 'check_cmd walker yes' "$dotfiles_root/desktop/tools/desktop-doctor" || grep -Fq 'run_required walker-websearch' "$dotfiles_root/desktop/tools/desktop-doctor"; then
    fail 'excluded Walker remains a required desktop dependency'
fi
grep -Fq 'ssh -G "$target"' "$dotfiles_root/desktop/bin/home" || fail 'home wrapper does not resolve the SSH user'
grep -Fq 'ansible_user=%s' "$dotfiles_root/desktop/bin/home" || fail 'home wrapper does not pass the resolved SSH user to Ansible'
grep -Fq 'flags=" -e set_ssh=false -e set_shrc=true"' "$dotfiles_root/desktop/bin/home" \
    || fail 'home wrapper enables SSH bootstrap by default'
grep -Fq 'inventory="$homelab_run/inventory.ini"' "$dotfiles_root/desktop/bin/home" \
    || fail 'home wrapper bypasses the private overlay inventory'
grep -Fq '$homelab_run/playbooks/home.yml' "$dotfiles_root/desktop/bin/home" || fail 'home wrapper does not use playbooks directory'
grep -Fq 'ln -s "../$inventory_vars" "$homelab_overlay/playbooks/$inventory_vars"' \
    "$dotfiles_root/desktop/bin/home" || fail 'private inventory vars are not exposed beside the relocated playbook'

printf 'homelab layout contract: ok\n'
