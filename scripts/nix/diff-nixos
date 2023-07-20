#!/usr/bin/env bash
# Run `nix-diff` on two revisions of a NixOS configuration defined in a git flake

set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 <flake-ref> <nixos-configuration> [<commit1> [<commit2>]]"
    exit 1
fi

flake_ref="${1}"
nixos_attr="nixosConfigurations.${2}.config.system.build.toplevel"

commit_1_display="${3-HEAD}"
commit_1_rev="?rev=$(git rev-parse "${3-HEAD}")"

commit_2_display="${4-worktree}"
commit_2_rev="${4+?rev=$(git rev-parse "$4")}"

drv_1_path="$(nix path-info --derivation "${flake_ref}${commit_1_rev}#${nixos_attr}")"
drv_2_path="$(nix path-info --derivation "${flake_ref}${commit_2_rev}#${nixos_attr}")"

printf "%s %s\n%s %s" \
    "${commit_1_display}" "${drv_1_path}" "${commit_2_display}" "${drv_2_path}" \
    | column --table

if [ "${drv_1_path}" = "${drv_2_path}" ]; then
    echo "derivation paths are the same"
else
    nix-diff "${drv_1_path}" "${drv_2_path}" ${NIX_DIFF_FLAGS-"--character-oriented"}
fi
