#!/usr/bin/env nu

# A convenience script for running NixOS-related commands
def main [] {
    help commands main
}

# Build the NixOS configuration for the current host
def --wrapped "main build" [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> string {
    if $help {
        help commands "main build"
        return
    }

    let cmd = if $nix { "nix" } else { "nom" }
    let flake = $env.CONFIG_REPO_ROOT
    let host = (sys host | get hostname)
    let nix_args = [
        build
        $"git+file://($flake)#nixosConfigurations.($host).config.system.build.toplevel"
        --no-link
        --print-out-paths
        ...$args
    ]

    run-cmd $cmd ...$nix_args
}

# Build and activate the NixOS configuration for the current host
def --wrapped "main switch" [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    --install-bootloader # (re)install the bootloader
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> nothing {
    if $help {
        help commands "main switch"
        return
    }

    run-cmd sudo --validate
    let path = main build --nix=$nix ...$args
    set-system-profile $path
    switch-to-configuration $path switch --install-bootloader=$install_bootloader
}

# Build and activate the NixOS configuration for the current host without adding bootloader entries
def --wrapped "main test" [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> nothing {
    if $help {
        help commands "main test"
        return
    }

    run-cmd sudo --validate
    let path = main build --nix=$nix ...$args
    switch-to-configuration $path test
}

# Build the NixOS configuration for the current host and make it the boot default
def --wrapped "main boot" [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    --install-bootloader # (re)install the bootloader
    ...args: string # Additional arguments passed to 'nix build'
] {
    if $help {
        help commands "main boot"
        return
    }

    run-cmd sudo --validate
    let path = main build --nix=$nix ...$args
    set-system-profile $path
    switch-to-configuration $path boot --install-bootloader=$install_bootloader
}

# Switch to a specialisation of the system configuration
#
# If no specialisation name is given, switch to the default, unspecialised configuration.
def "main specialisation" [
    specialisation?: string # Name of the specialisation to activate
] {
    switch-to-configuration /nix/var/nix/profiles/system test $specialisation
}

def set-system-profile [path: path]: nothing -> nothing {
    run-cmd sudo nix-env --profile /nix/var/nix/profiles/system --set $path
}

def switch-to-configuration [
    path: path, action: string, specialisation?: string, --install-bootloader
]: nothing -> nothing {
    let systemd_run = [
        systemd-run
        -E LOCALE_ARCHIVE
        -E $"NIXOS_INSTALL_BOOTLOADER=(if $install_bootloader { '1' } else { '' })"
        --collect
        --no-ask-password
        --pipe
        --quiet
        --same-dir
        --service-type=exec
        --unit=nixos-switch-to-configuration
        --wait
    ]
    let cmd_path = [
        $path
        ...(if $specialisation != null { [specialisation $specialisation] } else { [] })
        bin/switch-to-configuration
    ] | path join

    run-cmd sudo ...$systemd_run $cmd_path $action
}

def --wrapped run-cmd [cmd: string, ...args: string] {
    print -e $"(ansi default_bold)($cmd) ($args | str join ' ')(ansi reset)"
    do -c { ^$cmd ...$args }
}

alias "main b" = main build
alias "main s" = main switch
alias "main spec" = main specialisation
alias "main t" = main test
