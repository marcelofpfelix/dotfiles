#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
broker="$repo_root/desktop/bin/agent-host-broker"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/docker" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$DOCKER_ARGS"
printf '%s\t%s\n' work-hermes 'Up 1 minute (healthy)'
EOF
chmod +x "$tmp_dir/bin/docker"

ping_result="$(printf '%s\n' '{"version":1,"request_id":"ping-1","operation":"ping"}' | "$broker")"
jq -e '
  .version == 1 and
  .request_id == "ping-1" and
  .ok == true and
  (.result.operations | sort) == ["docker_status","ping","repo_status"]
' <<<"$ping_result" >/dev/null

repo_result="$(jq -nc --arg path "$repo_root" '{version:1,request_id:"repo-1",operation:"repo_status",args:{path:$path}}' |
  "$broker")"
jq -e '.ok == true and .result.path != "" and (.result.status | type) == "string"' <<<"$repo_result" >/dev/null

if printf '%s\n' '{"version":1,"request_id":"bad-path","operation":"repo_status","args":{"path":"/private/tmp"}}' |
  "$broker" >/dev/null 2>&1; then
  echo "broker accepted a repository outside GWT" >&2
  exit 1
fi

docker_result="$(printf '%s\n' '{"version":1,"request_id":"docker-1","operation":"docker_status","args":{"profile":"work"}}' |
  PATH="$tmp_dir/bin:$PATH" DOCKER_ARGS="$tmp_dir/docker-args" "$broker")"
jq -e '.ok == true and .result.profile == "work" and .result.container == "work-hermes"' <<<"$docker_result" >/dev/null
grep -Fq -- '--context colima ps --filter name=^/work-hermes$ --format' "$tmp_dir/docker-args"

if printf '%s\n' '{"version":1,"request_id":"bad-op","operation":"shell","args":{"command":"id"}}' |
  "$broker" >/dev/null 2>&1; then
  echo "broker accepted an unknown operation" >&2
  exit 1
fi

if printf '%s\n' 'not-json' | "$broker" >/dev/null 2>&1; then
  echo "broker accepted malformed JSON" >&2
  exit 1
fi

echo "agent host broker tests passed"
