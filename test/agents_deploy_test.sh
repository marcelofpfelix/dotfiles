#!/bin/sh
set -eu

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

repo_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
deploy="$repo_root/desktop/bin/agents-deploy"
agents_root="$test_dir/agents"
fake_home="$test_dir/home"

mkdir -p \
  "$agents_root/profiles/work/john" \
  "$agents_root/profiles/personal/eusebio" \
  "$agents_root/profiles/family/constanca" \
  "$agents_root/skills/portable" \
  "$agents_root/adapters/pi" \
  "$fake_home"

printf '# john\n' >"$agents_root/profiles/work/john/AGENTS.md"
printf '# eusebio\n' >"$agents_root/profiles/personal/eusebio/AGENTS.md"
printf '# constanca\n' >"$agents_root/profiles/family/constanca/AGENTS.md"
printf '{"mcpServers":{}}\n' >"$agents_root/adapters/pi/mcp.json"

dry_run="$("$deploy" --agents-root "$agents_root" --home "$fake_home" --profile work)"
case "$dry_run" in
  *'would link'*'.pi/agent/AGENTS.md'*'profiles/work/john/AGENTS.md'*) ;;
  *) printf 'dry-run did not select John work profile: %s\n' "$dry_run" >&2; exit 1 ;;
esac

[ ! -e "$fake_home/.pi/agent/AGENTS.md" ] || {
  printf 'dry-run changed the target home\n' >&2
  exit 1
}

"$deploy" --apply --agents-root "$agents_root" --home "$fake_home" --profile work

[ "$(realpath "$fake_home/.pi/agent/AGENTS.md")" = "$(realpath "$agents_root/profiles/work/john/AGENTS.md")" ]
[ "$(realpath "$fake_home/.config/opencode/AGENTS.md")" = "$(realpath "$agents_root/profiles/work/john/AGENTS.md")" ]
[ "$(realpath "$fake_home/.codex/AGENTS.md")" = "$(realpath "$agents_root/profiles/work/john/AGENTS.md")" ]
[ "$(realpath "$fake_home/.claude/CLAUDE.md")" = "$(realpath "$agents_root/profiles/work/john/AGENTS.md")" ]
[ "$(realpath "$fake_home/.agents/skills")" = "$(realpath "$agents_root/skills/portable")" ]
[ "$(realpath "$fake_home/.agents/mcp.json")" = "$(realpath "$agents_root/adapters/pi/mcp.json")" ]

"$deploy" --check --agents-root "$agents_root" --home "$fake_home" --profile work
second_run="$("$deploy" --apply --agents-root "$agents_root" --home "$fake_home" --profile work)"
case "$second_run" in
  *'linked '*) printf 'second apply was not idempotent: %s\n' "$second_run" >&2; exit 1 ;;
  *'ok '*) ;;
  *) printf 'second apply did not verify existing links: %s\n' "$second_run" >&2; exit 1 ;;
esac

conflict_home="$test_dir/conflict-home"
mkdir -p "$conflict_home/.pi/agent"
printf 'keep me\n' >"$conflict_home/.pi/agent/AGENTS.md"
if "$deploy" --apply --agents-root "$agents_root" --home "$conflict_home" --profile personal >/dev/null 2>&1; then
  printf 'apply overwrote an existing unmanaged file\n' >&2
  exit 1
fi
grep -F 'keep me' "$conflict_home/.pi/agent/AGENTS.md" >/dev/null

legacy_conflict_home="$test_dir/legacy-conflict-home"
mkdir -p "$legacy_conflict_home/.codex"
printf 'keep legacy instructions\n' >"$legacy_conflict_home/.codex/AGENTS.md"
if "$deploy" --apply --agents-root "$agents_root" --home "$legacy_conflict_home" --profile work >/dev/null 2>&1; then
  printf 'apply overwrote an unmanaged legacy instruction file\n' >&2
  exit 1
fi
grep -F 'keep legacy instructions' "$legacy_conflict_home/.codex/AGENTS.md" >/dev/null

instructions_home="$test_dir/instructions-home"
mkdir -p "$instructions_home/.agents/skills"
printf 'preserve shared skill directory\n' >"$instructions_home/.agents/skills/README"
"$deploy" --apply --instructions-only --agents-root "$agents_root" --home "$instructions_home" --profile work
[ "$(realpath "$instructions_home/.codex/AGENTS.md")" = "$(realpath "$agents_root/profiles/work/john/AGENTS.md")" ]
[ "$(realpath "$instructions_home/.claude/CLAUDE.md")" = "$(realpath "$agents_root/profiles/work/john/AGENTS.md")" ]
grep -F 'preserve shared skill directory' "$instructions_home/.agents/skills/README" >/dev/null
[ ! -e "$instructions_home/.agents/mcp.json" ]

printf 'agents deploy tests: ok\n'
