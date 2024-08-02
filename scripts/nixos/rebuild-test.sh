#!/usr/bin/env bash
# Run `nixos-rebuild test`

set -euo pipefail

PS4='+> '
set -x

sudo nixos-rebuild test --flake "${CONFIG_REPO_ROOT}" "$@"
