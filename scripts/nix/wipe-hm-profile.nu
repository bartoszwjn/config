#!/usr/bin/env nu

# Remove all noncurrent generations of the home-manager profile
def main [
    --user: string # The user whose profile will be wiped
    --dry-run # Show which generations would be removed without removing them
] {
    let current_user = $env.USER
    let target_user = if $user == null { $current_user } else { $user }

    mut args = []
    let cmd = if $target_user == $current_user {
        "nix"
    } else {
        $args ++= [-u $target_user nix]
        "sudo"
    }
    $args ++= [profile wipe-history]
    let profile_path = if $target_user == $current_user {
        "~/.local/state/nix/profiles/home-manager" | path expand --no-symlink
    } else {
        (
            $"~($target_user)"
            | path expand --no-symlink
            | path join ".local/state/nix/profiles/home-manager"
        )
    }
    $args ++= [--profile $profile_path]
    if $dry_run {
        $args ++= [--dry-run]
    }
    let args = $args

    print -e $"(ansi default_bold)($cmd) ($args | str join ' ')(ansi reset)"
    do -c { ^$cmd ...$args }
}
