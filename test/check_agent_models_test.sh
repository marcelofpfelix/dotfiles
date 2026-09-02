#!/bin/sh
set -eu

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT HUP INT TERM

repo_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
checker="$repo_root/desktop/bin/check-agent-models"
agents_root="$test_dir/agents"
target_home="$test_dir/home"
lagostim_root="$test_dir/lagostim"

mkdir -p "$agents_root/shared" "$target_home/.pi/agent" \
  "$target_home/.config/opencode" "$target_home/.codex"

for profile in personal-hermes constanca-hermes work-hermes; do
  mkdir -p "$lagostim_root/$profile"
  cat >"$lagostim_root/$profile/config.yaml" <<'EOF'
model:
  default: gpt-5.5
  provider: openai-codex
fallback_providers:
  - provider: litellm
    model: Kimi-K3
EOF
done

cat >"$agents_root/shared/model-policy.json" <<'EOF'
{
  "version": 1,
  "profiles": {
    "personal": {"hermes": {"primary": {"provider": "openai-codex", "model": "gpt-5.6"}, "fallback": {"provider": "litellm", "model": "Kimi-K3"}}},
    "family": {"hermes": {"primary": {"provider": "openai-codex", "model": "gpt-5.6"}, "fallback": {"provider": "litellm", "model": "Kimi-K3"}}},
    "work": {"hermes": {"primary": {"provider": "openai-codex", "model": "gpt-5.6"}, "fallback": {"provider": "litellm", "model": "Kimi-K3"}}}
  },
  "harnesses": {
    "pi": {"provider": "openai-codex", "model": "gpt-5.5"},
    "opencode": {"provider": "litellm", "model": "aiswe/coding-model"},
    "codex": {"provider": "openai", "model": "gpt-5.6-sol", "legacy": true}
  }
}
EOF

cat >"$target_home/.pi/agent/settings.json" <<'EOF'
{"defaultProvider":"openai-codex","defaultModel":"gpt-5.4"}
EOF
cat >"$target_home/.config/opencode/opencode.json" <<'EOF'
{"model":"litellm/aiswe/coding-model"}
EOF
cat >"$target_home/.codex/config.toml" <<'EOF'
model = "gpt-5.6-sol"
EOF

if "$checker" --agents-root "$agents_root" --home "$target_home" \
  --lagostim-root "$lagostim_root" >/dev/null 2>&1; then
  printf 'checker accepted drifted Pi and Hermes configs\n' >&2
  exit 1
fi

sed -i.bak 's/gpt-5.4/gpt-5.5/' "$target_home/.pi/agent/settings.json"
rm "$target_home/.pi/agent/settings.json.bak"
for profile in personal-hermes constanca-hermes work-hermes; do
  sed -i.bak 's/gpt-5.5/gpt-5.6/' "$lagostim_root/$profile/config.yaml"
  rm "$lagostim_root/$profile/config.yaml.bak"
done

if "$checker" --agents-root "$agents_root" --home "$target_home" \
  --lagostim-root "$lagostim_root" >/dev/null 2>&1; then
  printf 'checker accepted unsupported bare gpt-5.6 Codex slug\n' >&2
  exit 1
fi

sed -i.bak 's/"model": "gpt-5.6"/"model": "gpt-5.6-sol"/g' "$agents_root/shared/model-policy.json"
rm "$agents_root/shared/model-policy.json.bak"
for profile in personal-hermes constanca-hermes work-hermes; do
  sed -i.bak 's/gpt-5.6/gpt-5.6-sol/' "$lagostim_root/$profile/config.yaml"
  rm "$lagostim_root/$profile/config.yaml.bak"
done

"$checker" --agents-root "$agents_root" --home "$target_home" \
  --lagostim-root "$lagostim_root"

cat >"$test_dir/fallback-usage.json" <<'EOF'
{"completed":true,"failed":false,"provider":"litellm","model":"Kimi-K3"}
EOF

if smoke_output="$("$checker" --agents-root "$agents_root" --home "$target_home" \
  --lagostim-root "$lagostim_root" \
  --usage-report "work:$test_dir/fallback-usage.json" 2>&1)"; then
  printf 'checker accepted a fallback-masked primary smoke\n' >&2
  exit 1
fi
case "$smoke_output" in
  *'work smoke provider: expected openai-codex, got litellm'*) ;;
  *) printf 'checker did not explain fallback provider drift: %s\n' "$smoke_output" >&2; exit 1 ;;
esac

cat >"$test_dir/primary-usage.json" <<'EOF'
{"completed":true,"failed":false,"provider":"openai-codex","model":"gpt-5.6-sol"}
EOF
"$checker" --agents-root "$agents_root" --home "$target_home" \
  --lagostim-root "$lagostim_root" \
  --usage-report "work:$test_dir/primary-usage.json"

printf 'agent model drift tests: ok\n'
