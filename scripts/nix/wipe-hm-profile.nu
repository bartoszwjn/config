#!/usr/bin/env nu

use ../common.nu [run_cmd run_sudo]

# Remove all noncurrent generations of the home-manager profile
export def main [
    --user: string # The user whose profile will be wiped
    --dry-run # Show which generations would be removed without removing them
]: nothing -> nothing {
    let current_user = whoami
    let target_user = if $user == null { $current_user } else { $user }

    let profile_path = (
        $"~($target_user)"
        | path expand --no-symlink
        | path join ".local/state/nix/profiles/home-manager"
    )

    let nix_args = [
        profile wipe-history
        --profile $profile_path
        ...(if $dry_run { [--dry-run] } else { [] })
    ]

    if $target_user == $current_user {
        run_cmd nix ...$nix_args
    } else {
        run_sudo -u $target_user nix ...$nix_args
    }
}
