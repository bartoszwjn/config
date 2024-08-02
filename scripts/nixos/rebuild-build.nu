#!/usr/bin/env nu

# Build the NixOS configuration for the current host
def --wrapped main [
    --help (-h) # Display the help message for this command
    --nix # Call nix directly instead of using nom
    ...$args # Additional arguments passed to 'nix build'
] {
    if $help {
        help main
        return
    }

    let flake = $env.CONFIG_REPO_ROOT
    let host = (sys host | get hostname)
    let nix_args = [
        build
        $"git+file://($flake)#nixosConfigurations.($host).config.system.build.toplevel"
        --no-link
        ...$args
    ]

    let cmd = if $nix { "nix" } else { "nom" }
    print -e $"(ansi default_bold)($cmd) ($nix_args | str join ' ')(ansi reset)"
    do -c { ^$cmd ...$nix_args }
}
