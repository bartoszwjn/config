#!/usr/bin/env nu

use ../common.nu run_cmd

# Build the NixOS configuration for the current host
export def --wrapped main [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> string {
    if $help {
        help commands main
        return
    }

    let cmd = if $nix { "nix" } else { "nom" }
    let flake = $env.CONFIG_REPO_ROOT
    let host = sys host | get hostname
    let nix_args = [
        build
        $"git+file://($flake)#nixosConfigurations.($host).config.system.build.toplevel"
        --no-link
        --print-out-paths
        ...$args
    ]

    run_cmd $cmd ...$nix_args
}
