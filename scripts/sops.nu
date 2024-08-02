#!/usr/bin/env nu

# Run sops with $env.SOPS_AGE_KEY set by decrypting the file at $env.AGE_KEY_FILE
def --wrapped main [
    --help (-h) # Display the help message for this command
    ...args: string # Arguments passed to sops
] {
    if $help {
        help main
        return
    }

    let age_args = [-d $env.AGE_KEY_FILE]
    print -e $"(ansi default_bold)age ($age_args | str join ' ')(ansi reset)"
    $env.SOPS_AGE_KEY = (do -c { ^age ...$age_args })

    print -e $"(ansi default_bold)sops ($args | str join ' ')(ansi reset)"
    do -c { ^sops ...$args }
}
