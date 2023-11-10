#!/usr/bin/env bash
# Run `nixos-rebuild switch`

set -euo pipefail

PS4='+> '
set -x

sudo nixos-rebuild switch --flake "${CONFIG_REPO_ROOT}" "$@"
