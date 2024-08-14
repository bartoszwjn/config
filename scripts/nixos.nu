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
    ...args: string # Additional arguments passed to 'nix build'
]: nothing -> nothing {
    if $help {
        help commands "main switch"
        return
    }

    run-cmd sudo --validate
    let path = main build --nix=$nix ...$args
    switch-to-configuration $path switch
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
    ...args: string # Additional arguments passed to 'nix build'
] {
    if $help {
        help commands "main boot"
        return
    }

    run-cmd sudo --validate
    let path = main build --nix=$nix ...$args
    switch-to-configuration $path boot
}

# Switch to a specialisation of the system configuration
#
# If no specialisation name is given, switch to the default, unspecialised configuration.
def "main specialisation" [
    specialisation?: string # Name of the specialisation to activate
] {
    switch-to-configuration /nix/var/nix/profiles/system test $specialisation
}

def switch-to-configuration [
    $path: path, action: string, $specialisation?: string
]: nothing -> nothing {
    let systemd_run = [
        systemd-run
        -E LOCALE_ARCHIVE
        -E NIXOS_INSTALL_BOOTLOADER=
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

# Compare NixOS configurations across revisions of a flake
#
# --left defaults to 'HEAD', if --left-host is not given, and to the current worktree otherwise.
# --right defaults to the current worktree.
def "main diff" [
    ...hosts: string # Name of the attribute(s) in `nixosConfigurations` to compare
    --left (-l): string # Commit on the left side of the comparison
    --right (-r): string # Commit on the right side of the comparison
    --left-host: string # Compare all other hosts to this one.
    --program (-p): string = "nix-diff" # Program used for diffing ('nix-diff' or 'nvd')
] {
    let left = match [$left $left_host] {
        [null null] => { "HEAD" },
        [null _] => { null },
        [_ _] => { $left },
    }
    let program = match $program {
        "nix-diff" | "nvd" => { $program },
        _ => {
            error make {
                msg: $"Unsupported value for parameter --program: ($program)"
                label: {
                    text: "Expected one of: 'nix-diff', 'nvd'"
                    span: (metadata $program).span
                }
            }
        }
    }

    for right_host in $hosts {
        let left_host = match $left_host { null => { $right_host }, _ => { $left_host } }
        let left_rev = match $left { null => { null }, _ => { do -c { ^git rev-parse $left } } }
        let right_rev = match $right { null => { null }, _ => { do -c { ^git rev-parse $right } } }
        let left_path = match $program {
            "nix-diff" => { get-path-for-nix-diff $left_host $left_rev },
            "nvd" => { get-path-for-nvd $left_host $left_rev },
        }
        let right_path = match $program {
            "nix-diff" => { get-path-for-nix-diff $right_host $right_rev },
            "nvd" => { get-path-for-nvd $right_host $right_rev },
        }

        $env.config.table.mode = "none"
        print [
            [host ref rev path];
            [$left_host $left $left_rev $left_path]
            [$right_host $right $right_rev $right_path]
        ]
        if $left_path != $right_path {
            match $program {
                "nix-diff" => {
                    do -c { ^nix-diff --character-oriented $left_path $right_path }
                }
                "nvd" => {
                    do -c { ^nvd diff $left_path $right_path }
                }
            }
        }
    }
}

def get-path-for-nix-diff [$host: string, $rev?: string]: nothing -> string {
    let rev = match $rev { null => { "" }, _ => { $"?rev=($rev)" } }
    let attr = $"nixosConfigurations.($host).config.system.build.toplevel"
    do -c { ^nix path-info --derivation $".($rev)#($attr)" }
}

def get-path-for-nvd [$host: string, $rev?: string]: nothing -> string {
    let rev = match $rev { null => { "" }, _ => { $"?rev=($rev)" } }
    let attr = $"nixosConfigurations.($host).config.system.build.toplevel"
    do -c { ^nix build --no-link --print-out-paths $".($rev)#($attr)" }
}

def --wrapped run-cmd [cmd: string, ...args: string] {
    print -e $"(ansi default_bold)($cmd) ($args | str join ' ')(ansi reset)"
    do -c { ^$cmd ...$args }
}

alias "main b" = main build
alias "main d" = main diff
alias "main s" = main switch
alias "main spec" = main specialisation
alias "main t" = main test
