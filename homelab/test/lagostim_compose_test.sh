#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
compose_file="${repo_root}/files/lagostim/docker-compose.yml"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "${tmp_dir}/runtime" "${tmp_dir}/gwt" "${tmp_dir}/agents"

rendered="${tmp_dir}/compose.json"
HOME="$tmp_dir" \
LAGOSTIM_DOCKER_ROOT="${tmp_dir}/runtime" \
LAGOSTIM_SOURCE_ROOT="/Volumes/NVMe/gwt/marcelofpfelix/lagostim/main" \
AGENTS_REPO_ROOT="${tmp_dir}/agents" \
HERMES_GWT_ROOT="${tmp_dir}/gwt" \
PERSONAL_HERMES_API_SERVER_KEY=test-personal \
CONSTANCA_HERMES_API_SERVER_KEY=test-family \
WORK_HERMES_API_SERVER_KEY=test-work \
LITELLM_API_KEY=test-litellm \
docker-compose --file "$compose_file" --profile hermes config --format json >"$rendered"

jq -e '
  (.services | keys | sort) == ["constanca-hermes", "personal-hermes", "work-hermes"] and
  ([.services[].environment | has("OPENAI_API_KEY")] | all(. == false)) and
  ([.services[] | .working_dir] | all(. == "/workspace")) and
  ([.services[] | .volumes[] | select(.target == "/opt/data" or .target == "/workspace") | (.read_only // false)] | all(. == false)) and
  ([.services[] | .volumes[] | select(.target == "/Users/marcelof/gwt") | (.read_only // false)] | length == 3 and all(. == false)) and
  ([.services[] | .volumes[] | select(.target | startswith("/Users/marcelof/gwt/"))] | length == 0) and
  ([.services["constanca-hermes"].volumes[] | select(.target == "/Volumes/NVMe") | (.read_only // false)] | length == 1 and all(. == false)) and
  ([.services["constanca-hermes"].volumes[] | select(.target == "/opt/data/SOUL.md" or .target == "/opt/data/IDENTITY.md" or .target == "/workspace/AGENTS.md") | .read_only] | length == 3 and all) and
  ([.services["personal-hermes"].volumes[] | select(.target == "/opt/data/SOUL.md" or .target == "/opt/data/IDENTITY.md" or .target == "/workspace/AGENTS.md") | .read_only] | length == 3 and all)
  and ([.services["work-hermes"].volumes[] | select(.target == "/opt/data/ssh") | .read_only] | length == 1 and all)
  and ([.services["work-hermes"].volumes[] | select(.target == "/opt/data/SOUL.md" or .target == "/opt/data/IDENTITY.md" or .target == "/workspace/AGENTS.md") | .read_only] | length == 3 and all)
' "$rendered" >/dev/null

echo "lagostim compose tests passed"
