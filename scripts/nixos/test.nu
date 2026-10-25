#!/usr/bin/env nu

use ../common.nu run_sudo
use ./build.nu
use ./common.nu [set_system_profile, switch_to_configuration]

# Build and activate the NixOS configuration for the current host without adding bootloader entries
export def --wrapped main [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> nothing {
    if $help {
        help commands main
        return
    }

    run_sudo --validate
    let path = build --nix=$nix ...$args
    switch_to_configuration $path test
}
