# Private data

This repository keeps machine-specific inventory, work-specific service
definitions, and secrets out of git.

Ignored local paths:

- `group_vars/`
- `host_vars/`
- `templates/`
- `tasks/`
- `scripts/`
- `vars/work/`
- `.vault_pass` (legacy local fallback; prefer the gopass client)
- `.ansible/`

## Recommended layout

Use this repository for public, reusable automation and keep private state in a
separate private repository or encrypted secret store.

Recommended private repository shape using GNU Stow:

```text
homework/
  homelab/
    group_vars/
    host_vars/
    templates/
    tasks/
    scripts/
    vars/
      work/
```

Link the private overlay into this checkout:

```sh
make private-link
```

Remove the links:

```sh
make private-unlink
```

The Makefile defaults to:

```text
PRIVATE_REPO=../homework
PRIVATE_PACKAGE=homelab
```

Override those values when needed:

```sh
make private-link PRIVATE_REPO=../homework PRIVATE_PACKAGE=homelab-lab01
```

One-time migration outline:

```sh
mkdir -p ../homework/homelab/vars
mv group_vars ../homework/homelab/
mv host_vars ../homework/homelab/
mv templates ../homework/homelab/
mv vars/work ../homework/homelab/vars/
make private-link
```

Review the private repository before committing it. In particular, move secrets
into vault files before committing `../homework/homelab`.

`stow` is a good fit here because the public repository keeps the canonical
paths that Ansible expects, while the private repository owns the actual files.
Ansible can keep loading `group_vars/`, `host_vars/`, `templates/`, and
`vars/work/` normally after the links are created.

The private repository should have its own secret scanning and should never be
published as a container image build context.


## Vault password storage

Do not store the Ansible Vault password in a plaintext `.vault_pass` file. The
public checkout does not configure a vault password file by default, because this
repo currently loads runtime secrets from gopass and may not have vault-encrypted
files.

If the private overlay contains Ansible Vault encrypted files, use the private
`tasks/` and `scripts/` overlay and point Ansible at the gopass client only for
that run:

```sh
ANSIBLE_VAULT_PASSWORD_FILE=scripts/ansible-vault-gopass-client ansible-playbook deploy-container.yml
```

Create the gopass entry once:

```sh
gopass insert homelab/ansible_vault
```

The `community.general.passwordstore` lookup in `tasks/load-secrets.yml` is for
loading individual application secrets into playbooks. It is not the best place
to store the Ansible Vault password itself, because Ansible needs the vault
password before it can decrypt vault-encrypted vars.

## When to use encryption

Use `ansible-vault` or SOPS for values that must be versioned with history, such
as passwords, tokens, private keys, and webhook URLs. Prefer a separate private
repository for full private inventories and generated service configs.

Recommended Ansible Vault layout inside the private overlay:

```text
homework/
  homelab/
    group_vars/
      all/
        vars.yml
        vault.yml
```

Keep non-secret private values in `vars.yml`:

```yaml
---
dns_server: 10.0.0.1
```

Keep secrets in encrypted `vault.yml`:

```sh
ansible-vault create ../homework/homelab/group_vars/all/vault.yml
```

Use stable variable names from normal vars and secret values from vault:

```yaml
---
default_password: "{{ vault_default_password }}"
```

Do not commit plaintext secrets, even in ignored examples or docs.
