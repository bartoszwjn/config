#!/usr/bin/env bash
# Print the currently installed Nix version, as well the newest versions available in nixpkgs

set -euo pipefail

echo "=== Installed CLI ==="
nix --version

echo "=== Installed daemon ==="
nix store ping

echo "=== Pinned nixpkgs ==="
nix eval nixpkgs#nix.version --raw
echo

echo "=== nixpkgs/nixpkgs-unstable ==="
nix eval github:NixOS/nixpkgs/nixpkgs-unstable#nix.version --raw
echo
