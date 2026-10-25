#!/usr/bin/env nu

use ../common.nu run_sudo
use ./build.nu
use ./common.nu [set_system_profile, switch_to_configuration]

# Build the NixOS configuration for the current host and make it the boot default
export def --wrapped main [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    --install-bootloader # (re)install the bootloader
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> nothing {
    if $help {
        help commands main
        return
    }

    run_sudo --validate
    let path = build --nix=$nix ...$args
    set_system_profile $path
    switch_to_configuration $path boot --install-bootloader=$install_bootloader
}
