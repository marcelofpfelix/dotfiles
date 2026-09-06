#!/bin/sh
set -eu

homelab_root="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
cd "$homelab_root"
exec uv run --extra dev ansible-lint
