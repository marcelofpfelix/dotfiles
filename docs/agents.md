# Agent configuration deployment

Canonical agent instructions, identities, profiles, and portable skills live in the private Agents repository. Dotfiles owns only the public-safe local deployment mechanism.

Run a dry-run first:

```sh
agents-deploy --profile work
```

Apply or verify:

```sh
agents-deploy --apply --profile work
agents-deploy --check --profile work
```

Profiles map to John for work, Eusebio for personal, and Constanca for family. Pi and OpenCode use work by default. The deployer links their `AGENTS.md` files and the portable skill directory directly to the canonical repository, so it does not maintain copied instruction bodies. During the transition it also links Codex's `AGENTS.md` and Claude's `CLAUDE.md` to the same selected profile; those are compatibility adapters, not canonical sources.

The deployer never overwrites an existing unmanaged path. Preserve and move an old target explicitly before applying. This prevents migration from silently deleting legacy skill trees or local instructions.

If the live `~/.agents/skills` directory is intentionally composed from per-skill links, update only instruction adapters without taking ownership of that directory:

```sh
agents-deploy --apply --instructions-only --profile work
```

Private, organization-specific, credential-aware, Docker-context, and Hermes deployment belongs in Homework or Homelab. Secret values must remain in gopass or runtime environment files and must never be rendered by this public script.

## Brain access

Agents use `notesmd-cli` as the headless interface to the canonical Markdown
Brain. It reads the vault directly and does not require Obsidian to be running.
Register only the roots appropriate to the active profile, then search and read
with an explicit vault name:

```sh
notesmd-cli add-vault /path/to/agents/main/brain/academy
notesmd-cli add-vault /path/to/agents/main/brain/telnyx
notesmd-cli search-content "focused terms" --vault academy --format json
notesmd-cli print "path/to/concept.md" --vault telnyx
```

Obsidian remains an optional desktop editor. QMD is an optional future semantic
index, not a required dependency; use it only after its native runtime passes
the repository's release-age and compatibility checks. `rg` and `fd` remain the
portable fallback for direct Markdown search.

NotesMD 0.3.6 does not traverse a vault whose root is a symlink, so register the
physical backing directories: `academy` for logical `shared`, `notes` for
`personal`, `notepad` for `family`, and `telnyx` for `work`. Continue to use the
logical paths when editing Brain.
